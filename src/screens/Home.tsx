import { useMemo } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { CategoryArc } from '../components/CategoryArc'
import { PizzaCard } from '../components/PizzaCard'
import { IconBell, IconBag, IconChevronDown, IconSearch } from '../art/Icons'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { listGroup } from '../motion/variants'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { filterByCategory, type CategoryId } from '../data/pizzas'
import { useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { useHeroFlight } from '../state/heroFlight'

export function Home({
  category,
  onCategory,
}: {
  category: CategoryId
  onCategory: (c: CategoryId) => void
}) {
  const nav = useNav()
  const store = useStore()
  const flight = useHeroFlight()
  const pizzas = useMemo(() => filterByCategory(category), [category])

  const open = (id: string) => {
    // Marking the flight and pushing in the same event means React commits the
    // card's pizza unmounting and the detail hero mounting together — which is
    // exactly what lets the layout animation measure a start and an end.
    flight.setFlying(id)
    nav.push('product', { params: { id }, kind: 'morph' })
  }

  return (
    <>
      <div className="status-bar" />

      <StaggerGroup className="home-head pad" stagger={STAGGER.tight}>
        <StaggerItem>
          <header className="home-topline">
            <div className="avatar" aria-hidden>
              <svg viewBox="0 0 40 40">
                <circle cx="20" cy="20" r="20" fill="#e6ddd4" />
                <circle cx="20" cy="16" r="7" fill="#b9a794" />
                <path d="M6 40c1.6-8 7.2-12 14-12s12.4 4 14 12Z" fill="#2f2f36" />
              </svg>
            </div>
            <div className="home-address">
              <span className="label">Delivery to</span>
              <button className="home-address-btn">
                11/2 Diriyah, Riyadh
                <IconChevronDown size={14} />
              </button>
            </div>
            <motion.button className="icon-btn" whileHover={{ scale: 1.06 }} whileTap={{ scale: 0.92 }} transition={SPRING.snappy} aria-label="Notifications">
              <IconBell size={18} />
            </motion.button>
            <CartButton count={store.count} pulse={store.addPulse} onClick={() => nav.push('cart', { kind: 'modal' })} />
          </header>
        </StaggerItem>

        <StaggerItem>
          <h1 className="display home-display">
            Hungry? <span className="dim">Order &amp; Eat.</span>
          </h1>
        </StaggerItem>

        <StaggerItem>
          <motion.div className="search" whileHover={{ scale: 1.005 }} transition={SPRING.snappy}>
            <IconSearch size={17} className="search-icon" />
            <input placeholder="Search for Pizza" aria-label="Search for pizza" readOnly onFocus={() => nav.reset('search', { kind: 'dissolve' })} />
          </motion.div>
        </StaggerItem>
      </StaggerGroup>

      <div className="scroll home-scroll">
        <motion.div
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ ...SPRING.soft, delay: 0.12 }}
        >
          <CategoryArc value={category} onChange={onCategory} />
        </motion.div>

        {/* `mode="popLayout"` lets outgoing cards leave the flow immediately so
            the survivors reflow while the old ones are still fading — the menu
            reorganises instead of blanking and rebuilding. */}
        <motion.ul
          className="card-grid"
          variants={listGroup(STAGGER.tight, 0.04)}
          initial="initial"
          animate="animate"
          key="grid"
        >
          <AnimatePresence mode="popLayout" initial={false}>
            {pizzas.map((p) => (
              <PizzaCard
                key={p.id}
                pizza={p}
                heroActive={flight.flyingId === p.id}
                onOpen={() => open(p.id)}
                onQuickAdd={() => store.dispatch({ type: 'add', pizzaId: p.id, size: 'medium', extras: [], qty: 1 })}
              />
            ))}
          </AnimatePresence>
        </motion.ul>
      </div>
    </>
  )
}

/**
 * Cart button with a badge that pops on every add.
 * `pulse` is a monotonically increasing counter rather than the count itself,
 * so adding a second unit of the same pizza still registers visually.
 */
export function CartButton({ count, pulse, onClick }: { count: number; pulse: number; onClick: () => void }) {
  return (
    <motion.button
      className="icon-btn cart-btn"
      onClick={onClick}
      whileHover={{ scale: 1.06 }}
      whileTap={{ scale: 0.92 }}
      animate={pulse > 0 ? { scale: [1, 1.12, 1], y: [0, -3, 0] } : {}}
      key={pulse}
      transition={SPRING.pop}
      aria-label={`Cart, ${count} item${count === 1 ? '' : 's'}`}
    >
      <IconBag size={18} />
      <AnimatePresence>
        {count > 0 && (
          <motion.span
            className="cart-badge"
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0, opacity: 0, transition: tween(DUR.fast, EASE.in) }}
            transition={SPRING.pop}
          >
            <AnimatePresence mode="popLayout" initial={false}>
              <motion.span
                key={count}
                initial={{ y: 9, opacity: 0, scale: 1.3 }}
                animate={{ y: 0, opacity: 1, scale: 1 }}
                exit={{ y: -9, opacity: 0, scale: 0.8 }}
                transition={SPRING.pop}
              >
                {count}
              </motion.span>
            </AnimatePresence>
          </motion.span>
        )}
      </AnimatePresence>
    </motion.button>
  )
}
