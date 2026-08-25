import 'package:flutter/widgets.dart';

import '../models/cart_item.dart';
import '../models/pizza.dart';

/// Cart state, deliberately kept free of any widget or animation concern.
///
/// Screens listen to this; nothing here knows that a pizza flies across the
/// screen when something is added. The flight is triggered by the widget that
/// owns the gesture, and this controller is updated when the flight lands —
/// which is what keeps the badge count and the arriving pizza in sync.
class CartController extends ChangeNotifier {
  final List<CartItem> _items = <CartItem>[];
  final Set<String> _favourites = <String>{};
  final List<PlacedOrder> _orders = <PlacedOrder>[];

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  List<PlacedOrder> get orders => List<PlacedOrder>.unmodifiable(_orders);

  int get count => _items.fold(0, (int sum, CartItem i) => sum + i.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0.0, (double sum, CartItem i) => sum + i.lineTotal);

  double get delivery => _items.isEmpty ? 0 : 2.50;
  double get promo => _items.isEmpty ? 0 : 2.20;
  double get tax => _items.isEmpty ? 0 : 2.00;
  double get total => subtotal + delivery + tax - promo;

  void add(Pizza pizza, PizzaSize size, Set<String> toppings, int quantity) {
    final CartItem incoming = CartItem(
      pizza: pizza,
      size: size,
      toppings: Set<String>.from(toppings),
      quantity: quantity,
    );
    final int existing = _items.indexWhere((CartItem i) => i.key == incoming.key);
    if (existing >= 0) {
      _items[existing].quantity += quantity;
    } else {
      _items.add(incoming);
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  /// Decrementing past one removes the line, so the cart screen can animate a
  /// collapse rather than leaving a zero-quantity row behind.
  void decrement(CartItem item) {
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool isFavourite(String pizzaId) => _favourites.contains(pizzaId);

  void toggleFavourite(String pizzaId) {
    if (!_favourites.remove(pizzaId)) {
      _favourites.add(pizzaId);
    }
    notifyListeners();
  }

  /// Moves the cart into order history and empties it.
  PlacedOrder placeOrder() {
    final PlacedOrder order = PlacedOrder(
      reference: 'PZ-${1000 + _orders.length + 42}',
      items: List<CartItem>.from(_items),
      total: total,
      placedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _items.clear();
    notifyListeners();
    return order;
  }
}

class PlacedOrder {
  const PlacedOrder({
    required this.reference,
    required this.items,
    required this.total,
    required this.placedAt,
  });

  final String reference;
  final List<CartItem> items;
  final double total;
  final DateTime placedAt;

  int get itemCount => items.fold(0, (int s, CartItem i) => s + i.quantity);
}

/// Inherited access to the single [CartController].
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({super.key, required CartController controller, required super.child})
      : super(notifier: controller);

  static CartController of(BuildContext context) {
    final CartScope? scope =
        context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope is missing from the widget tree');
    return scope!.notifier!;
  }

  /// Reads the controller without subscribing — for callbacks that mutate the
  /// cart but should not rebuild when it changes.
  static CartController read(BuildContext context) {
    final CartScope? scope =
        context.getInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope is missing from the widget tree');
    return scope!.notifier!;
  }
}
