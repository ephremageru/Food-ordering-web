import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../art/pizza_painter.dart';
import '../models/menu_data.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import '../widgets/stagger.dart';
import 'app_shell.dart';

/// The opening screen: ingredients fall into place onto a pizza below.
///
/// Each ingredient has its own delay, arc and spin, and they arrive on a spring
/// so they settle with a small bounce rather than stopping dead. Falling
/// objects that stop instantly are the single most common tell of a
/// hand-animated intro, and the spring is what fixes it.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  );

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

  void _start() {
    Navigator.of(context)
        .pushReplacement(AppRoutes.revealRoute<void>(const AppShell()));
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double disc = math.min(screen.width * 0.78, 340);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.orangeSoft.withValues(alpha: 0.7),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screen.height * 0.16,
            left: (screen.width - disc) / 2,
            child: SizedBox(
              width: disc,
              height: disc + 160,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Positioned(
                    bottom: 0,
                    child: _RiseIn(
                      controller: _c,
                      begin: 0.0,
                      end: 0.30,
                      child: PizzaDisc(pizza: kMenu.first, size: disc),
                    ),
                  ),
                  for (int i = 0; i < _ingredients.length; i++)
                    _FallingIngredient(
                      controller: _c,
                      spec: _ingredients[i],
                      area: Size(disc, disc + 160),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 28,
            child: StaggerGroup(
              delay: const Duration(milliseconds: 1100),
              step: Motion.staggerNormal,
              children: <Widget>[
                Text(
                  'Build your\nFlavour, Step by Step',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Stack fresh ingredients for pizza made your way.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 26),
                Pressable(
                  onTap: _start,
                  scale: 0.97,
                  semanticLabel: 'Get started',
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.navBar,
                      borderRadius: BorderRadius.circular(Radii.chip),
                      boxShadow: Shadows.lifted,
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `x` and `y` are the landing point as a fraction of the pizza's radius from
/// its centre, so the ingredients settle scattered across the face rather than
/// stacking up in a line.
typedef _IngredientSpec = ({
  double x,
  double y,
  double delay,
  double size,
  double spin,
  Color color,
  Color accent,
  _Shape shape,
});

enum _Shape { disc, leaf, ring }

const List<_IngredientSpec> _ingredients = <_IngredientSpec>[
  (x: -0.46, y: -0.22, delay: 0.06, size: 32, spin: 1.4, color: Color(0xFFCE3A22), accent: Color(0xFFE9704F), shape: _Shape.disc),
  (x: 0.16, y: -0.48, delay: 0.13, size: 24, spin: -1.1, color: Color(0xFF4C8A34), accent: Color(0xFF74BC50), shape: _Shape.leaf),
  (x: 0.50, y: -0.06, delay: 0.20, size: 28, spin: 1.8, color: Color(0xFFB6552C), accent: Color(0xFFDC8A50), shape: _Shape.ring),
  (x: -0.20, y: 0.30, delay: 0.27, size: 22, spin: -1.6, color: Color(0xFF3E7A2C), accent: Color(0xFF69AC46), shape: _Shape.leaf),
  (x: 0.30, y: 0.44, delay: 0.34, size: 30, spin: 1.2, color: Color(0xFFC33A20), accent: Color(0xFFE96E4C), shape: _Shape.disc),
  (x: -0.52, y: 0.36, delay: 0.41, size: 23, spin: -0.9, color: Color(0xFFE1D2AE), accent: Color(0xFFF3E8CC), shape: _Shape.ring),
  (x: 0.02, y: 0.02, delay: 0.48, size: 26, spin: 2.1, color: Color(0xFFC33A20), accent: Color(0xFFE96E4C), shape: _Shape.disc),
];

class _FallingIngredient extends StatelessWidget {
  const _FallingIngredient({
    required this.controller,
    required this.spec,
    required this.area,
  });

  final AnimationController controller;
  final _IngredientSpec spec;
  final Size area;

  @override
  Widget build(BuildContext context) {
    final Animation<double> t = CurvedAnimation(
      parent: controller,
      curve: Interval(
        spec.delay,
        (spec.delay + 0.34).clamp(0.0, 1.0),
        curve: Ease.spring,
      ),
    );

    // The pizza is bottom-aligned in this box and is `area.width` across, so
    // its centre sits half a diameter up from the bottom.
    final double pizzaCentreY = area.height - area.width / 2;
    final double radius = area.width / 2;

    final double endX = area.width / 2 + spec.x * radius * 0.78;
    final double endY = pizzaCentreY + spec.y * radius * 0.78;
    final double startY = -80.0;

    return AnimatedBuilder(
      animation: t,
      builder: (BuildContext context, Widget? child) {
        final double v = t.value;
        // Drifts sideways on the way down instead of falling straight, so six
        // ingredients do not read as six parallel columns.
        final double driftX = endX - spec.x * radius * 0.35 * (1 - v);
        return Positioned(
          left: driftX - spec.size / 2,
          top: startY + (endY - startY) * v,
          child: Opacity(
            opacity: (v * 5).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: spec.spin * (1 - v),
              child: child,
            ),
          ),
        );
      },
      child: SizedBox(
        width: spec.size,
        height: spec.size,
        child: CustomPaint(painter: _IngredientPainter(spec)),
      ),
    );
  }
}

class _IngredientPainter extends CustomPainter {
  _IngredientPainter(this.spec);

  final _IngredientSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    switch (spec.shape) {
      case _Shape.disc:
        canvas.drawCircle(c, r, Paint()..color = spec.color);
        canvas.drawCircle(
          c.translate(-r * 0.25, -r * 0.25),
          r * 0.4,
          Paint()..color = spec.accent.withValues(alpha: 0.8),
        );
      case _Shape.ring:
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.42
            ..color = spec.color,
        );
        canvas.drawCircle(
          c,
          r * 0.78,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.16
            ..color = spec.accent,
        );
      case _Shape.leaf:
        final Path leaf = Path()
          ..moveTo(c.dx - r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy - r, c.dx + r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy + r, c.dx - r, c.dy)
          ..close();
        canvas.drawPath(leaf, Paint()..color = spec.color);
        canvas.drawLine(
          Offset(c.dx - r * 0.7, c.dy),
          Offset(c.dx + r * 0.7, c.dy),
          Paint()
            ..strokeWidth = r * 0.1
            ..color = spec.accent,
        );
    }
  }

  @override
  bool shouldRepaint(_IngredientPainter old) => false;
}

class _RiseIn extends StatelessWidget {
  const _RiseIn({
    required this.controller,
    required this.begin,
    required this.end,
    required this.child,
  });

  final AnimationController controller;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> t = CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: Ease.spring),
    );
    return AnimatedBuilder(
      animation: t,
      builder: (BuildContext context, Widget? c) => Opacity(
        opacity: t.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.82 + 0.18 * t.value, child: c),
      ),
      child: child,
    );
  }
}
