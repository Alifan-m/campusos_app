import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../providers/cafeteria_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _waitingForMpesa = false;
  String? _error;
  String? _checkoutRequestId;
  int? _orderId;
  Timer? _pollingTimer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _prefillPhone();
  }

  Future<void> _prefillPhone() async {
    // optionally prefill from secure storage if you saved it
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndPay() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _error = 'Enter your M-Pesa phone number');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(cafeteriaRepositoryProvider);
    final cart = ref.read(cartProvider);

    try {
      // 1. Create order
      final order = await repo.createOrder(cart);
      _orderId = order.id;

      // 2. Initiate STK push
      final mpesaData = await repo.initiateMpesa(
        orderId: order.id,
        phoneNumber: _phoneController.text.trim(),
      );
      _checkoutRequestId = mpesaData['checkout_request_id'];

      setState(() {
        _isLoading = false;
        _waitingForMpesa = true;
        _secondsElapsed = 0;
      });

      // 3. Poll for status
      _pollingTimer =
          Timer.periodic(const Duration(seconds: 3), (_) async {
        _secondsElapsed += 3;
        if (_secondsElapsed >= 90) {
          _pollingTimer?.cancel();
          setState(() {
            _waitingForMpesa = false;
            _error = 'Payment timed out. Please try again.';
          });
          return;
        }
        try {
          final status =
              await repo.getMpesaStatus(_checkoutRequestId!);
          if (status['status'] == 'success') {
            _pollingTimer?.cancel();
            ref.read(cartProvider.notifier).clear();
            if (mounted) {
              context.go('/order-status/${_orderId!}');
            }
          } else if (status['status'] == 'failed') {
            _pollingTimer?.cancel();
            setState(() {
              _waitingForMpesa = false;
              _error = 'Payment failed. Please try again.';
            });
          }
        } catch (_) {}
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...cart.map((ci) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ci.item.name} × ${ci.quantity}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                            Text(
                                'KES ${ci.subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
                      Text('KES ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!_waitingForMpesa) ...[
              // Phone input
              const Text('M-Pesa Phone Number',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '07XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style:
                          const TextStyle(color: AppColors.error)),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmAndPay,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.white)),
                        )
                      : const Text('Confirm & Pay via M-Pesa',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ] else ...[
              // Waiting for M-Pesa
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text(
                      'Check your phone',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'An M-Pesa prompt has been sent to ${_phoneController.text}.\nEnter your PIN to complete payment.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting... ${90 - _secondsElapsed}s',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
