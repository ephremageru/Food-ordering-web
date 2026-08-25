import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';

/// Small food drawings for the category pucks.
///
/// Drawn rather than set as emoji: emoji render differently on every platform
/// and would be the one place in the app where the art direction is decided by
/// the operating system.
class CategoryGlyphArt extends StatelessWidget {
  const CategoryGlyphArt({super.key, required this.glyph});

  final CategoryGlyph glyph;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlyphPainter(glyph),
      size: Size.infinite,
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph);

  final CategoryGlyph glyph;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    final Offset c = Offset(size.width / 2, size.height / 2);
    switch (glyph) {
      case CategoryGlyph.all:
        _all(canvas, c, s);
      case CategoryGlyph.beef:
        _beef(canvas, c, s);
      case CategoryGlyph.chicken:
        _chicken(canvas, c, s);
      case CategoryGlyph.cheese:
        _cheese(canvas, c, s);
      case CategoryGlyph.mushroom:
        _mushroom(canvas, c, s);
    }
  }

  /// A 3x3 dot grid — the conventional "everything" affordance.
  void _all(Canvas canvas, Offset c, double s) {
    final Paint p = Paint()..color = AppColors.ink;
    final double gap = s * 0.19;
    final double r = s * 0.045;
    for (int y = -1; y <= 1; y++) {
      for (int x = -1; x <= 1; x++) {
        canvas.drawCircle(c + Offset(x * gap, y * gap), r, p);
      }
    }
  }

  void _beef(Canvas canvas, Offset c, double s) {
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, s * 0.1), width: s * 0.62, height: s * 0.3),
      Paint()..color = const Color(0xFFE8D5B8),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: s * 0.56, height: s * 0.34),
      Paint()..color = const Color(0xFF7A3B22),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(-s * 0.06, -s * 0.05), width: s * 0.3, height: s * 0.14),
      Paint()..color = const Color(0xFFA85434),
    );
  }

  void _chicken(Canvas canvas, Offset c, double s) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.6);
    // Drumstick meat.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -s * 0.1), width: s * 0.42, height: s * 0.46),
      Paint()..color = const Color(0xFFC98A46),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-s * 0.05, -s * 0.16), width: s * 0.22, height: s * 0.2),
      Paint()..color = const Color(0xFFE3B173),
    );
    // Bone.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, s * 0.2), width: s * 0.12, height: s * 0.3),
        Radius.circular(s * 0.06),
      ),
      Paint()..color = const Color(0xFFF3E9D6),
    );
    canvas.drawCircle(Offset(0, s * 0.33), s * 0.09, Paint()..color = const Color(0xFFF3E9D6));
    canvas.restore();
  }

  /// A cheese wedge seen at a slight angle: a rounded back edge, a lighter cut
  /// face on top, and holes. Drawn as a plain triangle it reads as a warning
  /// sign, which is exactly what the first version looked like.
  void _cheese(Canvas canvas, Offset c, double s) {
    final double w = s * 0.34;
    final double h = s * 0.19;

    // Body: apex at the left, rounded rind on the right.
    final Path body = Path()
      ..moveTo(c.dx - w, c.dy + h * 0.2)
      ..quadraticBezierTo(
          c.dx + w * 0.55, c.dy - h * 1.5, c.dx + w, c.dy - h * 0.15)
      ..lineTo(c.dx + w, c.dy + h * 0.75)
      ..quadraticBezierTo(
          c.dx + w * 0.1, c.dy + h * 1.15, c.dx - w, c.dy + h * 0.95)
      ..close();

    canvas.drawPath(body, Paint()..color = const Color(0xFFD79B2C));

    // Lit cut face.
    final Path face = Path()
      ..moveTo(c.dx - w, c.dy + h * 0.2)
      ..quadraticBezierTo(
          c.dx + w * 0.55, c.dy - h * 1.5, c.dx + w, c.dy - h * 0.15)
      ..quadraticBezierTo(
          c.dx + w * 0.1, c.dy + h * 0.35, c.dx - w, c.dy + h * 0.2)
      ..close();
    canvas.drawPath(face, Paint()..color = const Color(0xFFF6D268));

    final Paint hole = Paint()..color = const Color(0xFFC1841F);
    canvas.drawCircle(c.translate(w * 0.12, -h * 0.12), s * 0.042, hole);
    canvas.drawCircle(c.translate(w * 0.58, h * 0.05), s * 0.030, hole);
    canvas.drawCircle(c.translate(-w * 0.35, h * 0.42), s * 0.026, hole);
  }

  void _mushroom(Canvas canvas, Offset c, double s) {
    final Path cap = Path()
      ..moveTo(c.dx - s * 0.3, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx - s * 0.3, c.dy - s * 0.3, c.dx, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.3, c.dy - s * 0.3, c.dx + s * 0.3, c.dy + s * 0.02)
      ..close();
    canvas.drawPath(cap, Paint()..color = const Color(0xFF9A6B44));
    canvas.drawPath(
      cap.shift(Offset(0, -s * 0.05)),
      Paint()..color = const Color(0xFFB98455),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * 0.16), width: s * 0.19, height: s * 0.3),
        Radius.circular(s * 0.05),
      ),
      Paint()..color = const Color(0xFFF0E2CC),
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.glyph != glyph;
}
