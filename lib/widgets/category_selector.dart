import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../art/category_glyph.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// The category arc.
///
/// The pucks sit on a parabola rather than a straight row: the centre item is
/// highest and largest, and items fall away and shrink toward the edges. That
/// shape is doing real work — it makes a five-item row read as a curved surface
/// receding at the sides, so the strip feels like part of a physical dial
/// instead of a list of buttons.
///
/// Selection is communicated three ways at once, all spring driven: the puck
/// scales up, the label goes bold and dark, and a short bar travels along the
/// arc from the old label to the new one. The bar *travels* — it is never
/// removed and re-added, because a bar that reappears elsewhere tells you the
/// selection changed but not where it came from.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  static const double height = 172;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final List<Category> items = Category.all;
          final int n = items.length;
          final double width = constraints.maxWidth;

          // Slot spacing is wider than the viewport so the outermost pucks are
          // cropped by the screen edge, which is what makes the arc read as
          // continuing past the frame rather than stopping.
          final double slot = width / (n - 0.5);
          final double baseSide = math.min(slot * 0.72, 76);
          final double arcDepth = 46;

          final List<Widget> pucks = <Widget>[];
          double? indicatorX;

          for (int i = 0; i < n; i++) {
            final Category cat = items[i];
            // Normalised position across the arc, -1 (left) .. 1 (right).
            final double u = (i - (n - 1) / 2) / ((n - 1) / 2);
            final double cx = width / 2 + u * slot * ((n - 1) / 2);
            final double drop = arcDepth * u * u;
            final double depthScale = 1.0 - 0.26 * u.abs();
            final bool selected = cat.id == selectedId;

            if (selected) {
              indicatorX = cx;
            }

            pucks.add(
              Positioned(
                left: cx - slot / 2,
                top: drop,
                width: slot,
                child: _CategoryPuck(
                  category: cat,
                  side: baseSide * depthScale,
                  selected: selected,
                  onTap: () => onSelected(cat.id),
                ),
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // The soft panel the arc sits on, which gives the curve something
              // to be curved against.
              Positioned(
                left: -width * 0.14,
                right: -width * 0.14,
                top: -26,
                height: height + 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.panel.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(width * 0.9, 120),
                    ),
                  ),
                ),
              ),
              ...pucks,
              if (indicatorX != null)
                AnimatedPositioned(
                  duration: Motion.medium,
                  curve: Ease.spring,
                  left: indicatorX - 13,
                  top: _labelBaseline(
                    indicatorX,
                    width,
                    slot,
                    Category.all.length,
                    baseSide,
                    arcDepth,
                  ),
                  child: Container(
                    width: 26,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Where the indicator bar sits for a puck at [cx] — it has to follow the
  /// same parabola the pucks do, or the bar would cut across the arc instead of
  /// riding along it.
  static double _labelBaseline(
    double cx,
    double width,
    double slot,
    int n,
    double baseSide,
    double arcDepth,
  ) {
    final double u = ((cx - width / 2) / (slot * ((n - 1) / 2))).clamp(-1.0, 1.0);
    final double drop = arcDepth * u * u;
    final double depthScale = 1.0 - 0.26 * u.abs();
    return drop + baseSide * depthScale + 30;
  }
}

class _CategoryPuck extends StatelessWidget {
  const _CategoryPuck({
    required this.category,
    required this.side,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final double side;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: '${category.label} category',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedScale(
            duration: Motion.medium,
            curve: Ease.spring,
            scale: selected ? 1.14 : 1.0,
            child: AnimatedContainer(
              duration: Motion.normal,
              curve: Ease.standard,
              width: side,
              height: side,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: selected ? Shadows.lifted : Shadows.card,
              ),
              child: Padding(
                padding: EdgeInsets.all(side * 0.2),
                child: CategoryGlyphArt(glyph: category.glyph),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedDefaultTextStyle(
            duration: Motion.normal,
            curve: Ease.standard,
            style: TextStyle(
              fontSize: selected ? 13.5 : 12.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.ink : AppColors.muted,
            ),
            // Clipped, not ellipsised: the outermost pucks are meant to bleed
            // off the screen edge, and an ellipsis would make that read as a
            // truncation bug rather than as the arc continuing.
            child: Text(
              category.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
