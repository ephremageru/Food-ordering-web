import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';

/// A number that rolls to its new value on a spring.
///
/// Prices and totals change constantly — size, quantity, toppings — and a value
/// that snaps makes the whole screen feel like it re-rendered. Rolling the
/// digits ties the new number to the control that caused it.
///
/// Only this widget rebuilds while the value is in motion; the controller is
/// listened to by an [AnimatedBuilder] rather than calling setState, so the
/// surrounding layout is untouched.
class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.decimals = 2,
  });

  final double value;
  final TextStyle? style;
  final String prefix;
  final int decimals;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.medium,
  );
  late double _from = widget.value;
  late double _to = widget.value;

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      // Resume from wherever the last roll got to, so rapid changes chain
      // instead of jumping back to the previous settled value.
      _from = _current;
      _to = widget.value;
      _c
        ..value = 0
        ..animateTo(
          1.0,
          duration: Motion.medium,
          curve: Ease.spring,
        );
    }
  }

  double get _current => _from + (_to - _from) * _c.value;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        return Text(
          '${widget.prefix}${_current.toStringAsFixed(widget.decimals)}',
          style: widget.style,
        );
      },
    );
  }
}
