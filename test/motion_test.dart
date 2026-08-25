import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizzafy/animations/animation_constants.dart';
import 'package:pizzafy/animations/hero_transitions.dart';
import 'package:pizzafy/animations/motion_curves.dart';

void main() {
  group('SpringCurve', () {
    final SpringCurve curve = SpringCurve(Springs.primary);

    test('is anchored at both ends', () {
      expect(curve.transform(0.0), closeTo(0.0, 0.001));
      expect(curve.transform(1.0), closeTo(1.0, 0.001));
    });

    test('overshoots, which is the point of using a spring at all', () {
      // stiffness 250 / damping 25 / mass 1 is underdamped (ratio ~0.79), so
      // the curve must exceed 1.0 somewhere. If this ever fails, the spring has
      // silently become an ease and every "physical" interaction with it is a
      // tween wearing a costume.
      double peak = 0;
      for (int i = 0; i <= 200; i++) {
        peak = peak < curve.transform(i / 200) ? curve.transform(i / 200) : peak;
      }
      expect(peak, greaterThan(1.0));
    });

    test('settles within a duration usable as a controller duration', () {
      final Duration d = SpringCurve.settleDuration(Springs.primary);
      expect(d.inMilliseconds, greaterThan(100));
      expect(d.inMilliseconds, lessThan(3000));
    });
  });

  group('flight arc', () {
    test('bows away from the straight line', () {
      const Offset a = Offset(40, 700);
      const Offset b = Offset(360, 120);
      final Offset control = flightControlPoint(a, b);
      final Offset mid = quadraticBezier(a, control, b, 0.5);
      final Offset straightMid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      expect(
        (mid - straightMid).distance,
        greaterThan(20),
        reason: 'a flight that tracks the straight line is just a slide',
      );
    });

    test('starts and ends exactly on target', () {
      const Offset a = Offset(10, 10);
      const Offset b = Offset(300, 400);
      final Offset c = flightControlPoint(a, b);
      expect(quadraticBezier(a, c, b, 0.0), a);
      expect(quadraticBezier(a, c, b, 1.0), b);
    });
  });

  group('SpringArcRectTween', () {
    test('lands precisely on the destination rect', () {
      final SpringArcRectTween t = SpringArcRectTween(
        begin: const Rect.fromLTWH(0, 0, 100, 100),
        end: const Rect.fromLTWH(200, 400, 260, 260),
      );
      final Rect end = t.lerp(1.0);
      expect(end.center.dx, closeTo(330, 0.5));
      expect(end.center.dy, closeTo(530, 0.5));
      expect(end.width, closeTo(260, 0.5));
    });

    test('leaves the straight line mid-flight', () {
      final SpringArcRectTween t = SpringArcRectTween(
        begin: const Rect.fromLTWH(0, 600, 100, 100),
        end: const Rect.fromLTWH(300, 100, 100, 100),
      );
      final Rect mid = t.lerp(0.5);
      final Offset straight = Offset.lerp(
        const Offset(50, 650),
        const Offset(350, 150),
        0.5,
      )!;
      expect((mid.center - straight).distance, greaterThan(5));
    });
  });

  group('size scales match the specification', () {
    test('0.94 / 1.00 / 1.06', () {
      expect(SizeScale.small, 0.94);
      expect(SizeScale.medium, 1.0);
      expect(SizeScale.large, 1.06);
    });
  });

  group('durations match the specification', () {
    test('the cart flight is exactly 650ms', () {
      expect(Motion.cartFlight.inMilliseconds, 650);
    });
    test('press feedback is 150ms', () {
      expect(Motion.fast.inMilliseconds, 150);
    });
  });
}
