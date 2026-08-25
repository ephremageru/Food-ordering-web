# Master Animation Specification

The brief that produced this app left section 39 as a placeholder —
`[PASTE THE MASTER ANIMATION SPECIFICATION HERE]` was never filled in. This
document is that section, reconstructed from the reference recording frame by
frame at 30fps, and it is what the implementation was built against.

Where the brief stated an exact value (650ms, 150ms, stiffness 250 / damping 25,
scales 0.94 / 1.00 / 1.06) that value is used verbatim. Where the recording and
the brief disagree, the disagreement is called out below with the reasoning for
which one won.

Every number here lives in exactly one place in the code:
`lib/animations/animation_constants.dart`.

---

## 1. The spring

```
mass 1.0   stiffness 250   damping 25
```

Critical damping for this system is `2 × √(k·m)` = 31.62, so a damping of 25
gives a damping ratio of **≈0.79** — underdamped. One small overshoot, then a
quick settle. That single overshoot is the entire reason to use a spring here;
if it is ever tuned away, the motion is an ease wearing a costume. There is a
test (`test/motion_test.dart`) that fails if the curve stops overshooting.

Reached two ways:

| Need | Mechanism |
|---|---|
| Implicit animations (`AnimatedScale`, `AnimatedContainer`, `AnimatedPositioned`) | `SpringCurve` — the simulation is run once and sampled into a 240-entry lookup table |
| Interruptible, gesture-driven motion | `SpringDriver.to()` → `AnimationController.animateWith(SpringSimulation)`, which carries velocity across an interruption |

The distinction matters. A curve cannot preserve velocity, so a button released
mid-press would restart from rest and "catch". The press control uses the real
simulation for exactly that reason.

Two derived springs exist: `heavy` (mass 1.4, damping 28) for large surfaces,
and `pop` (mass 0.7, stiffness 320, damping 22) for the badge, where an
oscillation would read as a glitch.

## 2. Timing table

| Token | Value | Used by |
|---|---|---|
| `fast` | 150ms | press/release, opacity swaps |
| `quick` | 200ms | quantity roll, chip selection, badge digit |
| `normal` | 280ms | page fades, indicator travel, grid reflow |
| `medium` | 400ms | detail entrance, size change, number roll |
| `hero` | 520ms | home ↔ detail shared element |
| `cartFlight` | **650ms** | add-to-cart pizza flight |
| `buttonMorph` | 320ms | add-to-cart button collapse |
| `ringDraw` / `checkDraw` | 520 / 420ms | success seal |
| `staggerTight` / `staggerNormal` | 35 / 55ms | entrance choreography step |

## 3. Curves

No single curve is reused everywhere; each encodes a different intent.

| Curve | Cubic | Intent |
|---|---|---|
| `Ease.out` | `(0.05, 0.7, 0.1, 1.0)` | anything arriving or settling |
| `Ease.exit` | `(0.3, 0.0, 0.8, 0.15)` | anything leaving — exits are faster than entrances |
| `Ease.standard` | `(0.2, 0.0, 0.0, 1.0)` | moving between two resting states |
| `Ease.flight` | `(0.42, 0.0, 0.18, 1.0)` | the cart flight: accelerates off, decelerates in |

## 4. Route transitions

Five, not one. The transition tells you what kind of navigation happened before
you have read anything on the new screen.

| Route | Motion | Used for |
|---|---|---|
| `morphRoute` | fade + scale 0.965→1.0, non-opaque | Home → Detail. The hero carries continuity; the page only clears the stage |
| `pushRoute` | slide 16%→0 in, outgoing recedes 8% | Cart → Checkout: deeper into a flow |
| `riseRoute` | y 100%→0 on `Springs.heavy` | a surface arriving over the current one |
| `dissolveRoute` | fade + scale 1.02→1.0, **no translation** | sibling tabs — a slide would imply an order they do not have |
| `revealRoute` | fade + scale 1.06→1.0 | Onboarding → App, Success → Orders: full context replacement |

## 5. Home → Detail hero

- Tag: `pizza-${pizza.id}`, exactly one `Hero` per pizza anywhere in the tree.
- `createRectTween` → **`SpringArcRectTween`**, which does two things Flutter's
  default does not:
  1. The **centre travels along an arc** (perpendicular bulge, `sin(πt)`, capped
     at 90px) rather than a straight line, so a pizza moving up-and-across
     sweeps instead of sliding diagonally.
  2. The parameter is passed through `SpringCurve`, so the flight carries the
     specified spring character instead of easing to a dead stop.
- **Size interpolates on `Ease.out` while position interpolates on the spring.**
  Reaching final size slightly before final position is what makes the pizza
  look like it is landing rather than being scaled by a separate process.
- `flightShuttleBuilder` renders on a transparent `Material` so the shuttle
  never picks up a card background or text underline mid-flight.

The artwork is seeded deterministically (`Pizza.toppingSeed`) so the same pizza
draws identically at both ends of the flight. A re-randomised topping scatter
would visibly reshuffle mid-flight and destroy the illusion of one object.

## 6. Card press

`1.0 → 0.96` over 150ms. Press is a tween (the finger is driving it and it must
land inside the budget); **release is a spring** seeded with the controller's
current velocity, so a fast tap stays fluid instead of catching.

## 7. Size selection

Scales are specified exactly: **small 0.94, medium 1.00, large 1.06**, applied
via `AnimatedScale` on `Ease.spring` over `medium`. Only the pizza, the price,
and the diameter/portion line rebuild — the surrounding page does not.

## 8. The add-to-cart flight — 650ms

