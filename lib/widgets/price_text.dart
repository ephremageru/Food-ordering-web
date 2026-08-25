import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_number.dart';

/// The price lockup used across the app: a small raised orange currency mark
/// against a large dark number. Keeping it in one widget is what stops the
/// dollar sign drifting a pixel between the card, the detail screen, and the
/// cart.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.value,
    this.size = 22,
    this.animate = true,
    this.color = AppColors.ink,
  });

  final double value;
  final double size;
  final bool animate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle numberStyle = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.0,
      color: color,
    );

    return Semantics(
      label: '\$${value.toStringAsFixed(2)}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: size * 0.08),
            child: Text(
              '\$',
              style: TextStyle(
                fontSize: size * 0.52,
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: AppColors.orange,
              ),
            ),
          ),
          const SizedBox(width: 1.5),
          if (animate)
            AnimatedNumber(value: value, style: numberStyle)
          else
            Text(value.toStringAsFixed(2), style: numberStyle),
        ],
      ),
    );
  }
}
