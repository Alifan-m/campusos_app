import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        elevation: 0,
        title: const Text('CampusOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: AppColors.navBar,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'S',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Student', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text('ID: ${user?.studentId ?? 'Not set'}', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            (user?.course?.isNotEmpty == true ? user!.course! : 'BSc. Computer Science').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account & payback section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACCOUNT & PREFERENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(icon: Icons.receipt_long_rounded, label: 'My Orders', onTap: () {}),
                      _MenuItem(icon: Icons.event_rounded, label: 'My Events', onTap: () {}),
                      _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () {}, badge: '3'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('SETTINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItem(icon: Icons.phone_rounded, label: 'Change Phone Number', onTap: () {}),
                      _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                      _MenuItem(icon: Icons.info_outline_rounded, label: 'About CampusOS', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: e.value.onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(e.value.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 14),
                      Expanded(child: Text(e.value.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface))),
                      if (e.value.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                          child: Text(e.value.badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 18),
                    ],
                  ),
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.badge});
}
