import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// Stepper whose number slides in the direction of the change.
///
/// Direction is the whole point: incrementing pushes the old digit up and
/// brings the new one in from below, decrementing does the reverse. A plain
/// cross-fade would tell you the number changed but not which way, which is
/// exactly the information the control exists to convey.
class QuantitySelector extends StatefulWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.vertical = false,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool vertical;
  final bool compact;

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _direction = 1;

  void _step(int delta) {
    final int next = (widget.value + delta).clamp(widget.min, widget.max);
    if (next == widget.value) {
      return;
    }
    setState(() => _direction = delta);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final double side = widget.compact ? 26 : 32;

    final Widget number = SizedBox(
      width: widget.compact ? 22 : 30,
      height: widget.compact ? 22 : 26,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: Motion.quick,
          switchInCurve: Ease.out,
          switchOutCurve: Ease.exit,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final bool incoming = child.key == ValueKey<int>(widget.value);
            final double sign = incoming ? _direction.toDouble() : -_direction.toDouble();
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.7 * sign),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Center(
            key: ValueKey<int>(widget.value),
            child: Text(
              '${widget.value}',
              style: TextStyle(
                fontSize: widget.compact ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );

    final List<Widget> children = <Widget>[
      _StepButton(
        icon: Icons.remove_rounded,
        side: side,
        enabled: widget.value > widget.min,
        label: 'Decrease quantity',
        onTap: () => _step(-1),
      ),
      number,
      _StepButton(
        icon: Icons.add_rounded,
        side: side,
        enabled: widget.value < widget.max,
        label: 'Increase quantity',
        onTap: () => _step(1),
      ),
    ];

    return Semantics(
      value: '${widget.value}',
      child: Container(
        padding: EdgeInsets.all(widget.compact ? 3 : 5),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(Radii.chip),
          border: Border.all(color: AppColors.hairline),
        ),
        child: widget.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: children.reversed.toList(),
              )
            : Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.side,
    required this.enabled,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final double side;
  final bool enabled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      scale: 0.86,
      semanticLabel: label,
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: enabled ? 1 : 0.3,
        // 44x44 minimum touch target regardless of the drawn size.
        child: SizedBox(
          width: side < 44 ? 44 : side,
          height: side < 44 ? 44 : side,
          child: Center(
            child: Container(
              width: side,
              height: side,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: side * 0.55, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
