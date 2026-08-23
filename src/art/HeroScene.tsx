import { motion } from 'framer-motion'
import { useMemo } from 'react'
import { Pizza, type ToppingKind } from './Pizza'
import { EASE, SPRING } from '../motion/tokens'
import { hashString, mulberry32 } from './rng'
import { useReducedMotionPref } from '../motion/useMotionPrefs'

/** One flying ingredient: where it sits, how big, how it drifts. */
type Piece = { kind: ToppingKind; x: number; y: number; s: number; rot: number; delay: number; drift: number; dur: number }

const KINDS: ToppingKind[] = ['pepperoni', 'mushroom', 'olive', 'onion', 'mozzarella', 'rocket', 'pepperoni', 'mozzarella', 'olive', 'mushroom', 'onion', 'rocket', 'pepperoni', 'mozzarella']

/**
 * The onboarding hero: a pizza with its toppings suspended above it.
 *
 * The reference opens on a still photograph of exactly this. Rebuilding it as
 * vector pieces means the ingredients can actually assemble on entry — which
 * is what the headline ("Build your Flavour, Step by Step") is describing.
 */
export function HeroScene() {
  const reduced = useReducedMotionPref()

  const pieces = useMemo<Piece[]>(() => {
    const rand = mulberry32(hashString('hero-scene-v1'))
    return KINDS.map((kind, i) => {
      // A funnel: wide at the top, converging onto the pizza. `t` runs 0 at the
      // top of the cone to 1 just above the crust, and everything — spread,
      // size, and entry delay — is derived from it so the pieces read as one
      // stream falling into place rather than fourteen separate objects.
      const t = i / (KINDS.length - 1)
      const spread = 30 - t * 19
      return {
        kind,
        // Alternating sides with a little jitter: an even stream, where pure
        // randomness kept stranding pieces far out on one side.
        x: 50 + Math.sin(i * 2.39996) * spread + (rand() - 0.5) * 5,
        y: 13 + t * 34 + (rand() - 0.5) * 4,
        s: 0.66 + (1 - t) * 0.42 + rand() * 0.16,
        rot: rand() * 360,
        // Lower pieces land first; the top of the stack arrives last.
        delay: 0.12 + (1 - t) * 0.4 + rand() * 0.05,
        drift: 3 + rand() * 5,
        dur: 3.4 + rand() * 2.2,
      }
    })
  }, [])

  return (
    <div className="hero-scene">
      <div className="hero-pizza">
        <motion.div
          className="hero-pizza-inner"
          initial={{ opacity: 0, y: 34, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ ...SPRING.hero, delay: 0.04 }}
        >
        <Pizza
          id="hero-margherita"
          look={{ base: '#c8412c', cheese: '#f4d795', crust: '#e8b876', crustDeep: '#c2803a', toppings: ['mozzarella', 'mozzarella', 'rocket'], density: 11 }}
          style={{ width: '100%', height: '100%' }}
        />
        </motion.div>
      </div>
      {/* Sauce layer — the last thing to land before the toppings. */}
      <div className="hero-sauce">
        <motion.svg
          viewBox="0 0 200 90"
          preserveAspectRatio="none"
          aria-hidden
          initial={{ opacity: 0, y: 26, scaleX: 0.86 }}
          animate={{ opacity: 1, y: 0, scaleX: 1 }}
          transition={{ ...SPRING.soft, delay: 0.16 }}
        >
          <path
            d="M10 46C10 30 30 20 52 16c20-4 34-2 52 0 20 2 40 8 48 20 8 12 2 24-14 30-18 7-42 10-66 9-22-1-44-5-56-13-4-3-6-9-6-16Z"
            fill="#c8412c"
          />
          <path
            d="M24 42c8-12 30-18 60-17 26 1 46 6 56 15"
            stroke="#e0583c"
            strokeWidth="6"
            fill="none"
            strokeLinecap="round"
          />
          <ellipse cx="66" cy="34" rx="14" ry="6" fill="#d9503a" opacity="0.7" />
        </motion.svg>
      </div>

      {pieces.map((p, i) => (
        <div
          key={i}
          className="hero-piece"
          style={{ left: `${p.x}%`, top: `${p.y}%`, width: `${p.s * 15}%` }}
        >
        <motion.div
          className="hero-piece-inner"
          initial={{ opacity: 0, y: 46, scale: 0.7, rotate: p.rot - 40 }}
          animate={
            reduced
              ? { opacity: 1, y: 0, scale: 1, rotate: p.rot }
              : {
                  opacity: 1,
                  scale: 1,
                  rotate: p.rot,
                  // Settle first, then breathe. The keyframe array runs after the
                  // entry spring resolves, so there is no fight over `y`.
                  y: [46, -p.drift, p.drift * 0.6, -p.drift],
                }
          }
          transition={
            reduced
              ? { duration: 0.001 }
              : {
                  opacity: { duration: 0.4, ease: EASE.out, delay: p.delay },
                  scale: { ...SPRING.soft, delay: p.delay },
                  rotate: { duration: 0.8, ease: EASE.out, delay: p.delay },
                  y: { duration: p.dur, times: [0, 0.28, 0.64, 1], repeat: Infinity, repeatType: 'mirror', ease: 'easeInOut', delay: p.delay },
                }
          }
        >
          <IngredientSprite kind={p.kind} />
        </motion.div>
        </div>
      ))}

    </div>
  )
}

