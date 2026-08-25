import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

enum AddToCartPhase { idle, flying, landed }

/// The detail screen's primary action, and the destination of the pizza flight.
///
/// It has three states and the transitions between them are the point:
///
/// * **idle** — a full-width pill reading "Add to cart".
/// * **flying** — the label fades and the pill collapses toward the bag icon,
///   which is where the pizza is heading. The button getting out of the way is
///   what makes the bag look like a target rather than decoration.
/// * **landed** — a circle holding a tick.
///
/// The width animates rather than the button being swapped for a different
/// widget, so the collapse is continuous and the bag icon never moves
/// discontinuously while the pizza is in the air aiming at it.
class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
    required this.phase,
    required this.onTap,
    required this.bagKey,
    this.label = 'Add to cart',
  });

  final AddToCartPhase phase;
  final VoidCallback onTap;

  /// Global key on the bag icon itself — the flight aims here, not at the
  /// button, so the pizza lands in the icon rather than in the middle of a pill.
  final GlobalKey bagKey;

  final String label;

  static const double _height = 58;

  @override
  Widget build(BuildContext context) {
    final bool collapsed = phase != AddToCartPhase.idle;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double full = constraints.maxWidth;
        return Align(
          alignment: Alignment.center,
          child: Pressable(
            onTap: phase == AddToCartPhase.idle ? onTap : null,
            scale: 0.97,
            semanticLabel: label,
            child: AnimatedContainer(
              duration: Motion.buttonMorph,
              curve: Ease.standard,
              width: collapsed ? _height : full,
              height: _height,
              decoration: BoxDecoration(
                color: AppColors.navBar,
                borderRadius: BorderRadius.circular(Radii.chip),
                boxShadow: Shadows.lifted,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.chip),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      key: bagKey,
                      width: 26,
                      height: 26,
                      child: AnimatedSwitcher(
                        duration: Motion.quick,
                        switchInCurve: Ease.springPop,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                ScaleTransition(scale: animation, child: child),
                        child: phase == AddToCartPhase.landed
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey<String>('tick'),
                                size: 24,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.shopping_bag_outlined,
                                key: ValueKey<String>('bag'),
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    // The label is animated out by width as well as opacity, so
                    // the text is gone before the pill is narrow enough to clip
                    // it — clipped mid-word is the tell that a button is just
                    // shrinking rather than transforming.
                    AnimatedSize(
                      duration: Motion.buttonMorph,
                      curve: Ease.standard,
                      child: SizedBox(
                        width: collapsed ? 0 : null,
                        child: AnimatedOpacity(
                          duration: Motion.fast,
                          opacity: collapsed ? 0 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              label,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
