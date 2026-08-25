import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

enum NavTab { home, search, favourites, orders, profile }

/// The floating dark navigation bar.
///
/// The active state is an orange pill that *slides* between destinations rather
/// than a colour that changes in place. Sliding is what tells you the tabs are
/// arranged in a row and where you moved within it; recolouring tells you only
/// that something changed.
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final NavTab current;
  final ValueChanged<NavTab> onSelected;

  static const List<({NavTab tab, IconData icon, String label})> _items =
      <({NavTab tab, IconData icon, String label})>[
    (tab: NavTab.home, icon: Icons.home_rounded, label: 'Home'),
    (tab: NavTab.search, icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    (tab: NavTab.favourites, icon: Icons.favorite_border_rounded, label: 'Favourites'),
    (tab: NavTab.orders, icon: Icons.receipt_long_outlined, label: 'Orders'),
    (tab: NavTab.profile, icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(Radii.chip),
          boxShadow: Shadows.lifted,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double slot = constraints.maxWidth / _items.length;
            final int index = _items.indexWhere(
              (({IconData icon, String label, NavTab tab}) e) => e.tab == current,
            );

            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                AnimatedPositioned(
                  duration: Motion.medium,
                  curve: Ease.spring,
                  left: slot * index + (slot - 50) / 2,
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    for (final ({IconData icon, String label, NavTab tab}) item
                        in _items)
                      Expanded(
                        child: Pressable(
                          onTap: () => onSelected(item.tab),
                          scale: 0.88,
                          semanticLabel: item.label,
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: AnimatedScale(
                                duration: Motion.normal,
                                curve: Ease.spring,
                                scale: item.tab == current ? 1.08 : 1.0,
                                child: Icon(
                                  item.icon,
                                  size: 22,
                                  color: item.tab == current
                                      ? Colors.white
                                      : const Color(0xFF7C7772),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
