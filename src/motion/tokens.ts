/**
 * Centralised motion constants.
 *
 * Every animation in the app pulls its timing from here so the whole interface
 * shares one motion language. Values were tuned against the reference
 * recording: fast, subtle, physical — never decorative.
 */
import type { Transition } from 'framer-motion'

/** Tween durations, in seconds. */
export const DUR = {
  /** 160ms — presses, hovers, colour changes. */
  fast: 0.16,
  /** 220ms — small element enter/exit. */
  quick: 0.22,
  /** 300ms — standard content transitions. */
  normal: 0.3,
  /** 400ms — page-level pushes. */
  medium: 0.4,
  /** 560ms — the big choreographed moments (screen morphs). */
  large: 0.56,
} as const

/**
 * Easing curves. `out` is the workhorse: a strong deceleration that reads as
 * "the interface caught up with you instantly", which is what makes native
 * transitions feel responsive.
 */
export const EASE = {
  out: [0.16, 1, 0.3, 1],
  inOut: [0.65, 0, 0.35, 1],
  in: [0.55, 0, 1, 0.45],
  /** Material-ish standard curve, good for position + opacity together. */
  standard: [0.4, 0, 0.2, 1],
  /** Very sharp deceleration for elements that must land immediately. */
  snap: [0.2, 0, 0, 1],
} as const

/** Spring presets. Moderate stiffness + damping — settle without wobble. */
export const SPRING = {
  /** General purpose: cards, layout shifts, list reflow. */
  soft: { type: 'spring', stiffness: 260, damping: 30, mass: 0.9 },
  /** Buttons, taps, indicators — settles in ~250ms. */
  snappy: { type: 'spring', stiffness: 440, damping: 34, mass: 0.8 },
  /** Cart badge, checkmarks — a little life, no bounce-fest. */
  pop: { type: 'spring', stiffness: 520, damping: 22, mass: 0.7 },
  /**
   * The shared-element pizza hero. Heavier than the UI springs so it reads as
   * one physical object being carried between screens, but stiff enough to
   * settle in ~600ms — AnimatePresence holds the outgoing screen mounted until
   * this resolves, so a lazier spring costs responsiveness, not just time.
   */
  hero: { type: 'spring', stiffness: 230, damping: 29, mass: 0.95 },
  /** Bottom sheets and drawers. */
  sheet: { type: 'spring', stiffness: 340, damping: 36, mass: 0.9 },
  /** Numeric counters — critically damped so digits never jitter. */
  counter: { type: 'spring', stiffness: 180, damping: 26, mass: 0.7 },
} satisfies Record<string, Transition>

/** Stagger steps, in seconds. Kept tight — the reference never feels slow. */
export const STAGGER = {
  tight: 0.035,
  normal: 0.05,
  relaxed: 0.07,
} as const

/**
 * Tween helper so screens never inline magic numbers.
 *
 * `delay` is omitted rather than sent as 0: an explicit zero delay overrides the
 * delay a variant parent computes for `staggerChildren`, which silently flattens
 * every staggered entrance into a single simultaneous fade.
 */
export const tween = (
  duration: number = DUR.normal,
  ease: readonly number[] = EASE.out,
  delay?: number,
): Transition => ({
  type: 'tween',
  duration,
  ease: ease as number[],
  ...(delay ? { delay } : {}),
})

export const REDUCED: Transition = { type: 'tween', duration: 0.001 }
