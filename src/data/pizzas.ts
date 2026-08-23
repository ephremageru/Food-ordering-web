import type { PizzaLook, ToppingKind } from '../art/Pizza'

export type CategoryId = 'all' | 'beef' | 'chicken' | 'cheese' | 'mushroom'

export type SizeId = 'small' | 'medium' | 'large'

export const SIZES: { id: SizeId; label: string; scale: number; priceFactor: number; diameter: number; slices: number }[] = [
  { id: 'small', label: 'Small', scale: 0.9, priceFactor: 0.85, diameter: 10, slices: 6 },
  { id: 'medium', label: 'Medium', scale: 1, priceFactor: 1, diameter: 12, slices: 8 },
  { id: 'large', label: 'Large', scale: 1.08, priceFactor: 1.25, diameter: 14, slices: 10 },
]

export type Extra = { id: string; label: string; price: number; icon: ToppingKind }

export const EXTRAS: Extra[] = [
  { id: 'cheese', label: 'Cheese', price: 0.75, icon: 'mozzarella' },
  { id: 'mushroom', label: 'Mushroom', price: 0.9, icon: 'mushroom' },
  { id: 'beef', label: 'Beef', price: 1.4, icon: 'beef' },
]

export type Pizza = {
  id: string
  name: string
  tagline: string
  price: number
  discount: number
  rating: number
  calories: number
  categories: CategoryId[]
  description: string
  look: PizzaLook
}

const CRUST = { crust: '#e6b26a', crustDeep: '#c8863c' }

