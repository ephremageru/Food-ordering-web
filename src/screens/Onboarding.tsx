import { useState } from 'react'
import { motion } from 'framer-motion'
import { HeroScene } from '../art/HeroScene'
import { Pressable } from '../motion/Pressable'
import { StaggerGroup, StaggerItem } from '../motion/Stagger'
import { DUR, EASE, SPRING, STAGGER, tween } from '../motion/tokens'
import { useNav } from '../nav/NavigationProvider'

/**
 * Stage 1 of the app. Everything enters in sequence — hero, headline, subtitle,
 * button — so the screen assembles rather than appearing.
 */
export function Onboarding() {
  const nav = useNav()
  const [leaving, setLeaving] = useState(false)

  const start = () => {
    if (leaving) return
    setLeaving(true)
    // Navigate on the next frame: the press compression and the screen
    // transition overlap instead of queueing, so the tap feels instant.
    requestAnimationFrame(() => nav.reset('home', { kind: 'reveal' }))
  }

  return (
    <div className="onboarding">
      <motion.div
        className="onboarding-art"
        initial={{ opacity: 0, scale: 0.92, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ ...SPRING.hero, opacity: tween(DUR.medium, EASE.out) }}
      >
        <HeroScene />
        <div className="onboarding-fade" />
      </motion.div>

      <StaggerGroup className="onboarding-copy" stagger={STAGGER.relaxed} delayChildren={0.34}>
        <StaggerItem>
          <h1 className="onboarding-title">
            Build your
            <br />
            Flavour, Step by Step
          </h1>
        </StaggerItem>
        <StaggerItem>
          <p className="onboarding-sub">Stack fresh ingredients for pizza made your way</p>
        </StaggerItem>
        <StaggerItem>
          <Pressable className="primary-btn onboarding-cta" press={0.96} onClick={start}>
            <motion.span
              animate={{ opacity: leaving ? 0.65 : 1 }}
              transition={tween(DUR.fast)}
            >
              Get Started
            </motion.span>
          </Pressable>
        </StaggerItem>
      </StaggerGroup>
    </div>
  )
}
