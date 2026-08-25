import 'dart:ui';

/// The three sizes, with the scale each one applies to the pizza artwork.
/// The scales are specified: 0.94 / 1.00 / 1.06.
enum PizzaSize {
  small('Small', 0.94, 0.85, 10, 6),
  medium('Medium', 1.00, 1.00, 12, 8),
  large('Large', 1.06, 1.25, 14, 10);


  const PizzaSize(this.label, this.scale, this.priceFactor, this.inches, this.slices);

  final String label;

  /// Scale applied to the hero artwork when this size is selected.
  final double scale;

  /// Multiplier on the base price.
  final double priceFactor;

  final int inches;
  final int slices;
}

class Topping {
  const Topping({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  static const List<Topping> all = <Topping>[
    Topping(id: 'cheese', name: 'Cheese', price: 1.20),
    Topping(id: 'mushroom', name: 'Mushroom', price: 1.50),
    Topping(id: 'beef', name: 'Beef', price: 2.40),
  ];
}

/// A pizza. `crust`, `sauce`, `cheese` and `toppingSeed` drive the procedural
/// artwork in `art/pizza_painter.dart`, so every pizza is drawn rather than
/// shipped as a bitmap.
class Pizza {
  const Pizza({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.discount,
    required this.rating,
    required this.calories,
    required this.categoryId,
    required this.sauce,
    required this.cheese,
    required this.toppingSeed,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final double price;

  /// Percentage off, shown in the dark badge on the card.
  final int discount;

  final double rating;
  final int calories;
  final String categoryId;

  /// Base sauce colour showing between the cheese.
  final Color sauce;

  /// Melted cheese colour.
  final Color cheese;

  /// Seeds the deterministic topping scatter, so a given pizza always draws
  /// identically — including across a hero flight, where a re-randomised
  /// scatter would break the illusion of continuity.
  final int toppingSeed;

  double priceFor(PizzaSize size, Set<String> toppings) {
    double total = price * size.priceFactor;
    for (final Topping t in Topping.all) {
      if (toppings.contains(t.id)) {
        total += t.price;
      }
    }
    return total;
  }
}
