import { AnimatePresence, motion } from 'framer-motion'
import { createContext, useCallback, useContext, useMemo, useRef, useState, type ReactNode } from 'react'
import { DUR, EASE, SPRING, tween } from './tokens'

type Toast = { id: number; text: string; icon?: ReactNode }
const ToastCtx = createContext<(text: string, icon?: ReactNode) => void>(() => {})

export const useToast = () => useContext(ToastCtx)

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([])
  const seq = useRef(0)

  const push = useCallback((text: string, icon?: ReactNode) => {
    const id = ++seq.current
    setToasts((t) => [...t.slice(-2), { id, text, icon }])
    window.setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 2200)
  }, [])

  const value = useMemo(() => push, [push])

  return (
    <ToastCtx.Provider value={value}>
      {children}
      <div className="toast-layer" aria-live="polite">
        <AnimatePresence initial={false}>
          {toasts.map((t) => (
            <motion.div
              key={t.id}
              className="toast"
              layout
              initial={{ opacity: 0, y: 18, scale: 0.94 }}
              animate={{ opacity: 1, y: 0, scale: 1, transition: SPRING.pop }}
              exit={{ opacity: 0, y: -8, scale: 0.97, transition: tween(DUR.quick, EASE.in) }}
            >
              {t.icon && <span className="toast-icon">{t.icon}</span>}
              <span>{t.text}</span>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </ToastCtx.Provider>
  )
}
