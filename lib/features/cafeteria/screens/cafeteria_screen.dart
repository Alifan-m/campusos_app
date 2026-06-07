import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/cafeteria_provider.dart';
import '../data/cafeteria_models.dart';

class CafeteriaScreen extends ConsumerWidget {
  const CafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final menuAsync = ref.watch(menuItemsProvider);
    final cartItems = ref.watch(cartProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final cartCount = cartItems.fold(0, (sum, ci) => sum + ci.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navBar,
            expandedHeight: 178,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.navBar,
                padding: const EdgeInsets.fromLTRB(20, 92, 60, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Menu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fresh meals prepared daily',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: AppColors.navBar,
                child: Column(
                  children: [
                    SizedBox(
                      height: 42,
                      child: categoriesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (categories) => ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          children: [
                            GestureDetector(
                              onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
                              child: _FilterChip(label: 'All', isSelected: selectedCategoryId == null),
                            ),
                            ...categories.map((cat) => GestureDetector(
                              onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat.id,
                              child: _FilterChip(label: cat.name, isSelected: selectedCategoryId == cat.id),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: menuAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_outlined, size: 52, color: AppColors.outline),
                const SizedBox(height: 14),
                const Text('Could not load menu',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15)),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => ref.refresh(menuItemsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) {
            final available = items.where((i) => i.isAvailable).toList();
            if (available.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food_rounded, size: 52, color: AppColors.outline),
                    SizedBox(height: 14),
                    Text('No items available',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: available.length,
              itemBuilder: (_, i) {
                final item = available[i];
                return _FoodCard(
                  item: item,
                  onAdd: () => ref.read(cartProvider.notifier).addItem(item),
                  onRemove: () => ref.read(cartProvider.notifier).removeItem(item),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: cartCount > 0
          ? GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'View Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _FoodCard extends ConsumerWidget {
  final MenuItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _FoodCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  IconData _categoryIcon(int catId) {
    switch (catId) {
      case 1: return Icons.free_breakfast_rounded;
      case 2: return Icons.lunch_dining_rounded;
      case 3: return Icons.local_cafe_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  Color _categoryColor(int catId) {
    switch (catId) {
      case 1: return const Color(0xFFF59E0B);
      case 2: return AppColors.primary;
      case 3: return AppColors.secondary;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = ref.watch(cartProvider.notifier).quantityOf(item.id);
    final catColor = _categoryColor(item.categoryId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: image or category badge
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            child: item.image != null && item.image!.isNotEmpty
                ? Image.network(
                    item.image!,
                    width: 100,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _CategoryBadge(
                      icon: _categoryIcon(item.categoryId),
                      color: catColor,
                    ),
                  )
                : _CategoryBadge(
                    icon: _categoryIcon(item.categoryId),
                    color: catColor,
                  ),
          ),

          // Right: details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KES ${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                      qty == 0
                          ? GestureDetector(
                              onTap: onAdd,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Add to order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                _QtyBtn(icon: Icons.remove, onTap: onRemove),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                _QtyBtn(icon: Icons.add, onTap: onAdd),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _CategoryBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      color: color.withOpacity(0.08),
      child: Icon(icon, color: color.withOpacity(0.6), size: 36),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 16, color: AppColors.secondary),
      ),
    );
  }
}
