import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/cafeteria_provider.dart';
import '../data/cafeteria_models.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;
    final freshStockAsync = ref.watch(cartStockCheckProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            )
          : freshStockAsync.when(
              loading: () => _CartBody(
                cart: cart,
                total: total,
                stockByItemId: null,
                ref: ref,
              ),
              error: (_, __) => _CartBody(
                cart: cart,
                total: total,
                stockByItemId: null,
                ref: ref,
              ),
              data: (items) {
                final stockByItemId = <int, MenuItem>{
                  for (final m in items) m.id: m,
                };
                return _CartBody(
                  cart: cart,
                  total: total,
                  stockByItemId: stockByItemId,
                  ref: ref,
                );
              },
            ),
    );
  }
}

class _CartBody extends StatelessWidget {
  final List<CartItem> cart;
  final double total;
  final Map<int, MenuItem>? stockByItemId;
  final WidgetRef ref;

  const _CartBody({
    required this.cart,
    required this.total,
    required this.stockByItemId,
    required this.ref,
  });

  String? _stockWarning(CartItem ci) {
    if (stockByItemId == null) return null;
    final fresh = stockByItemId![ci.item.id];
    if (fresh == null) return null;
    if (!fresh.isAvailable) {
      return '${ci.item.name} is no longer available';
    }
    if (fresh.effectiveStock < 999 && ci.quantity > fresh.effectiveStock) {
      if (fresh.effectiveStock <= 0) {
        return '${ci.item.name} just sold out';
      }
      return 'Only ${fresh.effectiveStock} left — reduce quantity';
    }
    return null;
  }

  bool get _hasBlockingIssue =>
      cart.any((ci) => _stockWarning(ci) != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.length,
            itemBuilder: (_, i) {
              final ci = cart[i];
              final warning = _stockWarning(ci);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: warning != null
                      ? Border.all(color: AppColors.error.withOpacity(0.4))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ci.item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              Text(
                                  'KES ${ci.item.price.toStringAsFixed(0)} × ${ci.quantity}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(
                          'KES ${ci.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ref
                                  .read(cartProvider.notifier)
                                  .removeItem(ci.item),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.border),
                                    borderRadius:
                                        BorderRadius.circular(6)),
                                child: const Icon(Icons.remove, size: 14),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text('${ci.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            GestureDetector(
                              onTap: () => ref
                                  .read(cartProvider.notifier)
                                  .addItem(ci.item),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.circular(6)),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (warning != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warning_rounded,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              warning,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (_hasBlockingIssue) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Some items in your cart are no longer available in the quantity you selected. Please adjust before checking out.',
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Text(
                      'KES ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _hasBlockingIssue
                        ? null
                        : () => context.push('/checkout'),
                    child: const Text('Proceed to Checkout',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
