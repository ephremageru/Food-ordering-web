/// A menu category. `glyph` selects which small food drawing the category puck
/// renders — see `art/category_glyph.dart`.
class Category {
  const Category({required this.id, required this.label, required this.glyph});

  final String id;
  final String label;
  final CategoryGlyph glyph;

  /// Order matters: this is the left-to-right order along the category arc,
  /// with `all` deliberately in the centre so it sits at the apex.
  static const List<Category> all = <Category>[
    Category(id: 'beef', label: 'Beef', glyph: CategoryGlyph.beef),
    Category(id: 'chicken', label: 'Chicken', glyph: CategoryGlyph.chicken),
    Category(id: 'all', label: 'All', glyph: CategoryGlyph.all),
    Category(id: 'cheese', label: 'Cheese', glyph: CategoryGlyph.cheese),
    Category(id: 'mushroom', label: 'Mushroom', glyph: CategoryGlyph.mushroom),
  ];
}

enum CategoryGlyph { beef, chicken, all, cheese, mushroom }
