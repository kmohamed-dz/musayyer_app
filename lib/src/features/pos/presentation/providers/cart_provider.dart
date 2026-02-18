import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => Cart(items: const []);

  void addProduct(Product product) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index == -1) {
      items.add(CartItem(product: product, quantity: 1));
    } else {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + 1);
    }

    state = state.copyWith(items: items);
  }

  void removeProduct(String productId) {
    final items = state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: items);
  }

  void updateQuantity(String productId, int qty) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      return;
    }

    if (qty <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: qty);
    }

    state = state.copyWith(items: items);
  }

  void clearCart() {
    state = Cart(items: const []);
  }
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);
