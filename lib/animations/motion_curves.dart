import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

import 'animation_constants.dart';

/// A [Curve] whose shape is produced by an actual spring simulation.
///
/// This is what lets the specified `stiffness: 250, damping: 25` reach widgets
/// that only accept a curve — [AnimatedContainer], [AnimatedScale],
/// [AnimatedAlign] and friends — instead of being quietly replaced by a
/// generic `Curves.easeInOut`. The simulation is run once at construction and
/// sampled into a lookup table, so evaluating it per frame is a table read
/// rather than a physics step.
///
/// For motion that is interruptible mid-flight (a press released early, a
/// selection changed while the previous one is still settling) prefer driving
/// an [AnimationController] with the simulation directly via
/// `controller.animateWith(...)` — that carries velocity across the
/// interruption, which a curve cannot. See [SpringDriver].
class SpringCurve extends Curve {
  SpringCurve(this.spring) : _table = _buildTable(spring);

  final SpringDescription spring;
  final List<double> _table;

  static const int _resolution = 240;

  /// Time in seconds for this spring to settle when released from 0 to 1.
  static double settleTime(SpringDescription spring) {
    final SpringSimulation sim = SpringSimulation(spring, 0.0, 1.0, 0.0);
    double t = 0.0;
    const double step = 1 / 240;
    while (t < 4.0 && !sim.isDone(t)) {
      t += step;
    }
    return t;
  }

  /// The natural duration of this spring, for use as a controller duration.
  static Duration settleDuration(SpringDescription spring) =>
      Duration(microseconds: (settleTime(spring) * 1e6).round());

  static List<double> _buildTable(SpringDescription spring) {
    final SpringSimulation sim = SpringSimulation(spring, 0.0, 1.0, 0.0);
    final double total = settleTime(spring);
    return List<double>.generate(_resolution + 1, (int i) {
      final double t = i / _resolution;
      if (i == _resolution) {
        return 1.0;
      }
      return sim.x(t * total);
    });
  }

  @override
  double transformInternal(double t) {
    final double pos = t * _resolution;
    final int i = pos.floor().clamp(0, _resolution - 1);
    final double f = pos - i;
    return _table[i] + (_table[i + 1] - _table[i]) * f;
  }
}

/// The app's curve set. Each one exists because a specific interaction needed
/// it — there is deliberately no single "default" curve reused everywhere.
class Ease {
  const Ease._();

  /// Strong deceleration. Anything entering the screen or settling into place.
  static const Cubic out = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Anything leaving the screen. Faster out than in, so exits never drag.
  static const Cubic exit = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Symmetric, for values that move between two resting states.
  static const Cubic standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// The cart flight: accelerates off the hero slot, decelerates into the bag.
  static const Cubic flight = Cubic(0.42, 0.0, 0.18, 1.0);

  /// The spring, as a curve, for implicit animations.
  static final SpringCurve spring = SpringCurve(Springs.primary);
  static final SpringCurve springHeavy = SpringCurve(Springs.heavy);
  static final SpringCurve springPop = SpringCurve(Springs.pop);
}

/// Drives an [AnimationController] with a real [SpringSimulation], preserving
/// velocity when a gesture interrupts an in-flight animation.
///
/// This is the difference between a button that can be mashed and one that
/// snaps back to zero on every touch: releasing mid-press hands the current
/// velocity to the return simulation, so the scale continues from where the
/// finger left it.
class SpringDriver {
  const SpringDriver._();

  static TickerFuture to(
    AnimationController controller,
    double target, {
    SpringDescription spring = Springs.primary,
    double? velocity,
  }) {
    final SpringSimulation sim = SpringSimulation(
      spring,
      controller.value,
      target,
      velocity ?? controller.velocity,
    );
    return controller.animateWith(sim);
  }
}

/// Quadratic Bézier evaluation, used by the cart flight to build its arc.
Offset quadraticBezier(Offset p0, Offset control, Offset p2, double t) {
  final double u = 1 - t;
  return Offset(
    u * u * p0.dx + 2 * u * t * control.dx + t * t * p2.dx,
    u * u * p0.dy + 2 * u * t * control.dy + t * t * p2.dy,
  );
}

/// Builds the control point for a flight arc between two screen points.
///
/// The arc always bows away from the straight line, perpendicular to it, so the
/// pizza sweeps out rather than sliding along a diagonal. The bow scales with
/// distance and is capped, so short flights stay tight and long ones do not
/// balloon off-screen.
Offset flightControlPoint(Offset start, Offset end) {
  final Offset mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  final Offset delta = end - start;
  final double distance = delta.distance;
  if (distance < 1) {
    return mid;
  }
  // Perpendicular to the travel direction, biased upward so the pizza lifts.
  final Offset normal = Offset(delta.dy, -delta.dx) / distance;
  final double bow = math.min(distance * 0.42, 190.0);
  final Offset bowed = mid + normal * bow;
  // Never let the apex sit below the straight line — the arc should read as a
  // toss, not a sag.
  return bowed.dy > mid.dy ? mid - normal * bow : bowed;
}
