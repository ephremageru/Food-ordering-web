import { AnimatePresence, motion } from 'framer-motion'
import { Pizza } from '../art/Pizza'
import { IconBack, IconMinus, IconPlus } from '../art/Icons'
import { AnimatedNumber } from '../motion/AnimatedNumber'
import { Pressable } from '../motion/Pressable'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { SIZES, byId } from '../data/pizzas'
import { useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'

export function Cart() {
  const nav = useNav()
  const store = useStore()

  return (
    <>
      <div className="status-bar" />
      <div className="topbar">
        <motion.button className="icon-btn" onClick={() => nav.back()} whileHover={{ scale: 1.06 }} whileTap={{ scale: 0.92 }} transition={SPRING.snappy} aria-label="Back">
          <IconBack size={18} />
        </motion.button>
        <h1 className="h-screen">My Cart</h1>
        <span />
      </div>
      <p className="cart-sub pad">
        {store.count} item{store.count === 1 ? '' : 's'} from your menu
      </p>

      <div className="scroll pad">
        {/* `layout` on every row means a removal is a reflow, not a repaint:
            the rows below rise into the gap under their own spring. */}
        <motion.ul className="cart-list" layout>
          <AnimatePresence initial={false} mode="popLayout">
            {store.cart.map((line) => {
              const pizza = byId(line.pizzaId)
              if (!pizza) return null
              const sizeLabel = SIZES.find((s) => s.id === line.size)?.label ?? ''
              return (
                <motion.li
                  key={line.key}
                  className="cart-row"
                  layout
                  initial={{ opacity: 0, y: 16, scale: 0.96 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95, height: 0, marginBottom: 0, paddingTop: 0, paddingBottom: 0, transition: tween(DUR.normal, EASE.in) }}
                  transition={SPRING.soft}
                >
                  <div className="cart-thumb">
                    <Pizza id={pizza.id} look={pizza.look} style={{ width: '100%', height: '100%' }} />
                  </div>
                  <div className="cart-meta">
                    <h3>{pizza.name}</h3>
                    <p className="sub">
                      {sizeLabel}
                      {line.extras.length > 0 && ` · +${line.extras.length} extra`}
                    </p>
                    <span className="cart-price">
                      <span className="currency">$</span>
                      <AnimatedNumber value={Math.round(line.unitPrice * line.qty * 100) / 100} />
                    </span>
                  </div>
                  <div className="cart-stepper">
                    <motion.button whileTap={{ scale: 0.85 }} transition={SPRING.snappy} onClick={() => store.dispatch({ type: 'setQty', key: line.key, qty: line.qty + 1 })} aria-label="Increase quantity">
                      <IconPlus size={14} />
                    </motion.button>
                    <span className="cart-qty">
                      <AnimatePresence mode="popLayout" initial={false}>
                        <motion.span
                          key={line.qty}
                          initial={{ y: 10, opacity: 0, scale: 1.2 }}
                          animate={{ y: 0, opacity: 1, scale: 1 }}
                          exit={{ y: -10, opacity: 0, scale: 0.85 }}
                          transition={SPRING.pop}
                        >
                          {line.qty}
                        </motion.span>
                      </AnimatePresence>
                    </span>
                    <motion.button whileTap={{ scale: 0.85 }} transition={SPRING.snappy} onClick={() => store.dispatch({ type: 'setQty', key: line.key, qty: line.qty - 1 })} aria-label={line.qty === 1 ? 'Remove item' : 'Decrease quantity'}>
                      <IconMinus size={14} />
                    </motion.button>
                  </div>
                </motion.li>
              )
            })}
          </AnimatePresence>
        </motion.ul>

        {store.count === 0 && (
          <motion.div className="empty" initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={SPRING.soft}>
            <p className="h-section">Your cart is empty</p>
            <p className="sub">Pick something from the menu and it will show up here.</p>
            <Pressable className="empty-cta" onClick={() => nav.reset('home', { kind: 'dissolve' })}>
              Browse pizzas
            </Pressable>
          </motion.div>
        )}
      </div>

      <StaggerGroup className="cart-foot" stagger={STAGGER.tight} delayChildren={0.12}>
        <StaggerItem>
          <div className="sum-row">
            <span>Subtotal</span>
            <strong><AnimatedNumber value={store.subtotal} prefix="$" /></strong>
          </div>
        </StaggerItem>
        <StaggerItem>
          <div className="sum-row">
            <span>Delivery</span>
            <strong><AnimatedNumber value={store.delivery} prefix="$" /></strong>
          </div>
        </StaggerItem>
        <StaggerItem>
          <div className="sum-row">
            <span>Tax</span>
            <strong><AnimatedNumber value={store.tax} prefix="$" /></strong>
          </div>
        </StaggerItem>
        <StaggerItem>
          <div className="sum-divider" />
          <div className="sum-row sum-row--total">
            <span>Total</span>
            <strong className="cart-total">
              <span className="currency">$</span>
              <AnimatedNumber value={store.total} />
            </strong>
          </div>
        </StaggerItem>
        <StaggerItem>
          <Pressable
            className="primary-btn"
            onClick={() => nav.push('checkout', { kind: 'push' })}
            disabled={store.count === 0}
            style={{ opacity: store.count === 0 ? 0.4 : 1 }}
          >
            Checkout
          </Pressable>
        </StaggerItem>
      </StaggerGroup>
    </>
  )
}
