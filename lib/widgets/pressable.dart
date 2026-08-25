import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';

/// Press feedback for anything tappable.
///
/// Driven by a real spring rather than [AnimatedScale] for one specific reason:
/// releasing mid-press hands the controller's current velocity to the return
/// simulation. A tween would restart from wherever the value happened to be and
/// ease to rest, which makes a quick tap feel like it "catches". This carries
/// through, so mashing the button stays fluid.
///
/// Target is the specified 1.0 -> 0.96 over ~150ms.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.semanticLabel,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.fast,
    // Bounds are widened so a spring overshoot on release is not clamped flat.
    lowerBound: -0.2,
    upperBound: 1.2,
  );

  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _press() {
    if (_reduced) {
      return;
    }
    // Pressing down is a tween, not a spring: the finger is driving it, and it
    // must reach the pressed state within the 150ms budget without overshoot.
    _c.animateTo(1.0, duration: Motion.fast, curve: Ease.standard);
  }

  void _release() {
    if (_reduced) {
      return;
    }
    SpringDriver.to(_c, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double t = _c.value;
        return Transform.scale(
          scale: 1.0 - (1.0 - widget.scale) * t,
          child: child,
        );
      },
      child: widget.child,
    );

    // `container: true` is load-bearing, not decorative. A Pressable that wraps
    // another Pressable — the pizza card wraps its own "+" button — otherwise
    // has no node of its own, and the card ends up announced to a screen reader
    // as "Add Pepperoni Classico to cart" instead of by its name and
    // description. Forcing a container gives the outer control its own node and
    // leaves the inner button as a separate one.
    return Semantics(
      container: widget.semanticLabel != null,
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: (_) => _press(),
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}
