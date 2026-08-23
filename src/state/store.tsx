import { createContext, useContext, useMemo, useReducer, type ReactNode } from 'react'
import { computeUnitPrice, byId, type SizeId } from '../data/pizzas'

export type CartLine = {
  /** Stable per configuration, so the same pizza in two sizes stays two lines. */
  key: string
  pizzaId: string
  size: SizeId
  extras: string[]
  qty: number
  unitPrice: number
}

export type Order = {
  id: string
  placedAt: number
  lines: CartLine[]
  total: number
  /** Index into TRACKING_STAGES. */
  stage: number
}

export const TRACKING_STAGES = ['Confirmed', 'Preparing', 'Baking', 'On the way', 'Delivered'] as const

type State = {
  cart: CartLine[]
  favorites: string[]
  orders: Order[]
  promo: number
  /** Bumped on every add, so the cart badge can animate even when the count is unchanged. */
  addPulse: number
}

type Action =
  | { type: 'add'; pizzaId: string; size: SizeId; extras: string[]; qty: number }
  | { type: 'setQty'; key: string; qty: number }
  | { type: 'remove'; key: string }
  | { type: 'toggleFavorite'; pizzaId: string }
  | { type: 'placeOrder'; total: number }
  | { type: 'advanceOrder'; id: string }

const lineKey = (pizzaId: string, size: SizeId, extras: string[]) =>
  `${pizzaId}::${size}::${[...extras].sort().join(',')}`

const initialState: State = { cart: [], favorites: ['chicken-rocket'], orders: [], promo: 2.2, addPulse: 0 }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'add': {
      const pizza = byId(action.pizzaId)
      if (!pizza) return state
      const key = lineKey(action.pizzaId, action.size, action.extras)
      const unitPrice = computeUnitPrice(pizza, action.size, action.extras)
      const existing = state.cart.find((l) => l.key === key)
      const cart = existing
        ? state.cart.map((l) => (l.key === key ? { ...l, qty: l.qty + action.qty } : l))
        : [...state.cart, { key, pizzaId: action.pizzaId, size: action.size, extras: action.extras, qty: action.qty, unitPrice }]
      return { ...state, cart, addPulse: state.addPulse + 1 }
    }
    case 'setQty': {
      if (action.qty <= 0) return { ...state, cart: state.cart.filter((l) => l.key !== action.key) }
      return { ...state, cart: state.cart.map((l) => (l.key === action.key ? { ...l, qty: action.qty } : l)) }
    }
    case 'remove':
      return { ...state, cart: state.cart.filter((l) => l.key !== action.key) }
    case 'toggleFavorite':
      return {
        ...state,
        favorites: state.favorites.includes(action.pizzaId)
          ? state.favorites.filter((f) => f !== action.pizzaId)
          : [...state.favorites, action.pizzaId],
      }
    case 'placeOrder': {
      const order: Order = {
        id: `PZ-${1000 + state.orders.length * 7 + 42}`,
        placedAt: Date.now(),
        lines: state.cart,
        total: action.total,
        stage: 1,
      }
      return { ...state, orders: [order, ...state.orders], cart: [] }
    }
    case 'advanceOrder':
      return {
        ...state,
        orders: state.orders.map((o) =>
          o.id === action.id ? { ...o, stage: Math.min(o.stage + 1, TRACKING_STAGES.length - 1) } : o,
        ),
      }
  }
}

type Store = State & {
  dispatch: React.Dispatch<Action>
  count: number
  subtotal: number
  delivery: number
  tax: number
  total: number
}

const StoreCtx = createContext<Store | null>(null)

export const useStore = () => {
  const ctx = useContext(StoreCtx)
  if (!ctx) throw new Error('useStore must be used inside <StoreProvider>')
  return ctx
}

export function StoreProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState)

  const value = useMemo<Store>(() => {
    const count = state.cart.reduce((n, l) => n + l.qty, 0)
    const subtotal = Math.round(state.cart.reduce((s, l) => s + l.unitPrice * l.qty, 0) * 100) / 100
    const delivery = count === 0 ? 0 : 2.5
    const tax = Math.round(subtotal * 0.09 * 100) / 100
    const total = Math.round((subtotal + delivery + tax) * 100) / 100
    return { ...state, dispatch, count, subtotal, delivery, tax, total }
  }, [state])

  return <StoreCtx.Provider value={value}>{children}</StoreCtx.Provider>
}

/** Checkout applies the promo on top of the cart totals. */
export function checkoutTotals(subtotal: number, promo: number, delivery: number, tax: number) {
  const promoApplied = subtotal > 0 ? promo : 0
  return {
    orderAmount: subtotal,
    promo: promoApplied,
    delivery,
    tax,
    total: Math.round(Math.max(0, subtotal - promoApplied + delivery + tax) * 100) / 100,
  }
}
