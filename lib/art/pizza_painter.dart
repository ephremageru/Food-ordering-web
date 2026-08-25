import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/pizza.dart';
import '../theme/app_theme.dart';

/// Deterministic RNG.
///
/// Every scatter in the artwork is seeded from the pizza, so the same pizza
/// draws pixel-identically everywhere it appears. That matters more than it
/// sounds: during a hero flight the same pizza is painted at two different
/// sizes on two different screens, and a re-randomised topping scatter would
/// visibly "reshuffle" mid-flight and destroy the sense that it is one object.
class _Rng {
  _Rng(this.seed);
  int seed;

  double next() {
    seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return seed / 0x7FFFFFFF;
  }

  double range(double a, double b) => a + next() * (b - a);
}

/// A top-down pizza, drawn entirely with canvas primitives.
class PizzaArt extends StatelessWidget {
  const PizzaArt({super.key, required this.pizza, this.slices = 8});

  final Pizza pizza;
  final int slices;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PizzaPainter(pizza: pizza, slices: slices),
        size: Size.infinite,
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

class _PizzaPainter extends CustomPainter {
  _PizzaPainter({required this.pizza, required this.slices});

  final Pizza pizza;
  final int slices;

  @override
  void paint(Canvas canvas, Size size) {
    final double r = math.min(size.width, size.height) / 2;
    if (r <= 0) {
      return;
    }
    final Offset c = Offset(size.width / 2, size.height / 2);
    final _Rng rng = _Rng(pizza.toppingSeed);

    _paintCrust(canvas, c, r, rng);
    _paintSauce(canvas, c, r);
    _paintCheese(canvas, c, r, rng);
    _paintSliceCuts(canvas, c, r);
    _paintToppings(canvas, c, r, rng);
    _paintBasilTuft(canvas, c, r, rng);
  }

  void _paintCrust(Canvas canvas, Offset c, double r, _Rng rng) {
    final Rect bounds = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(c.dx - r * 0.25, c.dy - r * 0.3),
          r * 1.25,
          <Color>[
            const Color(0xFFF0BE7C),
            const Color(0xFFDD9A4E),
            const Color(0xFFB56A2A),
          ],
          <double>[0.55, 0.84, 1.0],
        ),
    );

    // Charred blisters around the rim.
    final Paint char = Paint();
    for (int i = 0; i < 40; i++) {
      final double a = rng.range(0, math.pi * 2);
      final double rad = rng.range(r * 0.88, r * 0.98);
      final double blob = rng.range(r * 0.012, r * 0.030);
      char.color = Color.lerp(
        const Color(0xFF8A4A17),
        const Color(0xFFFFD9A0),
        rng.next(),
      )!
          .withValues(alpha: rng.range(0.10, 0.30));
      canvas.drawCircle(
        c + Offset(math.cos(a) * rad, math.sin(a) * rad),
        blob,
        char,
      );
    }

    // Inner shadow where the crust rolls down to the filling.
    canvas.drawCircle(
      c,
      r * 0.83,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.045
        ..color = const Color(0xFF8F5320).withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
    );

