import 'cart_item.dart';

class Cart {
  Cart({required this.items});

  final List<CartItem> items;

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }
}
