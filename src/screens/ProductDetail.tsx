import { useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { Pizza } from '../art/Pizza'
import { pizzaLayoutId } from '../components/PizzaCard'
import { IconBack, IconCheck, IconFlame, IconHeart, IconMinus, IconPlus, IconRuler, IconStar, IconBag } from '../art/Icons'
import { AnimatedNumber } from '../motion/AnimatedNumber'
import { Pressable } from '../motion/Pressable'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { EXTRAS, SIZES, byId, computeUnitPrice, type SizeId } from '../data/pizzas'
import { useStore } from '../state/store'
import { useNav } from '../nav/NavigationProvider'
import { useHeroFlight } from '../state/heroFlight'
import { useReducedMotionPref } from '../motion/useMotionPrefs'
import { IngredientSprite } from '../art/HeroScene'

type Phase = 'idle' | 'flying' | 'morphing'

export function ProductDetail({ id }: { id: string }) {
  const nav = useNav()
  const store = useStore()
  const flight = useHeroFlight()
  const reduced = useReducedMotionPref()

  const pizza = byId(id)
  const [size, setSize] = useState<SizeId>('medium')
  const [extras, setExtras] = useState<string[]>([])
  const [qty, setQty] = useState(1)
  const [qtyPulse, setQtyPulse] = useState(0)
  const [phase, setPhase] = useState<Phase>('idle')

  const sizeSpec = SIZES.find((s) => s.id === size)!
  const unitPrice = useMemo(
    () => (pizza ? computeUnitPrice(pizza, size, extras) : 0),
    [pizza, size, extras],
  )

  if (!pizza) return null

  const favorite = store.favorites.includes(pizza.id)

  const goBack = () => {
    // Hand the shared slot back to the card in the same commit as the pop, so
    // the pizza flies home instead of dissolving.
    flight.setFlying(null)
    nav.back()
  }

  const toggleExtra = (extraId: string) =>
    setExtras((e) => (e.includes(extraId) ? e.filter((x) => x !== extraId) : [...e, extraId]))

  const bumpQty = (delta: number) => {
    setQty((q) => Math.max(1, Math.min(20, q + delta)))
    setQtyPulse((p) => p + 1)
  }

  /**
   * Add to cart, staged.
   *
   * 1. the pizza shrinks into the button (a layout animation on the hero)
   * 2. the button collapses from a pill into a disc
   * 3. the cart takes over
   *
   * Each stage starts before the previous finishes, so it reads as one gesture.
   */
  const addToCart = () => {
    if (phase !== 'idle') return
    store.dispatch({ type: 'add', pizzaId: pizza.id, size, extras, qty })

    if (reduced) {
      flight.setFlying(null)
      nav.push('cart', { kind: 'dissolve' })
      return
    }

    setPhase('flying')
    window.setTimeout(() => setPhase('morphing'), 300)
    window.setTimeout(() => {
      flight.setFlying(null)
      nav.push('cart', { kind: 'morph' })
    }, 640)
  }

  const committing = phase !== 'idle'

  return (
    <>
      <div className="status-bar" />

      {/* Everything except the pizza recedes while the cart takes over. */}
      <motion.div
        className="pd-body"
        animate={committing ? { opacity: 0, filter: 'blur(7px)' } : { opacity: 1, filter: 'blur(0px)' }}
        transition={tween(DUR.normal, EASE.out)}
      >
        <div className="topbar pd-topbar">
          <motion.button
            className="icon-btn"
            onClick={goBack}
            whileHover={{ scale: 1.06 }}
            whileTap={{ scale: 0.92 }}
            transition={SPRING.snappy}
            aria-label="Back"
          >
            <IconBack size={18} />
          </motion.button>
          <span />
          <motion.button
            className="icon-btn"
            onClick={() => store.dispatch({ type: 'toggleFavorite', pizzaId: pizza.id })}
            whileHover={{ scale: 1.06 }}
            whileTap={{ scale: 0.86 }}
            animate={favorite ? { scale: [1, 1.22, 1] } : { scale: 1 }}
            transition={SPRING.pop}
            aria-pressed={favorite}
            aria-label={favorite ? 'Remove from favourites' : 'Add to favourites'}
            style={{ color: favorite ? 'var(--accent)' : 'var(--ink)' }}
          >
            <IconHeart size={18} filled={favorite} />
          </motion.button>
        </div>

        <div className="scroll">
          {/* Content enters after the hero is already in motion, in groups —
              never letter by letter. */}
          <StaggerGroup className="pd-info pad" stagger={STAGGER.normal} delayChildren={0.16}>
            <StaggerItem>
              <h1 className="pd-title">{pizza.name}</h1>
              <p className="pd-tagline">{pizza.tagline}</p>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-rating">
                {[0, 1, 2, 3, 4].map((i) => (
                  <IconStar key={i} size={12} filled={i < Math.round(pizza.rating)} />
                ))}
                <span className="pd-rating-value">({pizza.rating})</span>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-price">
                <span className="currency">$</span>
                <AnimatedNumber value={unitPrice} />
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-fact">
                <span className="label"><IconFlame size={12} /> Calories</span>
                <strong>{Math.round(pizza.calories * sizeSpec.priceFactor)} Cal</strong>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-fact">
                <span className="label"><IconRuler size={12} /> Diameter / Portion</span>
                <strong>{sizeSpec.diameter}&apos; / {sizeSpec.slices} Slices</strong>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-group pd-group--first">
                <span className="label">Size</span>
                <div className="pd-sizes" role="radiogroup" aria-label="Size">
                  {/* The selected pill is one permanently mounted element that
                      slides between columns. A `layoutId` swap would leave a
                      pending projection behind and stall this screen's exit. */}
                  <motion.span
                    layout
                    className="pd-size-pill"
                    style={{ '--i': SIZES.findIndex((s) => s.id === size) } as React.CSSProperties}
                    transition={SPRING.snappy}
                  />
                  {SIZES.map((s) => {
                    const active = s.id === size
                    return (
                      <motion.button
                        key={s.id}
                        className={`pd-size ${active ? 'is-active' : ''}`}
                        onClick={() => setSize(s.id)}
                        whileTap={{ scale: 0.95 }}
                        transition={SPRING.snappy}
                        role="radio"
                        aria-checked={active}
                      >
                        <span className="pd-size-label">{s.label}</span>
                      </motion.button>
                    )
                  })}
                </div>
              </div>
            </StaggerItem>

            <StaggerItem>
              <div className="pd-group">
                <span className="label">Extra topping</span>
                <div className="pd-extras">
                  {EXTRAS.map((e) => {
                    const on = extras.includes(e.id)
                    return (
                      <motion.button
                        key={e.id}
                        className={`pd-extra ${on ? 'is-on' : ''}`}
                        onClick={() => toggleExtra(e.id)}
                        animate={on ? { scale: [1, 1.05, 1] } : { scale: 1 }}
                        whileTap={{ scale: 0.95 }}
                        transition={SPRING.pop}
                        aria-pressed={on}
                      >
                        <span className="pd-extra-mark">
                          <AnimatePresence mode="wait" initial={false}>
                            {on ? (
                              <motion.span
                                key="on"
                                initial={{ scale: 0, rotate: -30 }}
                                animate={{ scale: 1, rotate: 0 }}
                                exit={{ scale: 0, transition: tween(DUR.fast, EASE.in) }}
                                transition={SPRING.pop}
                                className="pd-extra-check"
                              >
                                <IconCheck size={11} strokeWidth={3} />
                              </motion.span>
                            ) : (
                              <motion.span
                                key="off"
                                className="pd-extra-dot"
                                initial={{ scale: 0.7, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                exit={{ scale: 0.7, opacity: 0 }}
                                transition={tween(DUR.fast)}
                              >
                                <IngredientSprite kind={e.icon} />
                              </motion.span>
                            )}
                          </AnimatePresence>
                        </span>
                        {e.label}
                        <AnimatePresence initial={false}>
                          {on && (
                            <motion.span
                              className="pd-extra-price"
                              initial={{ opacity: 0, width: 0, x: -4 }}
                              animate={{ opacity: 1, width: 'auto', x: 0 }}
                              exit={{ opacity: 0, width: 0, x: -4 }}
                              transition={SPRING.snappy}
                            >
                              +${e.price.toFixed(2)}
                            </motion.span>
                          )}
                        </AnimatePresence>
                      </motion.button>
                    )
                  })}
                </div>
              </div>
            </StaggerItem>

            <StaggerItem>
              <p className="pd-desc">{pizza.description}</p>
            </StaggerItem>
          </StaggerGroup>
        </div>
      </motion.div>

      {/* --- Hero pizza -------------------------------------------------- */}
      {/* Lives outside .pd-body so the blur above never touches it: this is the
          one element that must stay sharp all the way through the handoff. */}
      <motion.div
        className={`pd-hero ${phase === 'idle' ? '' : 'pd-hero--docked'}`}
        layoutId={pizzaLayoutId(pizza.id)}
        transition={SPRING.hero}
        animate={{ opacity: phase === 'morphing' ? 0 : 1 }}
        style={{ pointerEvents: 'none' }}
      >
        <motion.div
          className="pd-hero-inner"
          animate={{ scale: phase === 'idle' ? sizeSpec.scale : 1 }}
          transition={SPRING.soft}
        >
          <Pizza id={pizza.id} look={pizza.look} style={{ width: '100%', height: '100%' }} />
        </motion.div>
      </motion.div>

      {/* --- Dock --------------------------------------------------------- */}
      <motion.div
        className="pd-dock"
        animate={phase === 'morphing' ? { opacity: 0 } : { opacity: 1 }}
        transition={tween(DUR.normal, EASE.out)}
      >
        <motion.div
          className="pd-qty"
          animate={committing ? { opacity: 0, scale: 0.9, x: -12 } : { opacity: 1, scale: 1, x: 0 }}
          transition={SPRING.snappy}
        >
          <motion.button onClick={() => bumpQty(-1)} whileTap={{ scale: 0.85 }} transition={SPRING.snappy} aria-label="Decrease quantity" disabled={qty <= 1}>
            <IconMinus size={15} />
          </motion.button>
          <span className="pd-qty-value">
            <motion.span key={qtyPulse} initial={{ scale: 1.25 }} animate={{ scale: 1 }} transition={SPRING.pop}>
              {qty}
            </motion.span>
          </span>
          <motion.button onClick={() => bumpQty(1)} whileTap={{ scale: 0.85 }} transition={SPRING.snappy} aria-label="Increase quantity">
            <IconPlus size={15} />
          </motion.button>
        </motion.div>

        {/* The pill collapses to a disc rather than swapping to a different
            control — the button you pressed is the thing that carries you over. */}
        <motion.div
          className="pd-add-wrap"
          animate={committing ? { flexGrow: 0, width: 56 } : { flexGrow: 1, width: '100%' }}
          transition={SPRING.sheet}
        >
          <Pressable className="primary-btn pd-add" onClick={addToCart} press={0.97} disabled={committing}>
            <span className="pd-add-inner">
              <IconBag size={17} />
              <motion.span
                className="pd-add-text"
                animate={committing ? { opacity: 0, width: 0, marginLeft: 0 } : { opacity: 1, width: 'auto', marginLeft: 8 }}
                transition={tween(DUR.quick, EASE.out)}
              >
                Add to cart
              </motion.span>
            </span>
          </Pressable>
        </motion.div>
      </motion.div>
    </>
  )
}
