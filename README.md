# Pizzafy

A pizza-ordering web app built animation-first, reproducing the motion language of
the supplied iOS reference recording rather than its screenshots.

React 18 · TypeScript · Vite · Framer Motion. No runtime dependencies beyond those,
and no external image assets — every pizza is drawn as SVG.

```bash
npm install
npm run dev      # http://localhost:5173
npm run build
```

Under 760px the app runs full-bleed. Above it, it renders inside a device frame,
because the whole motion system is designed for a handheld surface.

---

## The motion system comes first

Everything is built on `src/motion/`. Screens never inline durations or easings.

**`tokens.ts`** — the single source of timing.

| | |
|---|---|
| `DUR` | `fast` 160ms · `quick` 220ms · `normal` 300ms · `medium` 400ms · `large` 560ms |
| `EASE` | `out` (the workhorse — strong deceleration), `standard`, `inOut`, `in`, `snap` |
| `SPRING` | `soft` (layout), `snappy` (controls), `pop` (badges, checkmarks), `hero` (shared element), `sheet`, `counter` |
| `STAGGER` | `tight` 35ms · `normal` 50ms · `relaxed` 70ms |

Springs for anything physical — buttons, indicators, the pizza, sheets, counters.
Tweens for opacity, colour, and page-level fades. Nothing runs for a second or more.

**`variants.ts`** — six page transitions, not one reused everywhere, because each
navigation context means something different:

- `push` / `pop` — deeper into or back out of a flow; the mirror image of each other
- `modal` — a sheet rising over the current screen
- `dissolve` — sibling tabs, which make no spatial claim on each other
- `morph` — a shared element carries the continuity, so the page only clears the stage
- `reveal` — onboarding handing off to the app

**Primitives** — `AnimatedNumber` (spring counter that writes straight to the DOM so a
changing total never re-renders the tree around it), `Pressable`, `StaggerGroup` /
`StaggerItem`, `Sheet` (bottom sheet on touch with drag-to-dismiss, centred modal on
pointer devices), `Toast`.

---

## What each transition does

| Interaction | Motion |
|---|---|
| Onboarding | Ingredients fall into a cone above the pizza and settle, then headline → subtitle → button |
| Get Started → Home | Onboarding scales up and blurs away; Home assembles beneath it |
| Home entry | header → greeting → search → categories → cards, ~35ms apart |
| Category change | The indicator travels along the arc; the grid reflows with `AnimatePresence` instead of rebuilding |
| Card → Detail | **Shared element**: the pizza flies from the card to the hero slot, opaque and sharp the whole way, while the rest of Home fades and blurs behind it |
| Detail entry | Title → rating → price → calories → diameter → size → toppings → description, staggered *after* the pizza is already moving |
| Size change | Pizza springs to 0.9 / 1 / 1.08; price, calories and portion all count to their new values |
| Topping | Chip pops, checkmark scales in from 0, the price appears without shifting the layout |
| Add to cart | Pizza shrinks into the button → the pill collapses to a disc → the cart takes over |
| Cart edits | Removals collapse their own height and the rows below spring up; only the affected numbers move |
| Cart → Checkout | Native-style push |
| Payment | Width-stable button: `Pay Now` → spinner + `Processing…`, so nothing jumps |
| Success | Ring draws by `strokeDashoffset`, checkmark draws by `pathLength`, then a single radial burst |
| Orders | The progress line fills from 0 to the order's current stage |
| Tabs | The active pill travels between tabs; the icon pops on arrival |

---

## Notes on the implementation

**The shared element.** `layoutId={`pizza-${id}`}` on a square SVG in a square box, so
scaling is distortion-free. `HeroFlightProvider` tracks which pizza owns the slot, and
the source card yields its copy in the same commit that mounts the destination — that
single commit is what gives the layout animation a start and an end to measure. The
`morph` variant deliberately does not fade the screen; a separate backdrop layer fades
underneath instead, because a page-level opacity animation would drag the shared
element's opacity down with it and turn one object back into two pictures.

**Moving indicators are single elements.** The category underline, the size pill and
the tab pill each animate with `layout` rather than swapping a `layoutId` between a
hidden and a shown copy — the shared-id version leaves a pending projection behind that
stalls the owning screen's own exit animation.

**Pizzas are procedural SVG.** `src/art/Pizza.tsx` seeds a PRNG from the pizza id, so a
pizza is byte-identical everywhere it appears; anything less and the shared-element
transition would visibly re-roll its toppings mid-flight. Crust outlines are closed
Catmull-Rom beziers so they stay smooth from a 96px thumbnail to a 240px hero.

**Performance.** Animations are transform and opacity. Blur is used only on layers that
are static while they blur, never during continuous movement.

**Reduced motion.** `<MotionConfig reducedMotion="user">` neutralises transform
animations globally, and decorative motion — floating ingredients, the success burst,
count-ups, the tracking fill — opts out explicitly via `useReducedMotionPref`. The full
purchase flow was verified end to end with `prefers-reduced-motion: reduce`.

---

## Structure

```
src/
  motion/     tokens, page variants, reduced-motion hooks, animation primitives
  nav/        history-synced navigation stack; Screen applies the transition
  art/        procedural pizza SVG, onboarding hero scene, icons
  state/      cart/orders/favourites store, shared-element flight tracking
  screens/    Onboarding, Home, ProductDetail, Cart, Checkout, Success, Orders, tabs
  components/ CategoryArc, PizzaCard, BottomNav
```
