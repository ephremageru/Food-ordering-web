import { useEffect, useRef, useState } from 'react'
import { animate, useMotionValue } from 'framer-motion'
import { SPRING } from './tokens'
import { useReducedMotionPref } from './useMotionPrefs'

type Props = {
  value: number
  /** Decimal places to render. */
  decimals?: number
  /** Rendered before the digits, e.g. a currency glyph. */
  prefix?: string
  suffix?: string
  className?: string
}

/**
 * Counts to `value` instead of swapping the text.
 *
 * Writes straight to `textContent` from the animation frame rather than through
 * React state, so a running total never re-renders the tree around it — which is
 * what keeps a quantity change from visually reloading the whole cart.
 */
export function AnimatedNumber({ value, decimals = 2, prefix = '', suffix = '', className }: Props) {
  const mv = useMotionValue(value)
  const ref = useRef<HTMLSpanElement>(null)
  const reduced = useReducedMotionPref()
  // Mount shows the real value immediately; only later changes count.
  const mounted = useRef(false)

  useEffect(() => {
    const node = ref.current
    if (!node) return
    const render = (v: number) => {
      node.textContent = prefix + v.toFixed(decimals) + suffix
    }
    render(mv.get())
    const unsub = mv.on('change', render)
    return unsub
  }, [mv, decimals, prefix, suffix])

  useEffect(() => {
    if (!mounted.current) {
      mounted.current = true
      mv.set(value)
      return
    }
    if (reduced) {
      mv.set(value)
      return
    }
    const controls = animate(mv, value, SPRING.counter)
    return () => controls.stop()
  }, [value, mv, reduced])

  // Rendered once and never updated by React again. If the JSX tracked `value`,
  // any re-render mid-count would stamp the destination number into the DOM and
  // the animation would visibly snap forward and then resume.
  const [initialText] = useState(() => prefix + value.toFixed(decimals) + suffix)

  return (
    <span ref={ref} className={className}>
      {initialText}
    </span>
  )
}

/** Price with the small raised currency mark the reference uses. */
export function AnimatedPrice({
  value,
  className,
  symbolClassName,
}: {
  value: number
  className?: string
  symbolClassName?: string
}) {
  return (
    <span className={className}>
      <span className={symbolClassName ?? 'currency'}>$</span>
      <AnimatedNumber value={value} />
    </span>
  )
}
