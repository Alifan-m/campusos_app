import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/cafeteria')) return 1;
    if (location.startsWith('/events')) return 2;
    if (location.startsWith('/notices')) return 3;
    if (location.startsWith('/map')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/cafeteria'); break;
      case 2: context.go('/events'); break;
      case 3: context.go('/notices'); break;
      case 4: context.go('/map'); break;
      case 5: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBar,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', active: idx == 0, onTap: () => _onTap(context, 0)),
                _NavItem(icon: Icons.restaurant_rounded, label: 'Cafeteria', active: idx == 1, onTap: () => _onTap(context, 1)),
                _NavItem(icon: Icons.event_rounded, label: 'Events', active: idx == 2, onTap: () => _onTap(context, 2)),
                _NavItem(icon: Icons.notifications_rounded, label: 'Notices', active: idx == 3, onTap: () => _onTap(context, 3)),
                _NavItem(icon: Icons.map_rounded, label: 'Map', active: idx == 4, onTap: () => _onTap(context, 4)),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', active: idx == 5, onTap: () => _onTap(context, 5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: active ? AppColors.secondary : Colors.white.withOpacity(0.45)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? AppColors.secondary : Colors.white.withOpacity(0.45))),
        ],
      ),
    );
  }
}
