import type { ReactNode } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { DUR, EASE, SPRING, tween } from './tokens'
import { useHoverCapable } from './useMotionPrefs'

type Props = {
  open: boolean
  onClose: () => void
  children: ReactNode
  /** Accessible label for the dialog. */
  label?: string
}

/**
 * Bottom sheet on touch, centred modal on pointer devices.
 *
 * The sheet is drag-to-dismiss: the drag maps 1:1 to the sheet's own `y`, and
 * release velocity decides whether it snaps home or continues out — the same
 * rule iOS uses, which is why a flick feels different from a slow pull.
 */
export function Sheet({ open, onClose, children, label }: Props) {
  const isModal = useHoverCapable()

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          className="sheet-root"
          initial="initial"
          animate="animate"
          exit="exit"
          role="dialog"
          aria-modal="true"
          aria-label={label}
        >
          <motion.div
            className="sheet-backdrop"
            onClick={onClose}
            variants={{
              initial: { opacity: 0 },
              animate: { opacity: 1, transition: tween(DUR.normal, EASE.out) },
              exit: { opacity: 0, transition: tween(DUR.quick, EASE.in) },
            }}
          />
          {isModal ? (
            <motion.div
              className="sheet-panel sheet-panel--modal"
              variants={{
                initial: { opacity: 0, scale: 0.96 },
                animate: { opacity: 1, scale: 1, transition: SPRING.snappy },
                exit: { opacity: 0, scale: 0.97, transition: tween(DUR.fast, EASE.in) },
              }}
            >
              {children}
            </motion.div>
          ) : (
            <motion.div
              className="sheet-panel sheet-panel--bottom"
              variants={{
                initial: { y: '100%' },
                animate: { y: 0, transition: SPRING.sheet },
                exit: { y: '100%', transition: tween(DUR.normal, EASE.in) },
              }}
              drag="y"
              dragConstraints={{ top: 0, bottom: 0 }}
              dragElastic={{ top: 0, bottom: 0.7 }}
              onDragEnd={(_, info) => {
                if (info.offset.y > 110 || info.velocity.y > 550) onClose()
              }}
            >
              <div className="sheet-grabber" aria-hidden />
              {children}
            </motion.div>
          )}
        </motion.div>
      )}
    </AnimatePresence>
  )
}