export const PIZZAS: Pizza[] = [
  {
    id: 'pepperoni-classico',
    name: 'Pepperoni Classico',
    tagline: 'With Double Cheese',
    price: 8.99,
    discount: 25,
    rating: 4.8,
    calories: 285,
    categories: ['beef'],
    description:
      'Cured pepperoni over slow-cooked San Marzano sauce and a double layer of mozzarella, finished in a stone oven — at your door in 25 minutes.',
    look: { ...CRUST, base: '#c8412c', cheese: '#f2cf84', toppings: ['pepperoni', 'pepperoni', 'olive'], density: 14 },
  },
  {
    id: 'bianca-formaggi',
    name: 'Bianca Formaggi',
    tagline: 'Creamy White Sauce',
    price: 10.49,
    discount: 15,
    rating: 4.7,
    calories: 240,
    categories: ['cheese'],
    description:
      'Bianca Formaggi is hand-stretched and slow-proved for 24 hours, then finished in a stone oven — at your door in 25 minutes.',
    look: { ...CRUST, base: '#f4e6c8', cheese: '#fdf3dd', toppings: ['mozzarella', 'mushroom', 'mozzarella'], density: 15 },
  },
  {
    id: 'chicken-kebabi',
    name: 'Chicken Kebabi',
    tagline: 'Minced Chicken & Peppers',
    price: 12.75,
    discount: 10,
    rating: 4.6,
    calories: 310,
    categories: ['chicken'],
    description:
      'Charred kebab-spiced chicken with sweet peppers and red onion, over a garlic-herb base and a blanket of mozzarella.',
    look: { ...CRUST, base: '#d9633a', cheese: '#f3d494', toppings: ['chicken', 'pepper', 'onion'], density: 15 },
  },
  {
    id: 'chicken-rocket',
    name: 'Chicken Rocket',
    tagline: 'Rocket & Parmesan',
    price: 13.4,
    discount: 15,
    rating: 4.9,
    calories: 265,
    categories: ['chicken'],
    description:
      'Roast chicken and shaved parmesan under a handful of peppery rocket, dressed after the bake so the leaves stay bright.',
    look: { ...CRUST, base: '#efdcb8', cheese: '#fbeed0', toppings: ['chicken', 'rocket', 'rocket'], density: 14 },
  },
  {
    id: 'quattro-formaggi',
    name: 'Quattro Formaggi',
    tagline: 'Four Cheese Blend',
    price: 12.2,
    discount: 20,
    rating: 4.8,
    calories: 330,
    categories: ['cheese'],
    description:
      'Mozzarella, gorgonzola, fontina and parmesan melted into one another over a thin white base. Rich, and unapologetic about it.',
    look: { ...CRUST, base: '#f6ecd4', cheese: '#fefaef', toppings: ['mozzarella', 'mozzarella', 'olive'], density: 16 },
  },
  {
    id: 'pepperoni-doppio',
    name: 'Pepperoni Doppio',
    tagline: 'Double Beef Pepperoni',
    price: 14.6,
    discount: 10,
    rating: 4.7,
    calories: 360,
    categories: ['beef'],
    description:
      'Twice the pepperoni, cupped and crisped at the edges, with a hit of chilli honey brushed over the crust on the way out.',
    look: { ...CRUST, base: '#bd3a26', cheese: '#eec87c', toppings: ['pepperoni', 'beef', 'pepperoni'], density: 17 },
  },
  {
    id: 'tartufo-funghi',
    name: 'Tartufo Funghi',
    tagline: 'Truffle & Wild Mushroom',
    price: 13.9,
    discount: 15,
    rating: 4.9,
    calories: 295,
    categories: ['mushroom'],
    description:
      'Wild mushrooms and truffle cream over fior di latte, with thyme picked into the cheese before it goes in the oven.',
    look: { ...CRUST, base: '#e8dcc0', cheese: '#f7edd8', toppings: ['mushroom', 'mushroom', 'rocket'], density: 16 },
  },
  {
    id: 'funghi-crema',
    name: 'Funghi Crema',
    tagline: 'Mushroom & Garlic Cream',
    price: 11.3,
    discount: 20,
    rating: 4.5,
    calories: 275,
    categories: ['mushroom'],
    description:
      'Button and chestnut mushrooms folded through a slow-reduced garlic cream, then scattered with parsley and black pepper.',
    look: { ...CRUST, base: '#eee0c4', cheese: '#faf1de', toppings: ['mushroom', 'onion', 'mushroom'], density: 15 },
  },
  {
    id: 'manzo-piccante',
    name: 'Manzo Piccante',
    tagline: 'Spiced Beef & Chilli',
    price: 13.15,
    discount: 10,
    rating: 4.6,
    calories: 345,
    categories: ['beef'],
    description:
      'Spiced minced beef, roasted chilli and red onion over tomato — built for people who reach for the chilli oil anyway.',
    look: { ...CRUST, base: '#c04226', cheese: '#efc97f', toppings: ['beef', 'pepper', 'onion'], density: 16 },
  },
  {
    id: 'pollo-bianco',
    name: 'Pollo Bianco',
    tagline: 'Chicken & Ricotta',
    price: 12.4,
    discount: 15,
    rating: 4.7,
    calories: 300,
    categories: ['chicken', 'cheese'],
    description:
      'Lemon-thyme chicken with spoonfuls of ricotta and a white garlic base, finished with cracked pepper and olive oil.',
    look: { ...CRUST, base: '#f2e7cd', cheese: '#fdf6e6', toppings: ['chicken', 'mozzarella', 'rocket'], density: 15 },
  },
]

export const CATEGORIES: { id: CategoryId; label: string; icon: ToppingKind }[] = [
  { id: 'beef', label: 'Beef', icon: 'beef' },
  { id: 'chicken', label: 'Chicken', icon: 'chicken' },
  { id: 'all', label: 'All', icon: 'mozzarella' },
  { id: 'cheese', label: 'Cheese', icon: 'mozzarella' },
  { id: 'mushroom', label: 'Mushroom', icon: 'mushroom' },
]

export const byId = (id: string) => PIZZAS.find((p) => p.id === id)

export const filterByCategory = (cat: CategoryId) =>
  cat === 'all' ? PIZZAS : PIZZAS.filter((p) => p.categories.includes(cat))

/** Price for a given size + extras, matching what the detail screen shows. */
export function computeUnitPrice(pizza: Pizza, size: SizeId, extras: string[]) {
  const sz = SIZES.find((s) => s.id === size) ?? SIZES[1]
  const extrasTotal = extras.reduce((sum, id) => sum + (EXTRAS.find((e) => e.id === id)?.price ?? 0), 0)
  return Math.round((pizza.price * sz.priceFactor + extrasTotal) * 100) / 100
}
