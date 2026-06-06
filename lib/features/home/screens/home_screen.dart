import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../notices/providers/notices_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final noticesAsync = ref.watch(noticesProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Tharaka University',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(upcomingEventsProvider);
          ref.refresh(noticesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.fullName.split(' ').first ?? 'Student',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.studentId ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              // Quick actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _QuickAction(
                    icon: Icons.restaurant_rounded,
                    label: 'Order Food',
                    color: const Color(0xFFFF6B35),
                    iconColor: Colors.white,
                    onTap: () => context.go('/cafeteria'),
                  ),
                  _QuickAction(
                    icon: Icons.calendar_today_rounded,
                    label: 'Events',
                    color: AppColors.primary,
                    iconColor: Colors.white,
                    onTap: () => context.go('/events'),
                  ),
                  _QuickAction(
                    icon: Icons.notifications_rounded,
                    label: 'Notices',
                    color: const Color(0xFF10B981),
                    iconColor: Colors.white,
                    onTap: () => context.go('/notices'),
                  ),
                  _QuickAction(
                    icon: Icons.map_rounded,
                    label: 'Campus Map',
                    color: const Color(0xFF8B5CF6),
                    iconColor: Colors.white,
                    onTap: () => context.go('/map'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Today's events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/events'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              eventsAsync.when(
                loading: () => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.outlineVariant, width: 0.5),
                  ),
                  child: const Center(
                      child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (events) => events.isEmpty
                    ? Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.outlineVariant,
                              width: 0.5),
                        ),
                        child: const Center(
                          child: Text('No upcoming events',
                              style: TextStyle(
                                  color: AppColors.outline)),
                        ),
                      )
                    : SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (_, i) {
                            final event = events[i];
                            return GestureDetector(
                              onTap: () => context
                                  .push('/events/${event.id}'),
                              child: Container(
                                width: 200,
                                margin:
                                    const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: event.isToday
                                      ? AppColors.primary
                                      : AppColors
                                          .surfaceContainerLowest,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.outlineVariant,
                                      width: 0.5),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (event.isToday)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text('TODAY',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ),
                                    const Spacer(),
                                    Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: event.isToday
                                            ? Colors.white
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.location ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: event.isToday
                                            ? Colors.white70
                                            : AppColors
                                                .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Latest notice
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Notice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/notices'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              noticesAsync.when(
                loading: () => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (notices) => notices.isEmpty
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        onTap: () => context
                            .push('/notices/${notices.first.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notices.first.isUrgent
                                ? AppColors.errorContainer
                                : const Color(0xFFD3E4FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: notices.first.isUrgent
                                    ? AppColors.error
                                    : AppColors.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                notices.first.isUrgent
                                    ? Icons.warning_rounded
                                    : Icons.campaign_rounded,
                                color: notices.first.isUrgent
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notices.first.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: notices.first.isUrgent
                                            ? AppColors.error
                                            : AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      notices.first.body,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: notices.first.isUrgent
                                            ? AppColors.error
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: notices.first.isUrgent
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
