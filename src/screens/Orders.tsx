import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { Pizza } from '../art/Pizza'
import { IconBack } from '../art/Icons'
import { AnimatedNumber } from '../motion/AnimatedNumber'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { byId } from '../data/pizzas'
import { TRACKING_STAGES, useStore, type Order } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { useReducedMotionPref } from '../motion/useMotionPrefs'

export function Orders() {
  const nav = useNav()
  const store = useStore()

  return (
    <>
      <div className="status-bar" />
      <div className="topbar">
        <motion.button className="icon-btn" onClick={() => nav.reset('home', { kind: 'dissolve' })} whileHover={{ scale: 1.06 }} whileTap={{ scale: 0.92 }} transition={SPRING.snappy} aria-label="Back to home">
          <IconBack size={18} />
        </motion.button>
        <h1 className="h-screen">My Orders</h1>
        <span />
      </div>
      <p className="cart-sub pad">
        {store.orders.length} order{store.orders.length === 1 ? '' : 's'} placed
      </p>

      <StaggerGroup className="scroll pad" stagger={STAGGER.normal} delayChildren={0.06}>
        {store.orders.length === 0 && (
          <StaggerItem>
            <div className="empty">
              <p className="h-section">No orders yet</p>
              <p className="sub">When you place an order it will be tracked here.</p>
            </div>
          </StaggerItem>
        )}
        {store.orders.map((order) => (
          <StaggerItem key={order.id}>
            <OrderCard order={order} />
          </StaggerItem>
        ))}
      </StaggerGroup>
    </>
  )
}

function OrderCard({ order }: { order: Order }) {
  const reduced = useReducedMotionPref()
  // The line starts empty and fills to the current stage, so opening the screen
  // shows the order *arriving* at its status rather than asserting it.
  const [progress, setProgress] = useState(reduced ? order.stage : 0)

  useEffect(() => {
    if (reduced) { setProgress(order.stage); return }
    const t = window.setTimeout(() => setProgress(order.stage), 180)
    return () => window.clearTimeout(t)
  }, [order.stage, reduced])

  const pct = (progress / (TRACKING_STAGES.length - 1)) * 100

  return (
    <article className="order-card">
      <header className="order-head">
        <strong>Order {order.id}</strong>
        <span className="sub">{TRACKING_STAGES[order.stage]} · Just now</span>
      </header>

      <div className="order-track">
        <div className="order-track-rail">
          <motion.div
            className="order-track-fill"
            initial={{ width: reduced ? `${pct}%` : 0 }}
            animate={{ width: `${pct}%` }}
            transition={reduced ? { duration: 0.001 } : { duration: 0.9, ease: EASE.out }}
          />
        </div>
        <div className="order-track-stops">
          {TRACKING_STAGES.map((stage, i) => {
            const reached = i <= progress
            return (
              <div className="order-stop" key={stage}>
                <motion.span
                  className={`order-dot ${reached ? 'is-on' : ''}`}
                  animate={{ scale: reached ? 1 : 0.72, backgroundColor: reached ? 'var(--accent)' : '#dcdce2' }}
                  transition={{ ...SPRING.pop, delay: reduced ? 0 : 0.16 + i * 0.16 }}
                />
                <motion.span
                  className="order-stop-label"
                  animate={{ opacity: reached ? 1 : 0.45, fontWeight: i === progress ? 700 : 500 }}
                  transition={tween(DUR.normal, EASE.out, reduced ? 0 : 0.16 + i * 0.16)}
                >
                  {stage}
                </motion.span>
              </div>
            )
          })}
        </div>
      </div>

      <ul className="order-lines">
        {order.lines.map((line) => {
          const pizza = byId(line.pizzaId)
          if (!pizza) return null
          return (
            <li key={line.key} className="order-line">
              <div className="cart-thumb order-thumb">
                <Pizza id={pizza.id} look={pizza.look} style={{ width: '100%', height: '100%' }} />
              </div>
              <div className="cart-meta">
                <h3>{pizza.name}</h3>
                <p className="sub">×{line.qty} · {pizza.tagline}</p>
                <span className="cart-price">
                  <span className="currency">$</span>
                  <AnimatedNumber value={Math.round(line.unitPrice * line.qty * 100) / 100} />
                </span>
              </div>
            </li>
          )
        })}
      </ul>

      <div className="sum-divider" />
      <div className="sum-row sum-row--total">
        <span>Total</span>
        <strong className="cart-total"><span className="currency">$</span><AnimatedNumber value={order.total} /></strong>
      </div>
    </article>
  )
}
