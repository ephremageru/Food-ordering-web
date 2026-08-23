import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import type { TransitionKind } from '../motion/variants'

export type RouteName =
  | 'onboarding'
  | 'home'
  | 'search'
  | 'favorites'
  | 'orders'
  | 'profile'
  | 'product'
  | 'cart'
  | 'checkout'
  | 'success'

export type Route = {
  name: RouteName
  params?: Record<string, string>
  /** Set when the entry was pushed, so the exiting screen knows how to leave. */
  kind: TransitionKind
}

type NavState = {
  stack: Route[]
  /** 1 = moving forward, -1 = moving back. Drives which variant pair is used. */
  direction: 1 | -1
}

type NavApi = {
  route: Route
  stack: Route[]
  direction: 1 | -1
  push: (name: RouteName, opts?: { params?: Record<string, string>; kind?: TransitionKind }) => void
  /** Replaces the whole stack — used for tab switches and post-checkout resets. */
  reset: (name: RouteName, opts?: { params?: Record<string, string>; kind?: TransitionKind }) => void
  /** Swaps the top entry without growing the stack. */
  replace: (name: RouteName, opts?: { params?: Record<string, string>; kind?: TransitionKind }) => void
  back: () => void
  canGoBack: boolean
}

const NavContext = createContext<NavApi | null>(null)

export const useNav = () => {
  const ctx = useContext(NavContext)
  if (!ctx) throw new Error('useNav must be used inside <NavigationProvider>')
  return ctx
}

/** Tab roots are siblings — moving between them is never a push. */
export const TAB_ROUTES: RouteName[] = ['home', 'search', 'favorites', 'orders', 'profile']

function encode(stack: Route[]) {
  const top = stack[stack.length - 1]
  const params = top.params ? new URLSearchParams(top.params).toString() : ''
  return `#/${top.name}${params ? `?${params}` : ''}`
}

export function NavigationProvider({
  initial,
  children,
}: {
  initial: Route
  children: ReactNode
}) {
  const [state, setState] = useState<NavState>({ stack: [initial], direction: 1 })
  // Distinguishes our own history writes from a real browser Back press.
  const internal = useRef(false)

  const commit = useCallback((next: NavState, historyOp: 'push' | 'replace' | 'none') => {
    setState(next)
    if (historyOp === 'none') return
    internal.current = true
    const url = encode(next.stack)
    if (historyOp === 'push') window.history.pushState({ depth: next.stack.length }, '', url)
    else window.history.replaceState({ depth: next.stack.length }, '', url)
    // Released on the next task so the popstate we just caused (if any) is ignored.
    window.setTimeout(() => (internal.current = false), 0)
  }, [])

  const push: NavApi['push'] = useCallback(
    (name, opts) => {
      setState((s) => {
        const kind = opts?.kind ?? 'push'
        // A morph carries a shared element in *both* directions. The screen we
        // are leaving has to come back the same way, or the element would fade
        // back in with it instead of flying home, so it inherits the kind.
        const below = s.stack.slice(0, -1)
        const top = s.stack[s.stack.length - 1]
        const revealed = kind === 'morph' ? { ...top, kind: 'morph' as const } : top
        const next: NavState = {
          stack: [...below, revealed, { name, params: opts?.params, kind }],
          direction: 1,
        }
        internal.current = true
        window.history.pushState({ depth: next.stack.length }, '', encode(next.stack))
        window.setTimeout(() => (internal.current = false), 0)
        return next
      })
    },
    [],
  )

  const replace: NavApi['replace'] = useCallback(
    (name, opts) => {
      setState((s) => {
        const next: NavState = {
          stack: [...s.stack.slice(0, -1), { name, params: opts?.params, kind: opts?.kind ?? 'dissolve' }],
          direction: 1,
        }
        internal.current = true
        window.history.replaceState({ depth: next.stack.length }, '', encode(next.stack))
        window.setTimeout(() => (internal.current = false), 0)
        return next
      })
    },
    [],
  )

  const reset: NavApi['reset'] = useCallback(
    (name, opts) => {
      const next: NavState = {
        stack: [{ name, params: opts?.params, kind: opts?.kind ?? 'dissolve' }],
        direction: 1,
      }
      commit(next, 'replace')
    },
    [commit],
  )

  const back = useCallback(() => {
    setState((s) => {
      if (s.stack.length <= 1) return s
      internal.current = true
      window.history.back()
      window.setTimeout(() => (internal.current = false), 0)
      return { stack: s.stack.slice(0, -1), direction: -1 }
    })
  }, [])

  // A hardware/browser Back that we did not initiate still has to pop the stack.
  useEffect(() => {
    const onPop = () => {
      if (internal.current) return
      setState((s) => (s.stack.length <= 1 ? s : { stack: s.stack.slice(0, -1), direction: -1 }))
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])

  const value = useMemo<NavApi>(
    () => ({
      route: state.stack[state.stack.length - 1],
      stack: state.stack,
      direction: state.direction,
      push,
      reset,
      replace,
      back,
      canGoBack: state.stack.length > 1,
    }),
    [state, push, reset, replace, back],
  )

  return <NavContext.Provider value={value}>{children}</NavContext.Provider>
}
