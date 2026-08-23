import { forwardRef, type ReactNode } from 'react'
import { motion, useIsPresent } from 'framer-motion'
import { pageVariants, type TransitionKind } from '../motion/variants'
import { DUR, EASE, tween } from '../motion/tokens'

/**
 * A single screen in the navigation stack.
 *
 * `kind` picks the transition, and `direction` mirrors it when the same screen
 * is leaving backwards — that mirroring is what makes back feel like undo
 * rather than another forward step.
 *
 * Forwards its ref because AnimatePresence's `popLayout` mode measures the
 * outgoing screen before pulling it out of flow.
 */
export const Screen = forwardRef<
  HTMLDivElement,
  { kind: TransitionKind; direction: 1 | -1; children: ReactNode; className?: string }
>(function Screen({ kind, direction, children, className }, ref) {
  const resolved: TransitionKind = direction === -1 && kind === 'push' ? 'pop' : kind
  // AnimatePresence keeps an outgoing screen mounted until every descendant
  // animation settles — past the point where it looks gone. Taps must not reach
  // it in the meantime. Set through `style`, not a variant: `pointer-events` is
  // not an animatable value, and putting it in one stalls the exit.
  const present = useIsPresent()

  // A morph transition carries a shared element across the boundary, and that
  // element must never fade — a pizza that dims halfway is two pictures, not one
  // object. So the screen itself stays fully opaque on the way in and a separate
  // backdrop layer does the fading underneath the content.
  const isMorph = resolved === 'morph'

  return (
    <motion.div
      ref={ref}
      className={`screen ${isMorph ? 'screen--morph' : ''} ${className ?? ''}`}
      style={{ pointerEvents: present ? 'auto' : 'none' }}
      variants={pageVariants[resolved]}
      initial="initial"
      animate="animate"
      exit="exit"
    >
      {isMorph && (
        <motion.div
          className="screen-bg"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1, transition: tween(DUR.normal, EASE.out) }}
          exit={{ opacity: 0, transition: tween(DUR.quick, EASE.in) }}
        />
      )}
      {children}
    </motion.div>
  )
})
