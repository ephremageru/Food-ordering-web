import { memo, useMemo } from 'react'
import { hashString, mulberry32 } from './rng'

export type ToppingKind =
  | 'pepperoni'
  | 'mushroom'
  | 'olive'
  | 'onion'
  | 'chicken'
  | 'mozzarella'
  | 'rocket'
  | 'beef'
  | 'tomato'
  | 'pepper'

export type PizzaLook = {
  /** Sauce/base colour under the cheese. */
  base: string
  /** Melted-cheese colour laid over the base. */
  cheese: string
  crust: string
  crustDeep: string
  toppings: ToppingKind[]
  /** How many topping pieces to scatter. */
  density?: number
}

/* -------------------------------------------------------------------------- */

/**
 * Slightly irregular circle — a perfect circle reads as a plastic prop.
 * Closed with Catmull-Rom-derived beziers so the outline stays smooth at any
 * scale; straight segments would show as facets once the pizza fills the
 * detail hero.
 */
function wobblePath(r: number, wobble: number, points: number, rand: () => number) {
  const pts: [number, number][] = []
  for (let i = 0; i < points; i++) {
    const a = (i / points) * Math.PI * 2
    const rr = r + (rand() - 0.5) * wobble
    pts.push([100 + Math.cos(a) * rr, 100 + Math.sin(a) * rr])
  }
  const at = (i: number) => pts[(i + pts.length) % pts.length]
  let d = `M${at(0)[0].toFixed(2)},${at(0)[1].toFixed(2)}`
  for (let i = 0; i < pts.length; i++) {
    const [p0x, p0y] = at(i - 1)
    const [p1x, p1y] = at(i)
    const [p2x, p2y] = at(i + 1)
    const [p3x, p3y] = at(i + 2)
    const c1x = p1x + (p2x - p0x) / 6
    const c1y = p1y + (p2y - p0y) / 6
    const c2x = p2x - (p3x - p1x) / 6
    const c2y = p2y - (p3y - p1y) / 6
    d += ` C${c1x.toFixed(2)},${c1y.toFixed(2)} ${c2x.toFixed(2)},${c2y.toFixed(2)} ${p2x.toFixed(2)},${p2y.toFixed(2)}`
  }
  return d + ' Z'
}

