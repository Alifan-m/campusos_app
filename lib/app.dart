import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/bottom_nav.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/cafeteria/screens/cafeteria_screen.dart';
import 'features/cafeteria/screens/cart_screen.dart';
import 'features/cafeteria/screens/checkout_screen.dart';
import 'features/cafeteria/screens/order_status_screen.dart';
import 'features/events/screens/events_screen.dart';
import 'features/events/screens/event_detail_screen.dart';
import 'features/notices/screens/notices_screen.dart';
import 'features/notices/screens/notice_detail_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/cafeteria/screens/order_history_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
    GoRoute(
      path: '/order-status/:id',
      builder: (_, state) => OrderStatusScreen(
        orderId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/events/:id',
      builder: (_, state) => EventDetailScreen(
        eventId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/notices/:id',
      builder: (_, state) => NoticeDetailScreen(
        noticeId: int.parse(state.pathParameters['id']!),
      ),
    ),
    ShellRoute(
      builder: (_, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/cafeteria', builder: (_, __) => const CafeteriaScreen()),
        GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
        GoRoute(path: '/notices', builder: (_, __) => const NoticesScreen()),
        GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class CampusOSApp extends ConsumerWidget {
  const CampusOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusOS',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
