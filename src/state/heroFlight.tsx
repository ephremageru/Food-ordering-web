import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'

type Flight = {
  /** The pizza currently travelling between screens, if any. */
  flyingId: string | null
  setFlying: (id: string | null) => void
}

const Ctx = createContext<Flight | null>(null)

export const useHeroFlight = () => {
  const ctx = useContext(Ctx)
  if (!ctx) throw new Error('useHeroFlight must be used inside <HeroFlightProvider>')
  return ctx
}

/**
 * Tracks which pizza owns the shared-element slot.
 *
 * Without this, a card and the detail hero would both render an element with
 * the same `layoutId` while the screens cross over, and the pizza would appear
 * twice. The card yields its copy for the duration of the flight.
 */
export function HeroFlightProvider({ children }: { children: ReactNode }) {
  const [flyingId, setFlyingId] = useState<string | null>(null)
  const setFlying = useCallback((id: string | null) => setFlyingId(id), [])
  const value = useMemo(() => ({ flyingId, setFlying }), [flyingId, setFlying])
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>
}
