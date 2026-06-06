import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/notices_provider.dart';
import '../data/notices_models.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  static const _categories = [
    'Academic', 'Administrative', 'Events', 'Urgent', 'General'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);
    final selectedCategory = ref.watch(selectedNoticeCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notices',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceContainerLowest,
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _Pill(
                        label: 'All',
                        isSelected: selectedCategory == null,
                        onTap: () => ref
                            .read(selectedNoticeCategoryProvider.notifier)
                            .state = null,
                      ),
                      ..._categories.map((c) => _Pill(
                            label: c,
                            isSelected: selectedCategory == c,
                            onTap: () => ref
                                .read(selectedNoticeCategoryProvider.notifier)
                                .state = c,
                          )),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          Expanded(
            child: noticesAsync.when(
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
                    const Icon(Icons.wifi_off, size: 48, color: AppColors.outline),
                    const SizedBox(height: 12),
                    const Text('Could not load notices',
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(noticesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (notices) => notices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off, size: 64, color: AppColors.outline),
                          SizedBox(height: 16),
                          Text('No notices yet',
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.refresh(noticesProvider),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notices.length,
                        itemBuilder: (_, i) => _NoticeCard(
                          notice: notices[i],
                          onTap: () => context.push('/notices/${notices[i].id}'),
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

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;

  const _NoticeCard({required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Indicator Strip
            Container(
              width: 5,
              color: notice.isUrgent ? AppColors.error : AppColors.primary,
            ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          if (notice.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notice.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notice.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _timeAgo(notice.createdDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