    // Rim light along the top edge.
    canvas.drawArc(
      bounds.deflate(r * 0.02),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.045
        ..color = Colors.white.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
    );
  }

  void _paintSauce(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c,
      r * 0.82,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * 0.82,
          <Color>[pizza.sauce, Color.lerp(pizza.sauce, Colors.black, 0.22)!],
          <double>[0.6, 1.0],
        ),
    );
  }

  void _paintCheese(Canvas canvas, Offset c, double r, _Rng rng) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.82)));

    // Base melt, pulled in slightly so sauce shows as a thin rim.
    canvas.drawCircle(
      c,
      r * 0.795,
      Paint()..color = pizza.cheese,
    );

    // Mottling: many small, low-contrast pools rather than a few large ones.
    // Large translucent blobs read as a stain on the cheese; small ones read as
    // the uneven surface of something that melted.
    final Paint pool = Paint();
    for (int i = 0; i < 90; i++) {
      final double a = rng.range(0, math.pi * 2);
      final double rad = r * 0.76 * math.sqrt(rng.next());
      final double blob = rng.range(r * 0.020, r * 0.070);
      final bool browned = rng.next() > 0.72;
      pool.color = browned
          ? const Color(0xFFC98A3E).withValues(alpha: rng.range(0.06, 0.16))
          : Color.lerp(pizza.cheese, Colors.white, rng.range(0.25, 0.6))!
              .withValues(alpha: rng.range(0.10, 0.26));
      canvas.drawCircle(
        c + Offset(math.cos(a) * rad, math.sin(a) * rad),
        blob,
        pool,
      );
    }

    // A soft warm vignette so the centre sits back and the rim catches light.
    canvas.drawCircle(
      c,
      r * 0.795,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(c.dx - r * 0.22, c.dy - r * 0.26),
          r * 0.95,
          <Color>[
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
            const Color(0xFF8A5A22).withValues(alpha: 0.16),
          ],
          <double>[0.0, 0.55, 1.0],
        ),
    );
    canvas.restore();
  }

  void _paintSliceCuts(Canvas canvas, Offset c, double r) {
    final Paint cut = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, r * 0.011)
      ..color = const Color(0xFF9A5C25).withValues(alpha: 0.3);
    for (int i = 0; i < slices; i++) {
      final double a = (math.pi * 2 / slices) * i + math.pi / slices;
      canvas.drawLine(
        c + Offset(math.cos(a) * r * 0.06, math.sin(a) * r * 0.06),
        c + Offset(math.cos(a) * r * 0.82, math.sin(a) * r * 0.82),
        cut,
      );
    }
  }

  void _paintToppings(Canvas canvas, Offset c, double r, _Rng rng) {
    final int count = switch (pizza.categoryId) {
      'cheese' => 5,
      'mushroom' => 13,
      'chicken' => 14,
      _ => 12,
    };

    for (int i = 0; i < count; i++) {
      // Golden-angle placement keeps the scatter even without clumping, then a
      // small jitter takes the regularity back out of it.
      final double a = i * 2.39996 + rng.range(-0.35, 0.35);
      final double rad = r * 0.74 * math.sqrt((i + 0.6) / count) +
          rng.range(-r * 0.03, r * 0.03);
      final Offset p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      final double s = r * rng.range(0.1, 0.14);

      switch (pizza.categoryId) {
        case 'beef':
          _pepperoni(canvas, p, s, rng);
        case 'chicken':
          _chicken(canvas, p, s * 1.05, rng);
        case 'mushroom':
          _mushroom(canvas, p, s * 1.1, rng);
        case 'cheese':
          _cheeseDollop(canvas, p, s * 1.15, rng);
        default:
          if (i.isEven) {
            _pepperoni(canvas, p, s, rng);
          } else {
            _mushroom(canvas, p, s * 1.05, rng);
          }
      }
    }
  }

  /// Pepperoni reads as a *slice* — a flat disc with a darkened cupped rim —
  /// not a ball. The temptation is a strong radial gradient, but that is
  /// exactly what turns it into a sphere; the shading here is nearly flat with
  /// the contrast pushed out to the edge instead.
  void _pepperoni(Canvas canvas, Offset p, double s, _Rng rng) {
    // Contact shadow, tight to the disc.
    canvas.drawCircle(
      p.translate(0, s * 0.1),
      s * 1.02,
      Paint()
        ..color = const Color(0xFF6B2410).withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.16),
    );

    // Darker cupped rim.
    canvas.drawCircle(p, s, Paint()..color = const Color(0xFF9B2A14));

    // Flat face, only slightly lit.
    canvas.drawCircle(
      p,
      s * 0.86,
      Paint()
        ..shader = ui.Gradient.radial(
          p.translate(-s * 0.18, -s * 0.20),
          s * 1.35,
          <Color>[const Color(0xFFCE4526), const Color(0xFFB2331B)],
        ),
    );

    // Rendered fat flecks, kept inside the face.
    for (int i = 0; i < 5; i++) {
      final double a = rng.range(0, math.pi * 2);
      final double rad = s * 0.62 * math.sqrt(rng.next());
      canvas.drawCircle(
        p + Offset(math.cos(a) * rad, math.sin(a) * rad),
        s * rng.range(0.06, 0.13),
        Paint()..color = const Color(0xFFEBB093).withValues(alpha: 0.5),
      );
    }

    // Crisped highlight on the upper rim only.
    canvas.drawArc(
      Rect.fromCircle(center: p, radius: s * 0.93),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.13
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE0714E).withValues(alpha: 0.45),
    );
  }

  void _mushroom(Canvas canvas, Offset p, double s, _Rng rng) {
    final double rot = rng.range(0, math.pi * 2);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(rot);
    final Path cap = Path()
      ..moveTo(-s * 0.85, s * 0.2)
      ..quadraticBezierTo(-s * 0.9, -s * 0.85, 0, -s * 0.85)
      ..quadraticBezierTo(s * 0.9, -s * 0.85, s * 0.85, s * 0.2)
      ..lineTo(s * 0.3, s * 0.2)
      ..lineTo(s * 0.3, s * 0.75)
      ..lineTo(-s * 0.3, s * 0.75)
      ..lineTo(-s * 0.3, s * 0.2)
      ..close();
    canvas.drawPath(
      cap,
      Paint()..color = const Color(0xFF6B5340).withValues(alpha: 0.28),
    );
    canvas.drawPath(
      cap.shift(Offset(0, -s * 0.1)),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, -s),
          Offset(0, s),
          <Color>[const Color(0xFFF0E2CC), const Color(0xFFBFA887)],
        ),
    );
    canvas.restore();
  }

  void _chicken(Canvas canvas, Offset p, double s, _Rng rng) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(rng.range(0, math.pi * 2));
    final RRect chunk = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: s * 1.7, height: s * 1.25),
      Radius.circular(s * 0.45),
    );
    canvas.drawRRect(
      chunk.shift(Offset(0, s * 0.18)),
      Paint()..color = const Color(0xFF7A5A34).withValues(alpha: 0.3),
    );
    canvas.drawRRect(
      chunk,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, -s),
          Offset(0, s),
          <Color>[const Color(0xFFF6DFB4), const Color(0xFFCE9A55)],
        ),
    );
    // Grill char.
    canvas.drawLine(
      Offset(-s * 0.6, -s * 0.15),
      Offset(s * 0.6, -s * 0.15),
      Paint()
        ..strokeWidth = s * 0.14
        ..color = const Color(0xFF8B5A22).withValues(alpha: 0.5),
    );
    canvas.restore();
  }

  /// A torn blob of mozzarella. Drawn as a wobbled circle rather than a true
  /// one — a perfectly round white disc reads as a button, and it was the main
  /// reason the white pizzas looked like flat graphics rather than food.
  void _cheeseDollop(Canvas canvas, Offset p, double s, _Rng rng) {
    final Path blob = Path();
    const int lobes = 9;
    for (int i = 0; i <= lobes; i++) {
      final double a = (math.pi * 2 / lobes) * i;
      final double rr = s * rng.range(0.78, 1.12);
      final Offset pt = p + Offset(math.cos(a) * rr, math.sin(a) * rr);
      if (i == 0) {
        blob.moveTo(pt.dx, pt.dy);
      } else {
        blob.lineTo(pt.dx, pt.dy);
      }
    }
    blob.close();

    canvas.drawPath(
      blob.shift(Offset(0, s * 0.12)),
      Paint()
        ..color = const Color(0xFF9B7A3E).withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.2),
    );
    canvas.drawPath(
      blob,
      Paint()
        ..shader = ui.Gradient.radial(
          p.translate(-s * 0.28, -s * 0.32),
          s * 1.7,
          <Color>[const Color(0xFFFFFBF0), const Color(0xFFEBD9AE)],
        ),
    );
    // Browned edge where it caught the oven.
    canvas.drawPath(
      blob,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.1
        ..color = const Color(0xFFC7973F).withValues(alpha: 0.45),
    );
  }

  /// The basil tuft at the centre — the single green note that makes the whole
  /// disc read as food rather than as a texture study.
  void _paintBasilTuft(Canvas canvas, Offset c, double r, _Rng rng) {
    for (int i = 0; i < 3; i++) {
      final double a = -math.pi / 2 + (i - 1) * 0.95 + rng.range(-0.12, 0.12);
      final double len = r * rng.range(0.19, 0.25);
      _basilLeaf(canvas, c, a, len);
    }
  }

  void _basilLeaf(Canvas canvas, Offset origin, double angle, double len) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final double w = len * 0.5;
    final Path leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.45, -w, len, 0)
      ..quadraticBezierTo(len * 0.45, w, 0, 0)
      ..close();
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(len, 0),
          <Color>[const Color(0xFF3F7A32), const Color(0xFF6FB44A)],
        ),
    );
    canvas.drawPath(
      leaf,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = len * 0.04
        ..color = const Color(0xFF2C5A22).withValues(alpha: 0.5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PizzaPainter old) =>
      old.pizza.id != pizza.id || old.slices != slices;
}

/// The pizza plus its cast shadow, sized to a box. This is the unit that flies
/// during a hero transition and during the add-to-cart flight.
class PizzaDisc extends StatelessWidget {
  const PizzaDisc({
    super.key,
    required this.pizza,
    required this.size,
    this.slices = 8,
    this.shadow = true,
  });

  final Pizza pizza;
  final double size;
  final int slices;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: shadow ? Shadows.pizza : null,
        ),
        child: PizzaArt(pizza: pizza, slices: slices),
      ),
    );
  }
}
