# Pizzafy

An animation-first pizza ordering app in Flutter, built to match the motion of a
reference recording rather than just its layout.

The recording is a screen capture of an iOS simulator running a Flutter app.
Every timing, easing and spring value here was derived from it frame by frame at
30fps, and the reconstruction is written up in
**[`docs/MASTER_ANIMATION_SPEC.md`](docs/MASTER_ANIMATION_SPEC.md)** — that
document is the source of truth for the motion, and this README is the map.

## Running it

```bash
flutter pub get
flutter run                 # any connected device or simulator
flutter run -d chrome       # web
flutter test                # 17 unit tests
```

There are no third-party dependencies. Everything — the springs, the arc
flights, the path-drawn checkmark, and all of the pizza artwork — is built on
Flutter's own animation and painting APIs.

## What is worth looking at

| Interaction | Where |
|---|---|
| Spring-driven hero arc, home → detail | `lib/animations/hero_transitions.dart` |
| 650ms add-to-cart flight over a Bézier arc | `lib/animations/cart_flight.dart` |
| The spring, as a `Curve` and as a live simulation | `lib/animations/motion_curves.dart` |
| Five distinct route transitions | `lib/animations/page_transitions.dart` |
| Category arc with a travelling indicator | `lib/widgets/category_selector.dart` |
| Path-drawn success checkmark | `lib/screens/success_screen.dart` |
| Procedural pizza artwork | `lib/art/pizza_painter.dart` |

## Three decisions worth knowing about

**The spring is real.** `stiffness: 250, damping: 25, mass: 1` is underdamped
(ratio ≈0.79), so it overshoots once and settles. Widgets that only accept a
curve get `SpringCurve`, which samples an actual `SpringSimulation` into a
lookup table. Gesture-driven motion instead drives an `AnimationController` with
the simulation directly, so releasing a press mid-animation carries its velocity
across rather than restarting from rest. A test fails if the curve ever stops
overshooting.

**The pizzas are drawn, not shipped.** Every pizza is a `CustomPainter` — crust
gradient, charred blisters, mottled cheese, cupped pepperoni, basil. The scatter
is seeded from the pizza's id, which matters more than it sounds: during a hero
flight the same pizza is painted at two sizes on two screens, and a re-randomised
scatter would visibly reshuffle mid-flight and break the illusion that it is one
object. It also means there are no image assets and no decode cost.

**There is no default transition.** Five routes exist because five kinds of
navigation happen. Tabs cross-fade with no translation, because a slide would
imply an order the destinations do not have. Going deeper into checkout slides
and pushes the previous screen back. Home → detail barely animates the page at
all, because the hero is carrying the continuity and the page should get out of
its way.

## Structure

```
lib/
  animations/   motion constants, curves, springs, routes, hero, cart flight
  art/          procedural pizza and category-glyph painters
  models/       pizza, category, cart item, menu data
  screens/      onboarding, home, detail, cart, checkout, success, orders, shell
  state/        cart controller, flight anchor registry
  theme/        palette, radii, shadows, typography
  widgets/      pressable, quantity, cart button, category arc, card, nav, stagger
```

Animation code is reusable and lives in `animations/`; no screen inlines a
duration or a curve.

## Accessibility

Reduced motion is honoured by removing motion, not by speeding it up — the cart
flight is skipped entirely rather than run fast, routes collapse to a cross-fade,
and the success sequence jumps to its end state. Touch targets are at least
44×44 regardless of drawn size, and every control carries a semantic label.

## Verification

Built for web and driven in a real browser through the full flow — onboarding,
category filtering, hero, size and topping selection, the cart flight, cart,
checkout, payment, success and orders — at phone, tablet and desktop widths,
with video capture used to confirm the flight, the category indicator and the
checkmark actually animate rather than cutting to their end states. Zero console
or page errors across those runs.

On windows wider than 760px the app renders inside a phone-shaped frame: the
motion system is calibrated to a handheld aspect ratio, and stretching it would
change the arcs and put the navigation out of thumb reach.