function Topping({ kind, x, y, s, rot, rand }: {
  kind: ToppingKind; x: number; y: number; s: number; rot: number; rand: () => number
}) {
  const t = `translate(${x} ${y}) rotate(${rot}) scale(${s})`
  switch (kind) {
    case 'pepperoni':
      return (
        <g transform={t}>
          <circle r="9.4" fill="#a5301f" />
          <circle r="8.4" fill="#c94530" />
          <circle r="8.4" fill="url(#pepGloss)" />
          {[0, 1, 2, 3].map((i) => {
            const a = rand() * Math.PI * 2
            const rr = rand() * 5
            return <circle key={i} cx={Math.cos(a) * rr} cy={Math.sin(a) * rr} r={0.9 + rand()} fill="#7d2317" opacity="0.75" />
          })}
        </g>
      )
    case 'mushroom':
      return (
        <g transform={t}>
          <path d="M-7.5 1 A7.5 6.4 0 0 1 7.5 1 L5 1 L4.2 6.4 A4.6 2 0 0 1 -4.2 6.4 L-5 1 Z" fill="#efe3ce" />
          <path d="M-7.5 1 A7.5 6.4 0 0 1 7.5 1 Z" fill="#e0cfb2" />
          <path d="M-2.6 1.2 L-2 5.6 M0 1.2 L0 6 M2.6 1.2 L2 5.6" stroke="#c9b492" strokeWidth="0.9" fill="none" strokeLinecap="round" />
        </g>
      )
    case 'olive':
      return (
        <g transform={t}>
          <circle r="6.2" fill="#2f2b33" />
          <circle r="3.1" fill="#6b6472" />
          <circle r="6.2" fill="url(#oliveGloss)" />
        </g>
      )
    case 'onion':
      return (
        <g transform={t}>
          <path d="M-8 0 A8 8 0 0 1 8 0" stroke="#c8a9d4" strokeWidth="2.4" fill="none" strokeLinecap="round" />
          <path d="M-5.4 0 A5.4 5.4 0 0 1 5.4 0" stroke="#e3d2ea" strokeWidth="2" fill="none" strokeLinecap="round" />
        </g>
      )
    case 'chicken':
      return (
        <g transform={t}>
          <path d="M-7 -3 Q-2 -7 4 -5 Q9 -3 7 2 Q5 7 -1 6 Q-8 5 -7 -3 Z" fill="#dfae74" />
          <path d="M-4 -2 Q0 -4 4 -2" stroke="#c08e56" strokeWidth="1.2" fill="none" strokeLinecap="round" />
        </g>
      )
    case 'beef':
      return (
        <g transform={t}>
          <path d="M-5 -3 Q0 -6 5 -3 Q7 1 3 4 Q-2 6 -5 2 Z" fill="#8a5230" />
          <path d="M-2 -1 Q1 -2 3 0" stroke="#6d3d21" strokeWidth="1.1" fill="none" strokeLinecap="round" />
        </g>
      )
    case 'mozzarella':
      return (
        <g transform={t}>
          <path d="M-8 -2 Q-6 -8 1 -7 Q8 -6 8 1 Q8 8 0 7.5 Q-8 7 -8 -2 Z" fill="#fdf8ec" />
          <path d="M-4 -2 Q-1 -5 3 -3" stroke="#eee2cb" strokeWidth="1.4" fill="none" strokeLinecap="round" />
        </g>
      )
    case 'rocket':
      return (
        <g transform={t}>
          <path d="M0 -9 Q6 -4 5 3 Q3 9 0 9 Q-3 9 -5 3 Q-6 -4 0 -9 Z" fill="#4d8a3c" />
          <path d="M0 -7 L0 8" stroke="#3d6f30" strokeWidth="0.9" />
        </g>
      )
    case 'tomato':
      return (
        <g transform={t}>
          <circle r="7" fill="#d8402f" />
          <circle r="4.6" fill="#ef6a52" />
          <path d="M0 -4.6 L0 4.6 M-4.6 0 L4.6 0" stroke="#d8402f" strokeWidth="1.3" />
        </g>
      )
    case 'pepper':
      return (
        <g transform={t}>
          <path d="M-8 0 A8 6 0 0 1 8 0 A8 6 0 0 1 -8 0 Z" fill="none" stroke="#3f8f3f" strokeWidth="2.6" strokeLinecap="round" />
        </g>
      )
  }
}

function Basil({ x, y, rot, s = 1 }: { x: number; y: number; rot: number; s?: number }) {
  return (
    <g transform={`translate(${x} ${y}) rotate(${rot}) scale(${s})`}>
      <path d="M0 -13 Q9 -6 7 4 Q4 13 0 13 Q-4 13 -7 4 Q-9 -6 0 -13 Z" fill="#3f8b39" />
      <path d="M0 -13 Q9 -6 7 4 Q4 13 0 13 Z" fill="#4fa246" />
      <path d="M0 -11 L0 12" stroke="#2f6b2b" strokeWidth="1.1" strokeLinecap="round" />
    </g>
  )
}

/* -------------------------------------------------------------------------- */

/**
 * A top-down pizza drawn entirely in SVG.
 *
 * Square viewBox and `preserveAspectRatio` mean it scales without distortion,
 * which is what lets the same node grow from a 96px card thumbnail to a 240px
 * detail hero during a layout animation and stay visually continuous.
 */
