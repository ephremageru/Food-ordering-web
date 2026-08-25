import 'package:flutter/material.dart';

import '../art/pizza_painter.dart';
import '../models/pizza.dart';
import '../theme/app_theme.dart';
import 'animation_constants.dart';
import 'motion_curves.dart';

/// Marks a widget as a flight destination so the flight can find it by key
/// without any screen having to plumb coordinates around.
class FlightTarget {
  const FlightTarget._();

  /// Resolves a global centre + radius for a widget, given its key.
  static Rect? rectOf(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    if (context == null) {
      return null;
    }
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// Drives the add-to-cart pizza flight.
///
/// The pizza is lifted into an [OverlayEntry] so it can travel across the whole
/// screen without being clipped by the scroll view, card, or app bar it started
/// inside. It flies a quadratic Bézier arc over exactly 650ms, shrinking as it
/// goes, and lands in the bag icon.
///
/// The scale is a [TweenSequence] rather than a single tween, and that detail
/// carries most of the effect: the pizza *grows slightly* as it lifts off — the
/// way a thrown object reads as coming toward you — before collapsing into the
/// target. A single 1.0 -> 0.25 tween looks like something shrinking; this
/// looks like something being thrown.
class CartFlight {
  const CartFlight._();

  static Future<void> launch({
    required BuildContext context,
    required Pizza pizza,
    required Rect from,
    required Rect to,
    VoidCallback? onArrive,
  }) async {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      onArrive?.call();
      return;
    }

    // Reduced motion: skip the flight entirely rather than running the same
    // arc quickly. A fast arc is still a flying object crossing the screen.
    final bool reduced =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      onArrive?.call();
      return;
    }

    final AnimationController controller = AnimationController(
      vsync: overlay,
      duration: Motion.cartFlight,
    );

    final Offset start = from.center;
    final Offset end = to.center;
    final Offset control = flightControlPoint(start, end);
    final double startSide = from.shortestSide;
    final double endSide = to.shortestSide;

    final Animation<double> path = CurvedAnimation(
      parent: controller,
      curve: Ease.flight,
    );

    // 1.0 -> 1.12 -> 0.28 of the *start* size, then the final leg is expressed
    // relative to the target so the pizza ends exactly the size of the bag.
    final Animation<double> scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.12, end: 0.55)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 46,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.55, end: endSide / startSide)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 36,
      ),
    ]).animate(controller);

    // Holds full opacity almost the whole way, then extinguishes in the last
    // moments — the pizza should look absorbed, not faded out en route.
    final Animation<double> opacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: 82),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 18,
      ),
    ]).animate(controller);

    // A little spin, scaled to how far it travels. Enough to read as tumbling,
    // not enough to look like a loading spinner.
    final Animation<double> spin = Tween<double>(
      begin: 0.0,
      end: (end - start).distance > 220 ? 0.55 : 0.3,
    ).animate(CurvedAnimation(parent: controller, curve: Ease.flight));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            final Offset p = quadraticBezier(start, control, end, path.value);
            final double side = startSide * scale.value;
            return Positioned(
              left: p.dx - side / 2,
              top: p.dy - side / 2,
              width: side,
              height: side,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity.value,
                  child: Transform.rotate(angle: spin.value, child: child),
                ),
              ),
            );
          },
          // Built once and reused across all 650ms of frames: the pizza artwork
          // is the expensive part of this animation and nothing about it
          // changes during the flight. It fills whatever box the Positioned
          // gives it, so scaling costs nothing beyond a repaint.
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: Shadows.pizza,
            ),
            child: PizzaArt(pizza: pizza),
          ),
        );
      },
    );

    overlay.insert(entry);
    try {
      await controller.forward();
    } finally {
      entry.remove();
      controller.dispose();
    }
    onArrive?.call();
  }
}
