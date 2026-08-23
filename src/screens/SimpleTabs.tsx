import { useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { PizzaCard } from '../components/PizzaCard'
import { IconSearch } from '../art/Icons'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { listGroup } from '../motion/variants'
import { SPRING, STAGGER } from '../motion/tokens'
import { PIZZAS } from '../data/pizzas'
import { useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { useHeroFlight } from '../state/heroFlight'

/** Search: the grid reflows live as the query narrows it. */
export function SearchScreen() {
  const [q, setQ] = useState('')
  const nav = useNav()
  const store = useStore()
  const flight = useHeroFlight()

  const results = useMemo(() => {
    const needle = q.trim().toLowerCase()
    if (!needle) return PIZZAS
    return PIZZAS.filter((p) => `${p.name} ${p.tagline}`.toLowerCase().includes(needle))
  }, [q])

  const open = (id: string) => {
    flight.setFlying(id)
    nav.push('product', { params: { id }, kind: 'morph' })
  }

  return (
    <>
      <div className="status-bar" />
      <StaggerGroup className="pad" stagger={STAGGER.tight}>
        <StaggerItem>
          <h1 className="display" style={{ marginTop: 8 }}>Search</h1>
        </StaggerItem>
        <StaggerItem>
          <div className="search" style={{ marginTop: 14 }}>
            <IconSearch size={17} className="search-icon" />
            <input autoFocus value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search for Pizza" aria-label="Search for pizza" />
          </div>
        </StaggerItem>
      </StaggerGroup>

      <div className="scroll">
        <motion.ul className="card-grid" style={{ paddingTop: 56 }} variants={listGroup(STAGGER.tight, 0.04)} initial="initial" animate="animate">
          <AnimatePresence mode="popLayout" initial={false}>
            {results.map((p) => (
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
        {results.length === 0 && (
          <motion.div className="empty" initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={SPRING.soft}>
            <p className="h-section">Nothing matches “{q}”</p>
            <p className="sub">Try a topping, or a name like “Formaggi”.</p>
          </motion.div>
        )}
      </div>
    </>
  )
}

/** Favourites: removing one is a layout animation, never a page rebuild. */
export function FavoritesScreen() {
  const nav = useNav()
  const store = useStore()
  const flight = useHeroFlight()
  const favorites = PIZZAS.filter((p) => store.favorites.includes(p.id))

  const open = (id: string) => {
    flight.setFlying(id)
    nav.push('product', { params: { id }, kind: 'morph' })
  }

  return (
    <>
      <div className="status-bar" />
      <StaggerGroup className="pad" stagger={STAGGER.tight}>
        <StaggerItem>
          <h1 className="display" style={{ marginTop: 8 }}>Favourites</h1>
        </StaggerItem>
        <StaggerItem>
          <p className="sub" style={{ marginTop: 6 }}>{favorites.length} saved</p>
        </StaggerItem>
      </StaggerGroup>
      <div className="scroll">
        <motion.ul className="card-grid" style={{ paddingTop: 56 }} variants={listGroup(STAGGER.tight, 0.04)} initial="initial" animate="animate" layout>
          <AnimatePresence mode="popLayout" initial={false}>
            {favorites.map((p) => (
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
        {favorites.length === 0 && (
          <motion.div className="empty" initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={SPRING.soft}>
            <p className="h-section">No favourites yet</p>
            <p className="sub">Tap the heart on a pizza to save it here.</p>
          </motion.div>
        )}
      </div>
    </>
  )
}

export function ProfileScreen() {
  const store = useStore()
  const rows = [
    ['Orders placed', String(store.orders.length)],
    ['Saved pizzas', String(store.favorites.length)],
    ['Delivery address', '11/2 Diriyah, Riyadh'],
    ['Payment', 'Master Card ···· 8463'],
  ]
  return (
    <>
      <div className="status-bar" />
      <StaggerGroup className="pad" stagger={STAGGER.normal}>
        <StaggerItem>
          <div className="profile-head">
            <div className="avatar avatar--lg" aria-hidden>
              <svg viewBox="0 0 40 40">
                <circle cx="20" cy="20" r="20" fill="#e6ddd4" />
                <circle cx="20" cy="16" r="7" fill="#b9a794" />
                <path d="M6 40c1.6-8 7.2-12 14-12s12.4 4 14 12Z" fill="#2f2f36" />
              </svg>
            </div>
            <div>
              <h1 className="h-section" style={{ fontSize: 18 }}>Orb Ephrem</h1>
              <p className="sub">ephy1627@gmail.com</p>
            </div>
          </div>
        </StaggerItem>
        {rows.map(([k, v]) => (
          <StaggerItem key={k}>
            <div className="profile-row">
              <span className="sub">{k}</span>
              <strong>{v}</strong>
            </div>
          </StaggerItem>
        ))}
      </StaggerGroup>
    </>
  )
}
