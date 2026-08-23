import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { IconBack, IconCheck, IconChevron, IconMore, IconPin, IconPlus, LogoApple, LogoMastercard, LogoPaypal } from '../art/Icons'
import { AnimatedNumber } from '../motion/AnimatedNumber'
import { Pressable } from '../motion/Pressable'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { checkoutTotals, useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { Sheet } from '../motion/Sheet'

const METHODS = [
  { id: 'mastercard', label: 'Master Card', detail: '•••••••• 8463', Logo: LogoMastercard },
  { id: 'paypal', label: 'Paypal', detail: 'orb•••••@gmail.com', Logo: LogoPaypal },
  { id: 'apple', label: 'Apple Pay', detail: '', Logo: LogoApple },
]

type PayPhase = 'idle' | 'processing'

export function Checkout() {
  const nav = useNav()
  const store = useStore()
  const [method, setMethod] = useState('mastercard')
  const [phase, setPhase] = useState<PayPhase>('idle')
  const [sheetOpen, setSheetOpen] = useState(false)

  const totals = checkoutTotals(store.subtotal, store.promo, store.delivery, store.tax)

  const pay = () => {
    if (phase !== 'idle') return
    setPhase('processing')
    window.setTimeout(() => {
      store.dispatch({ type: 'placeOrder', total: totals.total })
      nav.replace('success', { kind: 'morph' })
    }, 1150)
  }

  return (
    <>
      <div className="status-bar" />
      <div className="topbar">
        <motion.button className="icon-btn" onClick={() => nav.back()} whileHover={{ scale: 1.06 }} whileTap={{ scale: 0.92 }} transition={SPRING.snappy} aria-label="Back">
          <IconBack size={18} />
        </motion.button>
        <h1 className="h-screen">Checkout</h1>
        <motion.button className="icon-btn" whileHover={{ scale: 1.06 }} whileTap={{ scale: 0.92 }} transition={SPRING.snappy} aria-label="More options" onClick={() => setSheetOpen(true)}>
          <IconMore size={18} />
        </motion.button>
      </div>

      {/* Sections arrive in reading order, close enough together that the
          sequence registers as pacing rather than as waiting. */}
      <StaggerGroup className="scroll pad co-scroll" stagger={STAGGER.relaxed} delayChildren={0.08}>
        <StaggerItem>
          <section className="co-card">
            {METHODS.map(({ id, label, detail, Logo }) => {
              const active = method === id
              return (
                <motion.button
                  key={id}
                  className="co-method"
                  onClick={() => setMethod(id)}
                  whileTap={{ scale: 0.985 }}
                  transition={SPRING.snappy}
                  role="radio"
                  aria-checked={active}
                >
                  <span className="co-logo"><Logo size={24} /></span>
                  <span className="co-method-label">{label}</span>
                  <span className="co-method-detail">{detail}</span>
                  {/* The indicator fills and stamps a check rather than
                      switching state — border, fill and mark each animate. */}
                  <motion.span
                    className="co-radio"
                    animate={{
                      backgroundColor: active ? 'var(--dark)' : 'rgba(0,0,0,0)',
                      borderColor: active ? 'var(--dark)' : 'var(--muted-2)',
                      scale: active ? [1, 1.18, 1] : 1,
                    }}
                    transition={{ ...SPRING.pop, backgroundColor: tween(DUR.quick), borderColor: tween(DUR.quick) }}
                  >
                    <AnimatePresence>
                      {active && (
                        <motion.span
                          initial={{ scale: 0, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          exit={{ scale: 0, opacity: 0, transition: tween(DUR.fast, EASE.in) }}
                          transition={{ ...SPRING.pop, delay: 0.04 }}
                          style={{ display: 'grid', placeItems: 'center', color: '#fff' }}
                        >
                          <IconCheck size={11} strokeWidth={3.2} />
                        </motion.span>
                      )}
                    </AnimatePresence>
                  </motion.span>
                </motion.button>
              )
            })}
            <Pressable className="co-addmethod" press={0.985} onClick={() => setSheetOpen(true)}>
              <IconPlus size={15} /> Add Payment Method
            </Pressable>
          </section>
        </StaggerItem>

        <StaggerItem>
          <section className="co-card co-address">
            <h2 className="h-section">Delivery Address</h2>
            <div className="co-address-row">
              <IconPin size={19} />
              <div>
                <strong>11/2 Diriyah, Road no A3</strong>
                <span className="sub">Riyadh (SA)</span>
              </div>
              <IconChevron size={17} />
            </div>
          </section>
        </StaggerItem>

        <StaggerItem>
          <section className="co-card">
            <h2 className="h-section">Order Summary</h2>
            <div className="sum-row"><span>Order Amount</span><strong><AnimatedNumber value={totals.orderAmount} prefix="$" /></strong></div>
            <div className="sum-row"><span>Promo-code</span><strong><AnimatedNumber value={totals.promo} prefix="-$" /></strong></div>
            <div className="sum-row"><span>Delivery</span><strong><AnimatedNumber value={totals.delivery} prefix="$" /></strong></div>
            <div className="sum-row"><span>Tax</span><strong><AnimatedNumber value={totals.tax} prefix="$" /></strong></div>
            <div className="sum-divider" />
            <div className="sum-row sum-row--total">
              <span>Total Amount</span>
              <strong className="cart-total"><span className="currency">$</span><AnimatedNumber value={totals.total} /></strong>
            </div>
          </section>
        </StaggerItem>
      </StaggerGroup>

      <div className="bottom-dock">
        {/* Fixed height and a centred swap keep the button from resizing when
            the label changes — a jumping pay button reads as an error. */}
        <Pressable className="primary-btn co-pay" onClick={pay} press={0.975} disabled={phase !== 'idle'}>
          <motion.span
            className="co-pay-inner"
            animate={{ opacity: phase === 'processing' ? 0.85 : 1 }}
            transition={tween(DUR.fast)}
          >
            <AnimatePresence mode="wait" initial={false}>
              {phase === 'idle' ? (
                <motion.span key="idle" initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }} transition={tween(DUR.fast, EASE.out)}>
                  Pay Now
                </motion.span>
              ) : (
                <motion.span key="busy" className="co-pay-busy" initial={{ opacity: 0, y: 6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -6 }} transition={tween(DUR.fast, EASE.out)}>
                  <Spinner />
                  Processing…
                </motion.span>
              )}
            </AnimatePresence>
          </motion.span>
        </Pressable>
      </div>

      <Sheet open={sheetOpen} onClose={() => setSheetOpen(false)} label="Payment options">
        <h2 className="h-section" style={{ marginBottom: 4 }}>Payment options</h2>
        <p className="sub" style={{ marginBottom: 16 }}>Cards are stored by your wallet, not by us.</p>
        {['Add debit card', 'Add credit card', 'Pay with cash on delivery'].map((label, i) => (
          <motion.button
            key={label}
            className="sheet-option"
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ ...SPRING.soft, delay: 0.04 + i * 0.05 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => setSheetOpen(false)}
          >
            {label}
            <IconChevron size={16} />
          </motion.button>
        ))}
      </Sheet>
    </>
  )
}

function Spinner() {
  return (
    <motion.svg
      width="16" height="16" viewBox="0 0 24 24" fill="none"
      animate={{ rotate: 360 }}
      transition={{ duration: 0.85, repeat: Infinity, ease: 'linear' }}
      aria-hidden
    >
      <circle cx="12" cy="12" r="9" stroke="rgba(255,255,255,0.28)" strokeWidth="3" />
      <path d="M21 12a9 9 0 0 0-9-9" stroke="#fff" strokeWidth="3" strokeLinecap="round" />
    </motion.svg>
  )
}
