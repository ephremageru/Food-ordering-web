import { forwardRef } from 'react'
import { motion, type HTMLMotionProps } from 'framer-motion'
import { SPRING } from './tokens'

type Props = HTMLMotionProps<'button'> & {
  /** How far the control compresses under the finger. */
  press?: number
  /** Lift applied on hover, pointer devices only (CSS media query gates it). */
  hoverLift?: number
  hoverScale?: number
}

/**
 * Every tappable surface in the app.
 *
 * The press is a spring, not a tween, so releasing early still settles
 * naturally — the control never feels "held down" waiting for a timer.
 */
export const Pressable = forwardRef<HTMLButtonElement, Props>(function Pressable(
  { press = 0.96, hoverLift = 0, hoverScale = 1, children, ...rest },
  ref,
) {
  return (
    <motion.button
      ref={ref}
      type="button"
      whileTap={{ scale: press }}
      whileHover={hoverLift || hoverScale !== 1 ? { y: -hoverLift, scale: hoverScale } : undefined}
      transition={SPRING.snappy}
      {...rest}
    >
      {children}
    </motion.button>
  )
})
