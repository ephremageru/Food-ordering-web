import 'package:flutter/material.dart';

import '../animations/hero_transitions.dart';
import '../models/pizza.dart';
import '../theme/app_theme.dart';
import 'price_text.dart';
import 'pressable.dart';

/// A pizza in the grid.
///
/// The artwork deliberately overflows the top of the card by roughly a third of
/// its height. That overhang is what makes the pizza feel like an object
/// resting on the card rather than a picture printed inside it — and it is also
/// what makes the hero flight legible, because the element that travels is
/// already visually separate from its container before it leaves.
class PizzaCard extends StatelessWidget {
  const PizzaCard({
    super.key,
    required this.pizza,
    required this.onTap,
    required this.onAdd,
    required this.addKey,
  });

  final Pizza pizza;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  /// Keyed so the flight knows the exact rect the pizza is departing from.
  final GlobalKey addKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double disc = w * 0.82;

        return Pressable(
          onTap: onTap,
          semanticLabel: '${pizza.name}, ${pizza.tagline}',
          child: Padding(
            // Room for the overhanging pizza to draw outside the card body.
            padding: EdgeInsets.only(top: disc * 0.42),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Radii.card),
                    boxShadow: Shadows.card,
                  ),
                  padding: EdgeInsets.only(
                    top: disc * 0.62,
                    left: 14,
                    right: 14,
                    bottom: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _DiscountBadge(discount: pizza.discount),
                      const SizedBox(height: 10),
                      Text(
                        pizza.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pizza.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          PriceText(value: pizza.price, size: 21, animate: false),
                          const Spacer(),
                          Pressable(
                            key: addKey,
                            onTap: onAdd,
                            scale: 0.82,
                            semanticLabel: 'Add ${pizza.name} to cart',
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.hairline),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 19,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -disc * 0.42,
                  child: PizzaHero(pizza: pizza, size: disc),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.discount});

  final int discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Text(
        '-$discount%',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
