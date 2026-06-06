import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cafeteria_repository.dart';
import '../data/cafeteria_models.dart';

final cafeteriaRepositoryProvider =
    Provider((ref) => CafeteriaRepository());

final categoriesProvider = FutureProvider<List<MenuCategory>>((ref) async {
  return ref.read(cafeteriaRepositoryProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final categoryId = ref.watch(selectedCategoryProvider);
  return ref.read(cafeteriaRepositoryProvider).getMenuItems(categoryId: categoryId);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item) {
    final index = state.indexWhere((ci) => ci.item.id == item.id);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(item: state[i].item, quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void removeItem(MenuItem item) {
    final index = state.indexWhere((ci) => ci.item.id == item.id);
    if (index < 0) return;
    if (state[index].quantity > 1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(item: state[i].item, quantity: state[i].quantity - 1)
          else
            state[i]
      ];
    } else {
      state = state.where((ci) => ci.item.id != item.id).toList();
    }
  }

  void clear() => state = [];

  double get total =>
      state.fold(0, (sum, ci) => sum + ci.subtotal);

  int quantityOf(int itemId) {
    final match = state.where((ci) => ci.item.id == itemId);
    return match.isEmpty ? 0 : match.first.quantity;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());
