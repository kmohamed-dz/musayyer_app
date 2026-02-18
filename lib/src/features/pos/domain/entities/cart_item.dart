import '../../../inventory/domain/entities/product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
