import 'pizza.dart';

/// One configured line in the cart. Two entries of the same pizza with
/// different sizes or toppings are distinct lines, which is why the identity
/// key folds all three in.
class CartItem {
  CartItem({
    required this.pizza,
    required this.size,
    required this.toppings,
    this.quantity = 1,
  });

  final Pizza pizza;
  final PizzaSize size;
  final Set<String> toppings;
  int quantity;

  String get key {
    final List<String> sorted = toppings.toList()..sort();
    return '${pizza.id}|${size.name}|${sorted.join(",")}';
  }

  double get unitPrice => pizza.priceFor(size, toppings);
  double get lineTotal => unitPrice * quantity;
}
