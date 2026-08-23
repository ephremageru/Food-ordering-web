import type { Variants } from 'framer-motion'
import { DUR, EASE, SPRING, STAGGER, tween } from './tokens'

/**
 * Page-level transitions.
 *
 * Deliberately NOT one variant reused everywhere: each navigation context says
 * something different about the relationship between the two screens.
 */
export type TransitionKind =
  | 'push'       // deeper into a flow — slides in from the trailing edge
  | 'pop'        // back out of a flow — the mirror of push
  | 'modal'      // a sheet rising over the current screen
  | 'dissolve'   // sibling screens (tab switches) — no spatial claim
  | 'morph'      // a shared element carries continuity; the page itself just clears
  | 'reveal'     // onboarding handing off to the app

export const pageVariants: Record<TransitionKind, Variants> = {
  push: {
    initial: { opacity: 0, x: '18%' },
    animate: { opacity: 1, x: 0, transition: { ...SPRING.soft, opacity: tween(DUR.quick) } },
    exit: { opacity: 0, x: '-8%', transition: tween(DUR.normal, EASE.standard) },
  },
  pop: {
    initial: { opacity: 0, x: '-8%' },
    animate: { opacity: 1, x: 0, transition: { ...SPRING.soft, opacity: tween(DUR.quick) } },
    exit: { opacity: 0, x: '18%', transition: tween(DUR.normal, EASE.standard) },
  },
  modal: {
    initial: { y: '100%' },
    animate: { y: 0, transition: SPRING.sheet },
    exit: { y: '100%', transition: tween(DUR.normal, EASE.in) },
  },
  dissolve: {
    initial: { opacity: 0, y: 8, scale: 0.995 },
    animate: { opacity: 1, y: 0, scale: 1, transition: tween(DUR.normal, EASE.out) },
    exit: { opacity: 0, y: -6, scale: 0.995, transition: tween(DUR.fast, EASE.in) },
  },
  // The shared element does the talking, so the page itself never fades in —
  // it would drag the shared element's opacity down with it. `Screen` renders a
  // separate backdrop for the fade; the content staggers itself. Only the
  // outgoing screen fades, blurring as it recedes behind the travelling element.
  morph: {
    initial: { opacity: 1 },
    animate: { opacity: 1 },
    exit: { opacity: 0, filter: 'blur(8px)', transition: tween(DUR.normal, EASE.in) },
  },
  reveal: {
    initial: { opacity: 0, scale: 1.015 },
    animate: { opacity: 1, scale: 1, transition: tween(DUR.large, EASE.out) },
    exit: { opacity: 0, scale: 1.04, filter: 'blur(10px)', transition: tween(DUR.medium, EASE.in) },
  },
}

/**
 * Staggered content entrance. Parents orchestrate, children just declare their
 * own shape — this is how every screen sequences header → body → controls.
 */
export const listGroup = (stagger: number = STAGGER.normal, delayChildren = 0): Variants => ({
  initial: {},
  animate: { transition: { staggerChildren: stagger, delayChildren } },
  exit: { transition: { staggerChildren: 0.02, staggerDirection: -1 } },
})

/** Default child: rises a few pixels while fading. Subtle, never a "fly-in". */
export const listItem: Variants = {
  initial: { opacity: 0, y: 12 },
  animate: { opacity: 1, y: 0, transition: { ...SPRING.soft, opacity: tween(DUR.quick) } },
  exit: { opacity: 0, y: -6, transition: tween(DUR.fast, EASE.in) },
}

/** Grid cards: fade + settle from slightly small, matching the reference's menu reflow. */
export const cardItem: Variants = {
  initial: { opacity: 0, scale: 0.94, y: 14 },
  animate: { opacity: 1, scale: 1, y: 0, transition: { ...SPRING.soft, opacity: tween(DUR.quick) } },
  exit: { opacity: 0, scale: 0.95, y: 0, transition: tween(DUR.fast, EASE.in) },
}
