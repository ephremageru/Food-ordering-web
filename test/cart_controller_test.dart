import 'package:flutter_test/flutter_test.dart';
import 'package:pizzafy/models/menu_data.dart';
import 'package:pizzafy/models/pizza.dart';
import 'package:pizzafy/state/cart_controller.dart';

void main() {
  group('CartController', () {
    late CartController cart;
    setUp(() => cart = CartController());

    test('folds identical configurations into one line', () {
      cart.add(kMenu.first, PizzaSize.medium, <String>{}, 1);
      cart.add(kMenu.first, PizzaSize.medium, <String>{}, 2);
      expect(cart.items.length, 1);
      expect(cart.count, 3);
    });

    test('keeps different sizes as separate lines', () {
      cart.add(kMenu.first, PizzaSize.medium, <String>{}, 1);
      cart.add(kMenu.first, PizzaSize.large, <String>{}, 1);
      expect(cart.items.length, 2);
    });

    test('treats topping order as irrelevant to identity', () {
      cart.add(kMenu.first, PizzaSize.medium, <String>{'cheese', 'beef'}, 1);
      cart.add(kMenu.first, PizzaSize.medium, <String>{'beef', 'cheese'}, 1);
      expect(cart.items.length, 1, reason: 'topping sets must compare unordered');
    });

    test('decrementing the last unit removes the line', () {
      cart.add(kMenu.first, PizzaSize.medium, <String>{}, 1);
      cart.decrement(cart.items.first);
      expect(cart.isEmpty, isTrue);
    });

    test('size and toppings both move the price', () {
      final Pizza p = kMenu.first;
      final double base = p.priceFor(PizzaSize.medium, <String>{});
      expect(p.priceFor(PizzaSize.large, <String>{}), greaterThan(base));
      expect(p.priceFor(PizzaSize.small, <String>{}), lessThan(base));
      expect(
        p.priceFor(PizzaSize.medium, <String>{'beef'}),
        closeTo(base + 2.40, 0.001),
      );
    });

    test('placing an order empties the cart and records history', () {
      cart.add(kMenu.first, PizzaSize.medium, <String>{}, 2);
      final double expected = cart.total;
      final PlacedOrder order = cart.placeOrder();
      expect(cart.isEmpty, isTrue);
      expect(cart.orders.length, 1);
      expect(order.itemCount, 2);
      expect(order.total, closeTo(expected, 0.001));
    });

    test('an empty cart has no delivery, tax or promo', () {
      expect(cart.total, 0);
      expect(cart.delivery, 0);
      expect(cart.tax, 0);
    });
  });
}
