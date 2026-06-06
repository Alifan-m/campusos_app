import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/cafeteria_provider.dart';
import '../data/cafeteria_models.dart';

class OrderStatusScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderStatusScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderStatusScreen> createState() =>
      _OrderStatusScreenState();
}

class _OrderStatusScreenState extends ConsumerState<OrderStatusScreen> {
  Order? _order;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadOrder());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await ref
          .read(cafeteriaRepositoryProvider)
          .getOrderStatus(widget.orderId);
      if (mounted) setState(() => _order = order);
      if (order.status == 'ready' || order.status == 'completed') {
        _refreshTimer?.cancel();
      }
    } catch (_) {}
  }

  int _statusIndex(String status) {
    switch (status) {
      case 'paid':
        return 1;
      case 'preparing':
        return 2;
      case 'ready':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Status',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Confirmed!',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Order #${_order!.id}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 32),

                  // Status stepper
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _StatusStep(
                            label: 'Order Received',
                            isDone: _statusIndex(_order!.status) >= 1),
                        _StatusStep(
                            label: 'Being Prepared',
                            isDone: _statusIndex(_order!.status) >= 2),
                        _StatusStep(
                            label: 'Ready for Pickup',
                            isDone: _statusIndex(_order!.status) >= 3),
                        _StatusStep(
                            label: 'Completed',
                            isDone: _statusIndex(_order!.status) >= 4,
                            isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_order!.status == 'ready')
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.restaurant_rounded,
                              color: AppColors.success),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your food is ready! Go to the cafeteria counter to collect it.',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isLast;

  const _StatusStep(
      {required this.label, required this.isDone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? AppColors.success : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.circle,
                color: Colors.white,
                size: isDone ? 16 : 8,
              ),
            ),
            if (!isLast)
              Container(
                  width: 2, height: 32, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  isDone ? FontWeight.w600 : FontWeight.normal,
              color:
                  isDone ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