export const Pizza = memo(function Pizza({
  id,
  look,
  className,
  style,
}: {
  id: string
  look: PizzaLook
  className?: string
  style?: React.CSSProperties
}) {
  const scene = useMemo(() => {
    const rand = mulberry32(hashString(id))
    const crustEdge = wobblePath(92, 4.5, 26, rand)
    const sauceEdge = wobblePath(76, 3.5, 22, rand)

    const density = look.density ?? 13
    const pieces: { kind: ToppingKind; x: number; y: number; s: number; rot: number }[] = []
    // Golden-angle placement keeps pieces evenly spread instead of clumping,
    // which is what random polar coordinates alone would do.
    const golden = Math.PI * (3 - Math.sqrt(5))
    for (let i = 0; i < density; i++) {
      const frac = (i + 0.6) / density
      const radius = Math.sqrt(frac) * 62
      const angle = i * golden + rand() * 0.5
      pieces.push({
        kind: look.toppings[i % look.toppings.length],
        x: 100 + Math.cos(angle) * radius,
        y: 100 + Math.sin(angle) * radius,
        s: 0.82 + rand() * 0.36,
        rot: rand() * 360,
      })
    }

    const cheeseBlobs = Array.from({ length: 9 }, () => {
      const a = rand() * Math.PI * 2
      const r = rand() * 66
      return { x: 100 + Math.cos(a) * r, y: 100 + Math.sin(a) * r, rx: 10 + rand() * 12, ry: 7 + rand() * 9, rot: rand() * 180 }
    })

    const chars = Array.from({ length: 11 }, () => {
      const a = rand() * Math.PI * 2
      const r = 80 + rand() * 10
      return { x: 100 + Math.cos(a) * r, y: 100 + Math.sin(a) * r, rx: 3 + rand() * 4, ry: 2.4 + rand() * 3, rot: (a * 180) / Math.PI }
    })

    const basil = [
      { x: 100, y: 96, rot: -18, s: 0.95 },
      { x: 88, y: 108, rot: 42, s: 0.78 },
      { x: 113, y: 106, rot: -62, s: 0.72 },
    ]

    return { crustEdge, sauceEdge, pieces, cheeseBlobs, chars, basil }
  }, [id, look])

  const gid = `pz-${id}`

  return (
    <svg
      className={className}
      style={style}
      viewBox="0 0 200 200"
      preserveAspectRatio="xMidYMid meet"
      role="img"
      aria-hidden="true"
    >
      <defs>
        <radialGradient id={`${gid}-crust`} cx="42%" cy="34%" r="72%">
          <stop offset="0%" stopColor={look.crust} />
          <stop offset="72%" stopColor={look.crust} />
          <stop offset="100%" stopColor={look.crustDeep} />
        </radialGradient>
        <radialGradient id={`${gid}-cheese`} cx="40%" cy="32%" r="76%">
          <stop offset="0%" stopColor={look.cheese} stopOpacity="0.98" />
          <stop offset="100%" stopColor={look.base} stopOpacity="0.9" />
        </radialGradient>
        <radialGradient id="pepGloss" cx="35%" cy="30%" r="70%">
          <stop offset="0%" stopColor="#fff" stopOpacity="0.34" />
          <stop offset="60%" stopColor="#fff" stopOpacity="0" />
        </radialGradient>
        <radialGradient id="oliveGloss" cx="34%" cy="28%" r="66%">
          <stop offset="0%" stopColor="#fff" stopOpacity="0.4" />
          <stop offset="70%" stopColor="#fff" stopOpacity="0" />
        </radialGradient>
        <radialGradient id={`${gid}-shadow`} cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#7a5230" stopOpacity="0.26" />
          <stop offset="70%" stopColor="#7a5230" stopOpacity="0.1" />
          <stop offset="100%" stopColor="#7a5230" stopOpacity="0" />
        </radialGradient>
      </defs>

      <ellipse cx="100" cy="112" rx="94" ry="88" fill={`url(#${gid}-shadow)`} />
      <path d={scene.crustEdge} fill={`url(#${gid}-crust)`} />
      {scene.chars.map((c, i) => (
        <ellipse key={i} cx={c.x} cy={c.y} rx={c.rx} ry={c.ry} transform={`rotate(${c.rot} ${c.x} ${c.y})`} fill="#8a5a2c" opacity="0.42" />
      ))}
      <path d={scene.sauceEdge} fill={look.base} />
      <path d={scene.sauceEdge} fill={`url(#${gid}-cheese)`} />
      {scene.cheeseBlobs.map((b, i) => (
        <ellipse key={i} cx={b.x} cy={b.y} rx={b.rx} ry={b.ry} transform={`rotate(${b.rot} ${b.x} ${b.y})`} fill={look.cheese} opacity="0.55" />
      ))}
      {/* Slice scoring — faint, just enough to read as a cut pizza. */}
      {Array.from({ length: 8 }, (_, i) => {
        const a = (i / 8) * Math.PI * 2
        return (
          <line
            key={i}
            x1={100 + Math.cos(a) * 12}
            y1={100 + Math.sin(a) * 12}
            x2={100 + Math.cos(a) * 74}
            y2={100 + Math.sin(a) * 74}
            stroke="#a9713c"
            strokeWidth="0.9"
            opacity="0.2"
          />
        )
      })}
      {scene.pieces.map((p, i) => {
        const rand = mulberry32(hashString(id + i))
        return <Topping key={i} {...p} rand={rand} />
      })}
      {scene.basil.map((b, i) => (
        <Basil key={i} {...b} />
      ))}
    </svg>
  )
})
