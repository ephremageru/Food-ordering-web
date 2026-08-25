import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'simple_tabs.dart';

/// The tab shell.
///
/// Tabs cross-fade with no translation — see `dissolveRoute` for the reasoning:
/// sibling destinations that slide imply an order they do not have. Each tab
/// keeps its own [Navigator] so pushing a detail screen from Home and switching
/// tabs does not lose your place, and so a hero flight has a navigator to fly
/// within.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavTab _tab = NavTab.home;

  final Map<NavTab, GlobalKey<NavigatorState>> _navigators =
      <NavTab, GlobalKey<NavigatorState>>{
    for (final NavTab t in NavTab.values) t: GlobalKey<NavigatorState>(),
  };

  /// How deep each tab's stack is. The nav bar belongs to the tab roots; once
  /// you are on a detail, cart, or checkout screen it must get out of the way,
  /// both because those screens own the bottom of the display (the add-to-cart
  /// bar, the pay button) and because a persistent nav bar there would invite
  /// you to leave a flow mid-way.
  final Map<NavTab, int> _depth = <NavTab, int>{
    for (final NavTab t in NavTab.values) t: 0,
  };

  bool get _navBarVisible => (_depth[_tab] ?? 0) == 0;

  late final Map<NavTab, NavigatorObserver> _observers =
      <NavTab, NavigatorObserver>{
    for (final NavTab t in NavTab.values) t: _DepthObserver(
      onChanged: (int d) {
        if (!mounted || _depth[t] == d) {
          return;
        }
        setState(() => _depth[t] = d);
      },
    ),
  };

  Widget _rootFor(NavTab tab) => switch (tab) {
        NavTab.home => const HomeScreen(),
        NavTab.search => const SearchTab(),
        NavTab.favourites => const FavouritesTab(),
        NavTab.orders => const OrdersScreen(embedded: true),
        NavTab.profile => const ProfileTab(),
      };

  Future<bool> _onPop() async {
    final NavigatorState? nav = _navigators[_tab]?.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    if (_tab != NavTab.home) {
      setState(() => _tab = NavTab.home);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (await _onPop() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: <Widget>[
            for (final NavTab tab in NavTab.values)
              // Offstage rather than rebuilt: switching tabs must not reset a
              // scroll position or restart an entrance animation.
              Offstage(
                offstage: _tab != tab,
                child: TickerMode(
                  enabled: _tab == tab,
                  child: AnimatedOpacity(
                    duration: Motion.normal,
                    curve: Ease.standard,
                    opacity: _tab == tab ? 1 : 0,
                    child: Navigator(
                      key: _navigators[tab],
                      observers: <NavigatorObserver>[_observers[tab]!],
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute<void>(
                          builder: (_) => _rootFor(tab),
                          settings: settings,
                        );
                      },
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              // Slides down and fades rather than being removed, so returning
              // from a detail screen brings it back along the same path.
              child: AnimatedSlide(
                duration: Motion.normal,
                curve: Ease.standard,
                offset: Offset(0, _navBarVisible ? 0 : 1.4),
                child: AnimatedOpacity(
                  duration: Motion.quick,
                  opacity: _navBarVisible ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_navBarVisible,
                    child: BottomNavigation(
                      current: _tab,
                      onSelected: (NavTab tab) {
                        if (tab == _tab) {
                          _navigators[tab]?.currentState?.popUntil(
                                (Route<dynamic> r) => r.isFirst,
                              );
                          return;
                        }
                        setState(() => _tab = tab);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Reports a navigator's stack depth as it changes.
class _DepthObserver extends NavigatorObserver {
  _DepthObserver({required this.onChanged});

  final ValueChanged<int> onChanged;
  int _depth = 0;

  void _emit(int delta) {
    _depth = (_depth + delta).clamp(0, 99);
    // Route callbacks fire during a build/layout phase, so defer.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(_depth));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _emit(1);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _emit(-1);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _emit(-1);
}
