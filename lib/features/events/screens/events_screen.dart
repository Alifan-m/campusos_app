import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/events_provider.dart';
import '../data/events_models.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  static const _categories = [
    'Academic', 'Sports', 'Cultural', 'Career', 'Social'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final selectedCategory = ref.watch(selectedEventCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            color: AppColors.surfaceContainerLowest,
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      _Pill(
                        label: 'All',
                        isSelected: selectedCategory == null,
                        onTap: () => ref
                            .read(selectedEventCategoryProvider.notifier)
                            .state = null,
                      ),
                      ..._categories.map((c) => _Pill(
                            label: c,
                            isSelected: selectedCategory == c,
                            onTap: () => ref
                                .read(selectedEventCategoryProvider.notifier)
                                .state = c,
                          )),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: eventsAsync.when(
              loading: () => ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: CardSkeleton(),
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 48, color: AppColors.outline),
                    const SizedBox(height: 12),
                    const Text('Could not load events',
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(eventsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (events) => events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 64, color: AppColors.outline),
                          SizedBox(height: 16),
                          Text('No events yet',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.refresh(eventsProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (_, i) => _EventCard(
                          event: events[i],
                          onTap: () =>
                              context.push('/events/${events[i].id}'),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.onSurfaceVariant,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date banner
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: event.isToday
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: event.isToday
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.isToday
                        ? 'TODAY'
                        : _formatDate(event.startDate),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: event.isToday
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (event.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: event.isToday
                            ? Colors.white.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.category!,
                        style: TextStyle(
                          fontSize: 11,
                          color: event.isToday
                              ? Colors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          event.location!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(event.startDate),
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${event.rsvpCount} going',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }
}
