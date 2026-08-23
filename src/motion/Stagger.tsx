import type { ReactNode } from 'react'
import { motion, type Variants } from 'framer-motion'
import { listGroup, listItem } from './variants'
import { STAGGER } from './tokens'

/**
 * Orchestrates a staggered entrance for its children.
 * Screens use this so ordering is declared by markup order, not by hand-tuned
 * delays scattered through the tree.
 */
export function StaggerGroup({
  children,
  stagger = STAGGER.normal,
  delayChildren = 0,
  className,
  style,
}: {
  children: ReactNode
  stagger?: number
  delayChildren?: number
  className?: string
  style?: React.CSSProperties
}) {
  return (
    <motion.div
      className={className}
      style={style}
      variants={listGroup(stagger, delayChildren)}
      initial="initial"
      animate="animate"
      exit="exit"
    >
      {children}
    </motion.div>
  )
}

export function StaggerItem({
  children,
  className,
  variants = listItem,
  style,
}: {
  children: ReactNode
  className?: string
  variants?: Variants
  style?: React.CSSProperties
}) {
  return (
    <motion.div className={className} style={style} variants={variants}>
      {children}
    </motion.div>
  )
}
