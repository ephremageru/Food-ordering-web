import { motion } from 'framer-motion'
import { CATEGORIES, type CategoryId } from '../data/pizzas'
import { SPRING, DUR, EASE, tween } from '../motion/tokens'
import { IconGrid } from '../art/Icons'
import { Pizza } from '../art/Pizza'

/** Vertical offset + size per arc slot, highest at the centre. */
const SLOTS = [
  { lift: 0, size: 42 },
  { lift: 26, size: 50 },
  { lift: 44, size: 62 },
  { lift: 26, size: 50 },
  { lift: 0, size: 42 },
]

const ICON_LOOK: Record<CategoryId, Parameters<typeof Pizza>[0]['look']> = {
  all: { base: '#f2e3c6', cheese: '#fdf6e6', crust: '#e6b26a', crustDeep: '#c8863c', toppings: ['mozzarella'], density: 4 },
  beef: { base: '#c04226', cheese: '#efc97f', crust: '#e6b26a', crustDeep: '#c8863c', toppings: ['beef'], density: 4 },
  chicken: { base: '#d9633a', cheese: '#f3d494', crust: '#e6b26a', crustDeep: '#c8863c', toppings: ['chicken'], density: 4 },
  cheese: { base: '#f4e6c8', cheese: '#fdf3dd', crust: '#e6b26a', crustDeep: '#c8863c', toppings: ['mozzarella'], density: 4 },
  mushroom: { base: '#e8dcc0', cheese: '#f7edd8', crust: '#e6b26a', crustDeep: '#c8863c', toppings: ['mushroom'], density: 4 },
}

/**
 * The curved category picker.
 *
 * The active indicator is a single element with a `layoutId`, so switching
 * category slides the underline from the old label to the new one instead of
 * hiding one bar and showing another. That continuity is the whole point.
 */
export function CategoryArc({
  value,
  onChange,
}: {
  value: CategoryId
  onChange: (id: CategoryId) => void
}) {
  const activeIndex = Math.max(0, CATEGORIES.findIndex((c) => c.id === value))

  return (
    <div className="cat-arc" role="tablist" aria-label="Pizza categories">
      <div className="cat-arc-bg" aria-hidden />
      {CATEGORIES.map((cat, i) => {
        const slot = SLOTS[i]
        const active = cat.id === value
        return (
          <button
            key={cat.id}
            role="tab"
            aria-selected={active}
            className={`cat-item ${active ? 'is-active' : ''}`}
            style={{ paddingBottom: slot.lift }}
            onClick={() => onChange(cat.id)}
          >
            <motion.span
              className="cat-icon"
              style={{ width: slot.size, height: slot.size }}
              animate={{ scale: active ? 1.06 : 1, y: active ? -2 : 0 }}
              whileHover={{ scale: active ? 1.08 : 1.05 }}
              whileTap={{ scale: 0.94 }}
              transition={SPRING.snappy}
            >
              {cat.id === 'all' ? (
                <IconGrid size={slot.size * 0.42} />
              ) : (
                <Pizza id={`cat-${cat.id}`} look={ICON_LOOK[cat.id]} style={{ width: '78%', height: '78%' }} />
              )}
            </motion.span>
            <motion.span
              className="cat-label"
              animate={{ color: active ? 'var(--ink)' : 'var(--muted)', fontWeight: active ? 700 : 500 }}
              transition={tween(DUR.quick, EASE.out)}
            >
              {cat.label}
            </motion.span>
            <span className="cat-underline-slot" />
          </button>
        )
      })}

      {/* One indicator that moves, rather than one hidden and another shown.
          `layout` on a permanently mounted element instead of `layoutId` on a
          conditional one: the shared-id version leaves a pending projection
          behind that stalls the screen's own exit animation. */}
      <div className="cat-underline-row" aria-hidden>
        {/* Matches the active slot's lift as well as its column, so the
            indicator travels along the arc rather than across a flat line. */}
        <span
          className="cat-underline-cell"
          style={{ gridColumn: activeIndex + 1, paddingBottom: SLOTS[activeIndex].lift }}
        >
          <motion.span layout className="cat-underline" transition={SPRING.snappy} />
        </span>
      </div>
    </div>
  )
}
