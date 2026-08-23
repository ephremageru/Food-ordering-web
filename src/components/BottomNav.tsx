import { motion } from 'framer-motion'
import { IconBookmark, IconChat, IconHeart, IconHome, IconUser } from '../art/Icons'
import { SPRING, DUR, EASE, tween } from '../motion/tokens'
import { TAB_ROUTES, useNav, type RouteName } from '../nav/NavigationProvider'

const TABS: { id: RouteName; label: string; Icon: typeof IconHome }[] = [
  { id: 'home', label: 'Home', Icon: IconHome },
  { id: 'search', label: 'Messages', Icon: IconChat },
  { id: 'favorites', label: 'Favourites', Icon: IconHeart },
  { id: 'orders', label: 'Orders', Icon: IconBookmark },
  { id: 'profile', label: 'Profile', Icon: IconUser },
]

/**
 * The floating tab bar.
 *
 * The active pill is one `layoutId` element, so it travels between tabs. The
 * icon inside also gets a short scale pop on selection — movement plus a beat
 * of feedback, which is what makes a tab change feel confirmed.
 */
export function BottomNav({ visible }: { visible: boolean }) {
  const nav = useNav()
  const current = nav.route.name

  return (
    // Kept mounted and animated rather than unmounted, for two reasons: the
    // active pill's layoutId survives, so it never replays an entrance on a tab
    // change; and pushing a detail screen drops the bar out of the way the same
    // way `hidesBottomBarWhenPushed` does, instead of cutting it.
    <motion.nav
      className="tabbar"
      aria-label="Primary"
      aria-hidden={!visible}
      initial={false}
      animate={
        visible
          ? { opacity: 1, y: 0, scale: 1, transition: SPRING.sheet }
          : { opacity: 0, y: 26, scale: 0.94, transition: tween(DUR.quick, EASE.in) }
      }
      style={{ pointerEvents: visible ? 'auto' : 'none' }}
    >
      {TABS.map(({ id, label, Icon }) => {
        const active = current === id
        return (
          <motion.button
            key={id}
            className={`tab ${active ? 'is-active' : ''}`}
            onClick={() => {
              if (active) return
              nav.reset(id, { kind: 'dissolve' })
            }}
            aria-label={label}
            aria-current={active ? 'page' : undefined}
            whileTap={{ scale: 0.9 }}
            transition={SPRING.snappy}
          >
            {active && (
              <motion.span
                layoutId="tab-pill"
                className="tab-pill"
                transition={SPRING.snappy}
              />
            )}
            <motion.span
              className="tab-icon"
              animate={{ scale: active ? [1, 1.16, 1] : 1, opacity: active ? 1 : 0.55 }}
              transition={active ? { scale: SPRING.pop, opacity: tween(DUR.fast) } : tween(DUR.quick, EASE.out)}
            >
              <Icon size={19} strokeWidth={active ? 2.1 : 1.8} />
            </motion.span>
          </motion.button>
        )
      })}
    </motion.nav>
  )
}

export const isTabRoute = (name: RouteName) => TAB_ROUTES.includes(name)
