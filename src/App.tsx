import { useState } from 'react'
import { AnimatePresence, LayoutGroup, MotionConfig } from 'framer-motion'
import { NavigationProvider, useNav, type Route } from './nav/NavigationProvider'
import { Screen } from './nav/Screen'
import { BottomNav, isTabRoute } from './components/BottomNav'
import { HeroFlightProvider } from './state/heroFlight'
import { StoreProvider } from './state/store'
import { ToastProvider } from './motion/Toast'
import { Onboarding } from './screens/Onboarding'
import { Home } from './screens/Home'
import { ProductDetail } from './screens/ProductDetail'
import { Cart } from './screens/Cart'
import { Checkout } from './screens/Checkout'
import { Success } from './screens/Success'
import { Orders } from './screens/Orders'
import { FavoritesScreen, ProfileScreen, SearchScreen } from './screens/SimpleTabs'
import type { CategoryId } from './data/pizzas'

/** Reads the route out of the URL so a refresh or a deep link lands correctly. */
function initialRoute(): Route {
  let hash = ''
  try {
    hash = window.location.hash.replace(/^#\/?/, '')
  } catch {
    /* Opaque-origin embeds can refuse location access; start at onboarding. */
  }
  const [name, query] = hash.split('?')
  const params = query ? Object.fromEntries(new URLSearchParams(query)) : undefined
  const known = ['home', 'search', 'favorites', 'orders', 'profile', 'product', 'cart', 'checkout']
  if (name && known.includes(name)) {
    return { name: name as Route['name'], params, kind: 'dissolve' }
  }
  return { name: 'onboarding', kind: 'reveal' }
}

function Router() {
  const nav = useNav()
  const { route, direction } = nav
  // Category lives above the Home screen so it survives a push to the detail
  // page — which is what guarantees the originating card still exists to
  // receive the pizza when the user comes back.
  const [category, setCategory] = useState<CategoryId>('all')

  const showTabs = isTabRoute(route.name)

  return (
    <>
      {/* Sync mode, not popLayout: screens are absolutely positioned so they
          already overlay without affecting each other's layout, and nesting
          popLayout here around the grid's own popLayout stalls the exit. */}
      <AnimatePresence initial={false}>
        <Screen key={route.name + (route.params?.id ?? '')} kind={route.kind} direction={direction}>
          {route.name === 'onboarding' && <Onboarding />}
          {route.name === 'home' && <Home category={category} onCategory={setCategory} />}
          {route.name === 'search' && <SearchScreen />}
          {route.name === 'favorites' && <FavoritesScreen />}
          {route.name === 'orders' && <Orders />}
          {route.name === 'profile' && <ProfileScreen />}
          {route.name === 'product' && <ProductDetail id={route.params?.id ?? ''} />}
          {route.name === 'cart' && <Cart />}
          {route.name === 'checkout' && <Checkout />}
          {route.name === 'success' && <Success />}
        </Screen>
      </AnimatePresence>

      {/* The tab bar lives outside the screen stack so its active pill can
          travel between tabs instead of being torn down with the screen. */}
      <BottomNav visible={showTabs} />
    </>
  )
}

export default function App() {
  return (
    // `reducedMotion="user"` makes every transform animation in the tree respect
    // the OS setting; components additionally opt decorative motion out.
    <MotionConfig reducedMotion="user">
      <StoreProvider>
        <HeroFlightProvider>
          <NavigationProvider initial={initialRoute()}>
            <div className="stage">
              <div className="device">
                <ToastProvider>
                  <LayoutGroup>
                    <Router />
                  </LayoutGroup>
                </ToastProvider>
              </div>
            </div>
          </NavigationProvider>
        </HeroFlightProvider>
      </StoreProvider>
    </MotionConfig>
  )
}
