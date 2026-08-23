import { useEffect, useState } from 'react'

/**
 * Tracks `prefers-reduced-motion`. Framer's `<MotionConfig reducedMotion="user">`
 * already neutralises transform animations, but decorative motion (floating
 * ingredients, burst rays, count-ups) has to opt out explicitly — this is how
 * components ask.
 */
export function useReducedMotionPref(): boolean {
  const [reduced, setReduced] = useState(() => {
    if (typeof window === 'undefined' || !window.matchMedia) return false
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  })

  useEffect(() => {
    if (!window.matchMedia) return
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
    const onChange = () => setReduced(mq.matches)
    mq.addEventListener('change', onChange)
    return () => mq.removeEventListener('change', onChange)
  }, [])

  return reduced
}

/** True on pointer-capable devices, so hover choreography only runs where it applies. */
export function useHoverCapable(): boolean {
  const [can, setCan] = useState(() => {
    if (typeof window === 'undefined' || !window.matchMedia) return false
    return window.matchMedia('(hover: hover) and (pointer: fine)').matches
  })
  useEffect(() => {
    if (!window.matchMedia) return
    const mq = window.matchMedia('(hover: hover) and (pointer: fine)')
    const onChange = () => setCan(mq.matches)
    mq.addEventListener('change', onChange)
    return () => mq.removeEventListener('change', onChange)
  }, [])
  return can
}
