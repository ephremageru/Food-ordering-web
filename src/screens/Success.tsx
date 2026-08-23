import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { EASE, SPRING, tween } from '../motion/tokens'
import { useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { useReducedMotionPref } from '../motion/useMotionPrefs'

const R = 52
const CIRCUMFERENCE = 2 * Math.PI * R

/**
 * Payment confirmation.
 *
 * The ring is drawn with `strokeDashoffset` rather than scaled in, so the mark
 * is constructed in front of you; the check is drawn the same way, and the
 * whole badge takes a single spring-loaded pop with a short radial burst at the
 * moment it completes. That beat is what makes the confirmation land.
 */
export function Success() {
  const nav = useNav()
  const store = useStore()
  const reduced = useReducedMotionPref()
  const [burst, setBurst] = useState(false)

  const order = store.orders[0]
  const itemCount = order?.lines.reduce((n, l) => n + l.qty, 0) ?? 0

  useEffect(() => {
    if (reduced) {
      setBurst(false)
      const go = window.setTimeout(() => nav.reset('orders', { kind: 'dissolve' }), 1200)
      return () => window.clearTimeout(go)
    }
    const b = window.setTimeout(() => setBurst(true), 980)
    const go = window.setTimeout(() => nav.reset('orders', { kind: 'dissolve' }), 3000)
    return () => {
      window.clearTimeout(b)
      window.clearTimeout(go)
    }
  }, [nav, reduced])

  return (
    <div className="success">
      <div className="success-center">
        <div className="success-badge">
          <motion.svg
            width="132" height="132" viewBox="0 0 132 132"
            animate={burst ? { scale: [1, 1.09, 1] } : { scale: 1 }}
            transition={SPRING.pop}
            aria-hidden
          >
            <motion.circle
              cx="66" cy="66" r={R}
              fill="none"
              stroke="var(--success)"
              strokeWidth="5"
              strokeLinecap="round"
              transform="rotate(-90 66 66)"
              strokeDasharray={CIRCUMFERENCE}
              initial={{ strokeDashoffset: reduced ? 0 : CIRCUMFERENCE }}
              animate={{ strokeDashoffset: 0 }}
              transition={reduced ? { duration: 0.001 } : { duration: 0.72, ease: EASE.out, delay: 0.12 }}
            />
            <motion.path
              d="M45 67.5 L59.5 82 L88 51"
              fill="none"
              stroke="var(--success)"
              strokeWidth="6"
              strokeLinecap="round"
              strokeLinejoin="round"
              initial={{ pathLength: reduced ? 1 : 0 }}
              animate={{ pathLength: 1 }}
              transition={reduced ? { duration: 0.001 } : { duration: 0.34, ease: EASE.out, delay: 0.8 }}
            />
          </motion.svg>

          {/* Radial rays fire once as the check completes, then clear.
              One group, scaled and faded as a unit — transform and opacity
              only, so nothing re-computes geometry mid-flight. */}
          {!reduced && (
            <svg className="success-burst" width="200" height="200" viewBox="0 0 200 200" aria-hidden>
              <motion.g
                style={{ transformOrigin: '100px 100px' }}
                initial={{ scale: 0.68, opacity: 0 }}
                animate={burst ? { scale: 1.16, opacity: [0, 0.9, 0] } : { scale: 0.68, opacity: 0 }}
                transition={{ duration: 0.6, ease: EASE.out, times: [0, 0.28, 1] }}
              >
                {Array.from({ length: 12 }, (_, i) => {
                  const a = (i / 12) * Math.PI * 2 - Math.PI / 2
                  return (
                    <line
                      key={i}
                      x1={100 + Math.cos(a) * 60}
                      y1={100 + Math.sin(a) * 60}
                      x2={100 + Math.cos(a) * 74}
                      y2={100 + Math.sin(a) * 74}
                      stroke="var(--success)"
                      strokeWidth="3.5"
                      strokeLinecap="round"
                    />
                  )
                })}
              </motion.g>
            </svg>
          )}
        </div>

        <motion.h1
          className="success-title"
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={reduced ? { duration: 0.001 } : { ...SPRING.soft, delay: 0.5 }}
        >
          Payment Successful
        </motion.h1>
        <motion.p
          className="success-meta"
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={reduced ? { duration: 0.001 } : { ...SPRING.soft, delay: 0.62 }}
        >
          ${order?.total.toFixed(2) ?? '0.00'} paid · Order {order?.id ?? '—'}
        </motion.p>
        <motion.p
          className="success-note"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={reduced ? { duration: 0.001 } : { ...SPRING.soft, delay: 0.72 }}
        >
          {itemCount} item{itemCount === 1 ? '' : 's'} on the way to you
        </motion.p>
      </div>

      <motion.p
        className="success-foot"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={tween(0.4, EASE.out, reduced ? 0 : 1.2)}
      >
        Taking you to your orders…
      </motion.p>
    </div>
  )
}
