import { motion } from 'framer-motion'
import { Pizza, type PizzaLook } from '../art/Pizza'
import { IconPlus } from '../art/Icons'
import { DUR, EASE, SPRING, tween } from '../motion/tokens'
import { cardItem } from '../motion/variants'
import type { Pizza as PizzaModel } from '../data/pizzas'

/** The id every shared-element pizza uses. One place, so card and hero agree. */
export const pizzaLayoutId = (id: string) => `pizza-${id}`

export function PizzaCard({
  pizza,
  onOpen,
  onQuickAdd,
  /** Suppressed while this card's pizza is flying to the detail hero. */
  heroActive,
}: {
  pizza: PizzaModel
  onOpen: () => void
  onQuickAdd: () => void
  heroActive: boolean
}) {
  return (
    <motion.li className="card-cell" variants={cardItem} layout>
      <motion.div
        className="card"
        onClick={onOpen}
        whileHover={{ y: -4, boxShadow: 'var(--shadow-card-hover)' }}
        whileTap={{ scale: 0.97 }}
        transition={{ ...SPRING.snappy, boxShadow: tween(DUR.quick, EASE.out) }}
        role="button"
        tabIndex={0}
        aria-label={`${pizza.name}, $${pizza.price.toFixed(2)}`}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onOpen() }
        }}
      >
        <div className="card-art">
          {/* While the hero is flying, the card leaves a hole rather than a
              second copy — otherwise the same pizza would exist twice. */}
          {!heroActive && (
            <motion.div className="card-pizza" layoutId={pizzaLayoutId(pizza.id)} transition={SPRING.hero}>
              <Pizza id={pizza.id} look={pizza.look as PizzaLook} style={{ width: '100%', height: '100%' }} />
            </motion.div>
          )}
        </div>

        <div className="card-body">
          <span className="card-badge">-{pizza.discount}%</span>
          <h3 className="card-title">{pizza.name}</h3>
          <p className="card-tagline">{pizza.tagline}</p>
          <div className="card-foot">
            <span className="card-price">
              <span className="currency">$</span>
              {pizza.price.toFixed(2)}
            </span>
            <motion.button
              className="card-add"
              onClick={(e) => { e.stopPropagation(); onQuickAdd() }}
              whileHover={{ scale: 1.09, backgroundColor: 'var(--accent)', color: '#fff' }}
              whileTap={{ scale: 0.9 }}
              transition={SPRING.snappy}
              aria-label={`Add ${pizza.name} to cart`}
            >
              <IconPlus size={17} />
            </motion.button>
          </div>
        </div>
      </motion.div>
    </motion.li>
  )
}
