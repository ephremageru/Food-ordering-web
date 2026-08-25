import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../state/cart_controller.dart';
import '../state/flight_anchors.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// The header cart icon: flight destination, impact reaction, and live count.
///
/// The bump is triggered by the flight on arrival rather than by the count
/// changing. That ordering is what sells the whole interaction — the icon
/// reacts because something hit it, so the reaction lands on the same frame the
/// pizza disappears instead of a beat later.
class CartButton extends StatefulWidget {
  const CartButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _anchorKey = GlobalKey();

  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: Motion.normal,
    lowerBound: 0.0,
    upperBound: 1.4,
  );

  @override
  void initState() {
    super.initState();
    CartAnchor.instance.register(_anchorKey, _playBump);
  }

  @override
  void dispose() {
    CartAnchor.instance.unregister(_anchorKey);
    _bump.dispose();
    super.dispose();
  }

  /// 1.0 -> 1.15 -> 1.0, as specified. The return leg is a spring, so the icon
  /// settles with one small overshoot rather than easing to a dead stop.
  void _playBump() {
    if (!mounted) {
      return;
    }
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return;
    }
    _bump.animateTo(1.0, duration: Motion.fast, curve: Ease.out).whenComplete(() {
      if (mounted) {
        SpringDriver.to(_bump, 0.0, spring: Springs.pop);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final CartController cart = CartScope.of(context);
    final int count = cart.count;

    return Pressable(
      onTap: widget.onTap,
      scale: 0.9,
      semanticLabel: count == 0 ? 'Cart, empty' : 'Cart, $count items',
      child: AnimatedBuilder(
        animation: _bump,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: 1.0 + 0.15 * _bump.value,
            child: child,
          );
        },
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                key: _anchorKey,
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: Shadows.card,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 21,
                  color: AppColors.ink,
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: _CountBadge(count: count),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The badge. Appearing and disappearing are separate motions from counting up:
/// 0 -> 1 pops the whole badge into existence, while 1 -> 2 rolls just the
/// digit, so the two events never look like the same thing.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: Motion.normal,
      curve: Ease.springPop,
      scale: count == 0 ? 0.0 : 1.0,
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: count == 0 ? 0.0 : 1.0,
        child: Container(
          constraints: const BoxConstraints(minWidth: 19),
          height: 19,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(color: AppColors.background, width: 2),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: Motion.quick,
              switchInCurve: Ease.out,
              switchOutCurve: Ease.exit,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.8),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '$count',
                key: ValueKey<int>(count),
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
