import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';

/// Entrance choreography.
///
/// Each child fades up from a short offset, one step after the last. The step
/// is small on purpose: a stagger you consciously notice is too slow, and the
/// whole group should be settled well inside half a second. The point is only
/// to give the screen a reading order, not to perform.
class StaggerGroup extends StatefulWidget {
  const StaggerGroup({
    super.key,
    required this.children,
    this.step = Motion.staggerNormal,
    this.offset = 18,
    this.delay = Duration.zero,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final Duration step;
  final double offset;
  final Duration delay;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<StaggerGroup> createState() => _StaggerGroupState();
}

class _StaggerGroupState extends State<StaggerGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    final int n = widget.children.length;
    final Duration total = widget.step * (n - 1) + Motion.medium;
    _c = AnimationController(vsync: this, duration: total);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _c.value = 1.0;
        return;
      }
      Future<void>.delayed(widget.delay, () {
        if (mounted) {
          _c.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int n = widget.children.length;
    final Duration total = _c.duration ?? Motion.medium;
    final double totalMs = total.inMilliseconds.toDouble();

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < n; i++)
          _StaggerItem(
            controller: _c,
            begin: (widget.step.inMilliseconds * i) / totalMs,
            end: ((widget.step.inMilliseconds * i) + Motion.medium.inMilliseconds) /
                totalMs,
            offset: widget.offset,
            child: widget.children[i],
          ),
      ],
    );
  }
}

class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.controller,
    required this.begin,
    required this.end,
    required this.offset,
    required this.child,
  });

  final AnimationController controller;
  final double begin;
  final double end;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> t = CurvedAnimation(
      parent: controller,
      curve: Interval(begin.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Ease.out),
    );
    return AnimatedBuilder(
      animation: t,
      builder: (BuildContext context, Widget? c) {
        return Opacity(
          opacity: t.value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t.value)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
