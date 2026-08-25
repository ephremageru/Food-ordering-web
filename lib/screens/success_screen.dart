import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import 'orders_screen.dart';

/// Payment confirmation.
///
/// One controller drives the whole sequence through [Interval]s rather than a
/// chain of delayed futures. That matters for correctness as much as for
/// tidiness: if the screen is disposed halfway through — the user hits back,
/// or the auto-advance fires — a single controller stops cleanly, whereas a
/// chain of pending timers keeps firing into a dead tree.
///
/// Order of events: ring sweeps, tick draws, then the copy arrives beneath it.
/// The tick must not start before the ring closes, or the two strokes read as
/// one scribble instead of a seal being stamped.
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  late final Animation<double> _pop = _interval(0.00, 0.16, Ease.springPop);
  late final Animation<double> _ring = _interval(0.10, 0.44, Ease.out);
  late final Animation<double> _tick = _interval(0.44, 0.68, Ease.out);
  late final Animation<double> _title = _interval(0.60, 0.76, Ease.out);
  late final Animation<double> _meta = _interval(0.68, 0.84, Ease.out);
  late final Animation<double> _actions = _interval(0.78, 1.00, Ease.out);

  Animation<double> _interval(double a, double b, Curve curve) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _c.value = 1.0;
      } else {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toOrders() {
    Navigator.of(context).pushReplacement(
      AppRoutes.revealRoute<void>(const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _c,
                    builder: (BuildContext context, _) {
                      return Transform.scale(
                        scale: 0.6 + 0.4 * _pop.value,
                        child: SizedBox(
                          width: 116,
                          height: 116,
                          child: CustomPaint(
                            painter: _SealPainter(
                              ring: _ring.value,
                              tick: _tick.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _Reveal(
                    animation: _title,
                    child: Text(
                      'Payment Successful',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Reveal(
                    animation: _meta,
                    child: Column(
                      children: <Widget>[
                        Text(
                          '\$${widget.order.total.toStringAsFixed(2)} paid  ·  Order ${widget.order.reference}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.order.itemCount} item${widget.order.itemCount == 1 ? "" : "s"} on the way to you',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _Reveal(
                    animation: _actions,
                    child: Column(
                      children: <Widget>[
                        _WideButton(
                          label: 'Track my order',
                          filled: true,
                          onTap: _toOrders,
                        ),
                        const SizedBox(height: 12),
                        _WideButton(
                          label: 'Back to menu',
                          filled: false,
                          onTap: () => Navigator.of(context)
                              .popUntil((Route<dynamic> r) => r.isFirst),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ring and the tick, both drawn stroke-by-stroke.
///
/// The tick is a real path traversal via [PathMetric.extractPath], not two
/// lines revealed by a clip. That is what gives it a moving stroke head with a
/// correct round cap — a clipped tick shows a squared-off leading edge that
/// gives the trick away at any size above about 40px.
class _SealPainter extends CustomPainter {
  _SealPainter({required this.ring, required this.tick});

  final double ring;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = math.min(size.width, size.height) / 2 - 5;

    // Faint full ring underneath, so the sweep has a track to run along.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.success.withValues(alpha: 0.14),
    );

    if (ring > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        math.pi * 2 * ring,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.success,
      );
    }

    if (tick > 0) {
      final Path path = Path()
        ..moveTo(c.dx - r * 0.42, c.dy + r * 0.02)
        ..lineTo(c.dx - r * 0.10, c.dy + r * 0.34)
        ..lineTo(c.dx + r * 0.44, c.dy - r * 0.28);

      final PathMetric metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * tick),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.success,
      );
    }
  }

  @override
  bool shouldRepaint(_SealPainter old) => old.ring != ring || old.tick != tick;
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? c) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - animation.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      semanticLabel: label,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: filled ? AppColors.navBar : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.chip),
          border: filled ? null : Border.all(color: AppColors.hairline),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