This is the signature interaction, and the recording shows something more
specific than "pizza flies to a cart icon":

1. The page **blurs and fades** (`ImageFilter.blur` 0→9σ, opacity 1→0.15) while
   the pizza and the button stay sharp — the thing moving and the thing it is
   aimed at.
2. The pizza is lifted into an `OverlayEntry` so it can cross the whole screen
   without being clipped by the scroll view it started in.
3. It travels a **quadratic Bézier arc**, control point perpendicular to the
   line of travel, bowed upward, magnitude `min(distance × 0.42, 190)`.
4. Scale is a **`TweenSequence`, not a single tween**: `1.0 → 1.12 → 0.55 →
   (target/source)` at weights 18 / 46 / 36. The initial *growth* is what makes
   it read as thrown rather than shrunk.
5. Opacity holds at 1.0 for 82% of the flight, then extinguishes — the pizza is
   absorbed, not faded out en route.
6. Rotation: 0.55rad for long flights, 0.3rad for short ones. Enough to tumble,
   not enough to look like a spinner.
7. On arrival the cart model is updated and the destination reacts.

**Two destinations, deliberately:**

| Origin | Destination | Why |
|---|---|---|
| Home grid "+" | header cart icon | matches brief §17–20, including badge and icon bump |
| Detail "Add to cart" | the **bag icon inside the button** | this is what the recording actually shows |

On the detail screen the button then collapses from a full-width pill to a
58px circle over 320ms and swaps its bag for a tick — the button getting out of
the way is what makes the bag read as a target rather than decoration.

**Deviation from the recording, stated:** the recorded flight runs ≈1.2s. The
brief specifies 650ms and says so emphatically. 650ms is used, on the reading
that the recording is a debug build on an iOS simulator, where Flutter runs
materially slower than release.

## 9. Cart icon response

`1.0 → 1.15 → 1.0`, as specified. Out on `Ease.out` over 150ms, back on
`Springs.pop`. **Triggered by the flight's arrival callback, not by the count
changing** — so the reaction lands on the same frame the pizza disappears rather
than a beat later.

Badge: 0→1 pops the whole badge in on a spring; 1→2 rolls only the digit. Two
different events must not look like the same thing.

## 10. Category arc

Pucks sit on a **parabola**, not a row: `drop = 46·u²`, `scale = 1 − 0.26·|u|`
for `u ∈ [−1, 1]`. The outermost items bleed past the screen edge, so the strip
reads as a curved surface receding at the sides.

Selection is communicated three ways simultaneously — puck scales to 1.14, label
goes bold and dark, and a 26×3.5 bar **travels** along the arc to the new label
on `Ease.spring` over `medium`. The bar is never removed and re-added; a bar
that reappears elsewhere tells you the selection changed but not where from.

Filtering: `AnimatedSwitcher` over the grid keyed by category — outgoing fades
and lifts 4%, incoming fades in. No hard refresh.

## 11. Quantity

`AnimatedSwitcher` at 200ms, sliding **in the direction of the change**:
incrementing pushes the old digit up and brings the new one in from below,
decrementing reverses it. A cross-fade would say the number changed but not
which way — which is the only thing the control exists to communicate.

## 12. Cart removal

Four simultaneous parts, all required: fade, scale to 0.9, **height collapse**
(`Align.heightFactor`), and the rows below sliding up. Dropping the height
collapse is what makes most "animated" list removals still feel like a jump —
the row fades out smoothly and then the list below it teleports.

The row animates out *before* it is removed from the model, so the collapse can
finish.

## 13. Checkout

Sections stagger in at 55ms steps. Payment selection animates border, fill and a
spring-popped check indicator together.

The pay button's **size is pinned across idle and processing**. A button that
resizes when it starts working shifts its neighbours at the exact moment the
user is watching for confirmation.

Totals are **snapshotted when payment begins**. Placing the order empties the
cart while this screen is still visible and animating out; without the snapshot
every figure rolls toward zero in front of the user, which reads as the order
being cancelled at the moment it succeeded.

## 14. Success seal

One `AnimationController` (1900ms) with `Interval`s, not a chain of delayed
futures — if the screen is disposed halfway through, one controller stops
cleanly while pending timers keep firing into a dead tree.

| Phase | Interval | Curve |
|---|---|---|
| circle pops in | 0.00–0.16 | `springPop` |
| ring sweeps 0→360° | 0.10–0.44 | `Ease.out` |
| tick draws | 0.44–0.68 | `Ease.out` |
| title | 0.60–0.76 | `Ease.out` |
| order meta | 0.68–0.84 | `Ease.out` |
| actions | 0.78–1.00 | `Ease.out` |

The tick must not begin before the ring closes, or the two strokes read as one
scribble instead of a seal being stamped.

The tick is a genuine path traversal via `PathMetric.extractPath`, not two lines
revealed by a clip. That gives it a moving stroke head with a correct round cap;
a clipped tick shows a squared-off leading edge at any size above ~40px.

## 15. Bottom navigation

The active orange pill **slides** between destinations on `Ease.spring`. The bar
itself slides down and fades out whenever the active tab's navigator has a
pushed route, so detail, cart and checkout own the bottom of the display.

## 16. Reduced motion

`MediaQuery.disableAnimations` is honoured at every level, and honoured by
*removing* motion rather than speeding it up:

- Routes collapse to a short cross-fade.
- The cart flight is **skipped entirely** — a fast arc is still a flying object
  crossing the screen.
- Press feedback is disabled rather than shortened.
- Staggered entrances and the success sequence jump to their end state.
