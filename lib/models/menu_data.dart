import 'dart:ui';

import 'pizza.dart';

/// The menu. Sauce and cheese colours feed the procedural artwork, so varying
/// them is what stops twelve drawn pizzas looking like one pizza twelve times.
const List<Pizza> kMenu = <Pizza>[
  Pizza(
    id: 'pepperoni-classico',
    name: 'Pepperoni Classico',
    tagline: 'With Double Cheese',
    description:
        'Cured pepperoni over a slow-cooked San Marzano base, finished with '
        'fior di latte and a scatter of oregano. Baked at 430°C for 90 seconds.',
    price: 8.99,
    discount: 25,
    rating: 4.8,
    calories: 285,
    categoryId: 'beef',
    sauce: Color(0xFFC0391F),
    cheese: Color(0xFFF2D89B),
    toppingSeed: 1201,
  ),
  Pizza(
    id: 'bianca-formaggi',
    name: 'Bianca Formaggi',
    tagline: 'Creamy White Sauce',
    description:
        'Bianca Formaggi is hand-stretched and slow-proved for 24 hours, then '
        'finished in a stone oven — at your door in 25 minutes.',
    price: 10.49,
    discount: 15,
    rating: 4.7,
    calories: 240,
    categoryId: 'cheese',
    sauce: Color(0xFFD9B571),
    cheese: Color(0xFFF3DFA6),
    toppingSeed: 3312,
  ),
  Pizza(
    id: 'quattro-formaggi',
    name: 'Quattro Formaggi',
    tagline: 'Four Cheese Blend',
    description:
        'Gorgonzola, fontina, parmigiano and mozzarella melted over a thin '
        'white base. Rich, salty, and best eaten immediately.',
    price: 12.20,
    discount: 20,
    rating: 4.9,
    calories: 310,
    categoryId: 'cheese',
    sauce: Color(0xFFD3AC66),
    cheese: Color(0xFFF6E3AC),
    toppingSeed: 7781,
  ),
  Pizza(
    id: 'truffle-mushroom',
    name: 'Truffle Mushroom',
    tagline: 'Wild Forest Blend',
    description:
        'Chestnut and oyster mushrooms with black truffle cream, thyme and a '
        'finish of aged pecorino.',
    price: 11.25,
    discount: 20,
    rating: 4.6,
    calories: 265,
    categoryId: 'mushroom',
    sauce: Color(0xFFC2A377),
    cheese: Color(0xFFEDD9A8),
    toppingSeed: 4457,
  ),
  Pizza(
    id: 'wild-mushroom',
    name: 'Wild Mushroom',
    tagline: 'Garlic & Thyme',
    description:
        'Slow-roasted field mushrooms, confit garlic and thyme over mozzarella, '
        'with a crack of black pepper.',
    price: 11.90,
    discount: 10,
    rating: 4.5,
    calories: 258,
    categoryId: 'mushroom',
    sauce: Color(0xFFB89A70),
    cheese: Color(0xFFEAD5A2),
    toppingSeed: 9014,
  ),
  Pizza(
    id: 'chicken-kebabi',
    name: 'Chicken Kebabi',
    tagline: 'Spiced Charred Chicken',
    description:
        'Shish-spiced chicken thigh, charred peppers and sumac onions over a '
        'light tomato base with a garlic drizzle.',
    price: 12.75,
    discount: 15,
    rating: 4.7,
    calories: 330,
    categoryId: 'chicken',
    sauce: Color(0xFFC4502A),
    cheese: Color(0xFFF3DFAA),
    toppingSeed: 6620,
  ),
  Pizza(
    id: 'chicken-rocket',
    name: 'Chicken Rocket',
    tagline: 'Rocket & Parmesan',
    description:
        'Grilled chicken, wild rocket and shaved parmesan, dressed with lemon '
        'oil after the bake so the leaves stay bright.',
    price: 13.40,
    discount: 10,
    rating: 4.6,
    calories: 295,
    categoryId: 'chicken',
    sauce: Color(0xFFCC5A2E),
    cheese: Color(0xFFF4E1AF),
    toppingSeed: 2288,
  ),
  Pizza(
    id: 'pepperoni-doppio',
    name: 'Pepperoni Doppio',
    tagline: 'Twice The Pepperoni',
    description:
        'Double-layered pepperoni that cups and crisps in the oven, over a '
        'sweet tomato base and a heavy blanket of mozzarella.',
    price: 14.60,
    discount: 20,
    rating: 4.9,
    calories: 380,
    categoryId: 'beef',
    sauce: Color(0xFFBE3620),
    cheese: Color(0xFFF1D593),
    toppingSeed: 5150,
  ),
];

List<Pizza> menuFor(String categoryId) => categoryId == 'all'
    ? kMenu
    : kMenu.where((Pizza p) => p.categoryId == categoryId).toList();
