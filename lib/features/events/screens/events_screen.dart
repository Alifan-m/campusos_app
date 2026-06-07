import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/events_provider.dart';
import '../data/events_models.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  static const _categories = ['All', 'Academic', 'Social', 'Sports', 'Career'];

  Color _categoryColor(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'academic': return AppColors.primary;
      case 'social': return const Color(0xFF7C3AED);
      case 'sports': return AppColors.secondary;
      case 'career': return const Color(0xFF0891B2);
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final selectedCat = ref.watch(selectedEventCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navBar,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.navBar,
                padding: const EdgeInsets.fromLTRB(20, 72, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Discover what\'s happening on campus',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: AppColors.navBar,
                child: Column(
                  children: [
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16, bottom: 10),
                        children: _categories.map((cat) {
                          final isAll = cat == 'All';
                          final isSelected = isAll
                              ? selectedCat == null
                              : selectedCat == cat;
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedEventCategoryProvider.notifier).state =
                                  isAll ? null : cat;
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.secondary
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondary
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy_rounded, size: 56, color: AppColors.outline),
                const SizedBox(height: 16),
                const Text('Could not load events',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(eventsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_outlined, size: 56, color: AppColors.outline),
                    const SizedBox(height: 16),
                    Text(
                      selectedCat == null ? 'No events yet' : 'No $selectedCat events',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            // Separate today vs upcoming
            final todayEvents = events.where((e) => e.isToday).toList();
            final upcomingEvents = events.where((e) => !e.isToday && e.isUpcoming).toList();
            final pastEvents = events.where((e) => !e.isUpcoming && !e.isToday).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (todayEvents.isNotEmpty) ...[
                  _SectionLabel(label: "Today", accent: AppColors.secondary),
                  const SizedBox(height: 10),
                  ...todayEvents.map((e) => _EventCard(
                    event: e,
                    accentColor: _categoryColor(e.category),
                    onTap: () => context.push('/events/${e.id}'),
                  )),
                  const SizedBox(height: 20),
                ],
                if (upcomingEvents.isNotEmpty) ...[
                  _SectionLabel(label: "Upcoming", accent: AppColors.primary),
                  const SizedBox(height: 10),
                  ...upcomingEvents.map((e) => _EventCard(
                    event: e,
                    accentColor: _categoryColor(e.category),
                    onTap: () => context.push('/events/${e.id}'),
                  )),
                ],
                if (pastEvents.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionLabel(label: "Past Events", accent: AppColors.outline),
                  const SizedBox(height: 10),
                  ...pastEvents.map((e) => _EventCard(
                    event: e,
                    accentColor: AppColors.outline,
                    isPast: true,
                    onTap: () => context.push('/events/${e.id}'),
                  )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color accent;
  const _SectionLabel({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accent, letterSpacing: -0.2)),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final Color accentColor;
  final bool isPast;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.accentColor,
    required this.onTap,
    this.isPast = false,
  });

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${months[dt.month - 1]} ${dt.day} · $h12:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date sidebar
            Container(
              width: 68,
              decoration: BoxDecoration(
                color: isPast ? AppColors.surfaceContainerHigh : accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.startDate.day.toString(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isPast ? AppColors.outline : accentColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
                        [event.startDate.month - 1],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPast ? AppColors.outline : accentColor,
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (event.isToday)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('TODAY',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        if (event.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.category!.toUpperCase(),
                              style: TextStyle(
                                color: isPast ? AppColors.outline : accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.people_rounded, size: 13, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Text(
                              '${event.rsvpCount}',
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isPast ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.startDate),
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.isRsvped) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                SizedBox(width: 4),
                                Text('Interested',
                                    style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