/** Standalone sprite version of a topping, scaled to fill its box. */
export function IngredientSprite({ kind }: { kind: ToppingKind }) {
  const map: Record<string, JSX.Element> = {
    pepperoni: (
      <>
        <circle cx="20" cy="20" r="19" fill="#a5301f" />
        <circle cx="20" cy="20" r="17" fill="#c94530" />
        <circle cx="14" cy="15" r="2.4" fill="#7d2317" />
        <circle cx="26" cy="22" r="2" fill="#7d2317" />
        <circle cx="19" cy="28" r="1.7" fill="#7d2317" />
        <circle cx="15" cy="14" r="7" fill="#fff" opacity="0.14" />
      </>
    ),
    mushroom: (
      <>
        <path d="M2 22A18 15 0 0 1 38 22L31 22 29 34A9 5 0 0 1 11 34L9 22Z" fill="#efe3ce" />
        <path d="M2 22A18 15 0 0 1 38 22Z" fill="#ded0b3" />
        <path d="M15 23 14 33M20 23 20 35M25 23 26 33" stroke="#c5ae89" strokeWidth="2" strokeLinecap="round" />
      </>
    ),
    olive: (
      <>
        <circle cx="20" cy="20" r="16" fill="#2f2b33" />
        <circle cx="20" cy="20" r="7.5" fill="#6b6472" />
        <circle cx="15" cy="14" r="5" fill="#fff" opacity="0.18" />
      </>
    ),
    onion: (
      <>
        <circle cx="20" cy="20" r="17" fill="none" stroke="#c8a9d4" strokeWidth="5" />
        <circle cx="20" cy="20" r="10" fill="none" stroke="#e6d6ec" strokeWidth="4" />
      </>
    ),
    mozzarella: (
      <>
        <path d="M4 16C4 6 14 2 22 4s16 8 14 18-10 16-19 14S4 26 4 16Z" fill="#fdf8ec" />
        <path d="M12 14c4-5 12-4 15 1" stroke="#eadfc7" strokeWidth="3" fill="none" strokeLinecap="round" />
      </>
    ),
    beef: (
      <>
        <path d="M5 14C8 5 18 2 27 5s10 13 6 21-14 12-21 8S2 23 5 14Z" fill="#8a5230" />
        <path d="M13 15c4-4 10-3 13 2" stroke="#6d3d21" strokeWidth="3" fill="none" strokeLinecap="round" />
        <path d="M12 27c5-2 9-1 13 2" stroke="#6d3d21" strokeWidth="2.4" fill="none" strokeLinecap="round" />
      </>
    ),
    chicken: (
      <>
        <path d="M4 16C7 6 17 2 27 5s11 12 7 20-15 13-22 9S1 26 4 16Z" fill="#dfae74" />
        <path d="M12 16c4-4 11-3 14 2" stroke="#c08e56" strokeWidth="3" fill="none" strokeLinecap="round" />
      </>
    ),
    rocket: (
      <>
        <path d="M20 2C32 10 30 24 25 33c-3 5-8 6-11 3C8 31 6 18 20 2Z" fill="#4d8a3c" />
        <path d="M20 5C22 16 20 28 16 34" stroke="#3a6c2d" strokeWidth="2" fill="none" strokeLinecap="round" />
      </>
    ),
  }
  return (
    <svg viewBox="0 0 40 40" aria-hidden style={{ width: '100%', height: '100%', display: 'block' }}>
      {map[kind] ?? map.pepperoni}
    </svg>
  )
}
