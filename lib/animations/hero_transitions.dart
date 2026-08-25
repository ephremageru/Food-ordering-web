import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/pizza_painter.dart';
import '../models/pizza.dart';
import 'animation_constants.dart';
import 'motion_curves.dart';

/// A [RectTween] that flies along an arc and is shaped by the specified spring.
///
/// Flutter's default hero tween interpolates the rect linearly, which reads as
/// a mechanical slide. Two things fix that here:
///
/// 1. The **centre** travels along a circular arc rather than a straight line,
///    so a pizza moving up-and-across sweeps instead of sliding diagonally.
/// 2. The whole parameter is passed through [SpringCurve], so the flight
///    carries the `stiffness: 250, damping: 25` character — it arrives with a
///    single small overshoot and settles, instead of easing to a dead stop.
///
/// Size is interpolated on a slightly different curve than position. Letting
/// the pizza reach most of its final size before it reaches its final position
/// is what makes it look like it is *landing* rather than being scaled by a
/// separate process.
class SpringArcRectTween extends RectTween {
  SpringArcRectTween({super.begin, super.end});

  static final SpringCurve _spring = SpringCurve(Springs.primary);

  @override
  Rect lerp(double t) {
    final Rect? a = begin;
    final Rect? b = end;
    if (a == null || b == null) {
      return super.lerp(t)!;
    }

    final double st = _spring.transform(t.clamp(0.0, 1.0));
    final double sizeT = Ease.out.transform(t.clamp(0.0, 1.0));

    final Offset centre = _arcCentre(a.center, b.center, st);
    final double w = a.width + (b.width - a.width) * sizeT;
    final double h = a.height + (b.height - a.height) * sizeT;

    return Rect.fromCenter(center: centre, width: w, height: h);
  }

  /// Interpolates between two points along a circular arc whose bulge is
  /// perpendicular to the travel direction and biased upward.
  static Offset _arcCentre(Offset from, Offset to, double t) {
    final Offset delta = to - from;
    final double distance = delta.distance;
    if (distance < 1) {
      return Offset.lerp(from, to, t)!;
    }
    final Offset straight = from + delta * t;
    final Offset normal = Offset(delta.dy, -delta.dx) / distance;
    final Offset up = normal.dy <= 0 ? normal : -normal;
    // sin() gives zero bulge at both ends and the maximum at the midpoint, so
    // the arc leaves and arrives cleanly along the straight line.
    final double bulge = math.sin(t * math.pi) * math.min(distance * 0.22, 90.0);
    return straight + up * bulge;
  }
}

/// The shared pizza element.
///
/// One widget, used on the home card and in the detail hero slot, so the two
/// screens genuinely share an element rather than each drawing a lookalike.
/// Note there is exactly one [Hero] here and nothing else in the app wraps a
/// pizza in another — nested heroes with the same tag are the usual cause of a
/// flight that flashes or drops out mid-transition.
class PizzaHero extends StatelessWidget {
  const PizzaHero({
    super.key,
    required this.pizza,
    required this.size,
    this.slices = 8,
    this.shadow = true,
    this.enabled = true,
  });

  final Pizza pizza;
  final double size;
  final int slices;
  final bool shadow;

  /// Set false where a pizza is shown but must not participate in a flight —
  /// e.g. the cart list, which is on screen at the same time as the detail
  /// hero and would otherwise contend for the same tag.
  final bool enabled;

  static String tagFor(Pizza pizza) => 'pizza-${pizza.id}';

  @override
  Widget build(BuildContext context) {
    final Widget disc = PizzaDisc(
      pizza: pizza,
      size: size,
      slices: slices,
      shadow: shadow,
    );
    if (!enabled) {
      return disc;
    }
    return Hero(
      tag: tagFor(pizza),
      createRectTween: (Rect? begin, Rect? end) =>
          SpringArcRectTween(begin: begin, end: end),
      // The shuttle is drawn on a transparent Material so it never picks up a
      // card background or a text-underline from either route while in flight.
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection direction,
        BuildContext fromContext,
        BuildContext toContext,
      ) {
        return Material(
          type: MaterialType.transparency,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double side = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Center(
                child: PizzaDisc(
                  pizza: pizza,
                  size: side.isFinite && side > 0 ? side : size,
                  slices: slices,
                  shadow: shadow,
                ),
              );
            },
          ),
        );
      },
      child: disc,
    );
  }
}
