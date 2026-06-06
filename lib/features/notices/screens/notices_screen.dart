import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/notices_provider.dart';
import '../data/notices_models.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  // These map to what backend stores
  static const _categories = ['All', 'General', 'Academic', 'Faculty', 'Urgent'];

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'urgent': return AppColors.error;
      case 'academic': return AppColors.primary;
      case 'faculty': return const Color(0xFF7C3AED);
      case 'general': return AppColors.success;
      default: return AppColors.onSurfaceVariant;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'urgent': return Icons.warning_rounded;
      case 'academic': return Icons.school_rounded;
      case 'faculty': return Icons.person_rounded;
      case 'general': return Icons.campaign_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesProvider);
    final selectedCat = ref.watch(selectedNoticeCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navBar,
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.navBar,
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notices &',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: AppColors.navBar,
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, bottom: 10),
                    children: _categories.map((cat) {
                      final isAll = cat == 'All';
                      // For urgent, we filter by isUrgent flag — map to 'urgent' category string
                      final isSelected = isAll
                          ? selectedCat == null
                          : selectedCat?.toLowerCase() == cat.toLowerCase();

                      final accent = isAll ? Colors.white : _categoryColor(cat);

                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedNoticeCategoryProvider.notifier).state =
                              isAll ? null : cat.toLowerCase();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isAll ? Colors.white : accent)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? (isAll ? Colors.white : accent)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? (isAll ? AppColors.navBar : Colors.white)
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
              ),
            ),
          ),
        ],
        body: noticesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.outline),
                const SizedBox(height: 16),
                const Text('Could not load notices',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(noticesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (notices) {
            // If urgent category selected, also filter by isUrgent flag
            final filtered = selectedCat?.toLowerCase() == 'urgent'
                ? notices.where((n) => n.isUrgent).toList()
                : notices;

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.outline),
                    const SizedBox(height: 16),
                    Text(
                      selectedCat == null ? 'No notices yet' : 'No ${selectedCat} notices',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            // Sort: urgent first
            final sorted = [...filtered]
              ..sort((a, b) {
                if (a.isUrgent && !b.isUrgent) return -1;
                if (!a.isUrgent && b.isUrgent) return 1;
                return b.createdDate.compareTo(a.createdDate);
              });

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: sorted.length,
              itemBuilder: (_, i) => _NoticeCard(
                notice: sorted[i],
                categoryIcon: _categoryIcon(sorted[i].category),
                categoryColor: sorted[i].isUrgent ? AppColors.error : _categoryColor(sorted[i].category),
                onTap: () => context.push('/notices/${sorted[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = notice.isUrgent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUrgent ? const Color(0xFFFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUrgent ? AppColors.error.withOpacity(0.3) : AppColors.outlineVariant,
            width: isUrgent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(isUrgent ? 0.1 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isUrgent) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                notice.category.toUpperCase(),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (notice.postedBy != null)
                              Expanded(
                                child: Text(
                                  notice.postedBy!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            Text(
                              _timeAgo(notice.createdDate),
                              style: const TextStyle(fontSize: 11, color: AppColors.outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 18),
                ],
              ),
            ),
            // Title + body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isUrgent ? AppColors.error : AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notice.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
