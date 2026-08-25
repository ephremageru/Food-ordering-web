import 'package:flutter/material.dart';

import 'animation_constants.dart';
import 'motion_curves.dart';

/// The app's route transitions.
///
/// There is deliberately no single transition reused for every screen. Each one
/// encodes what the navigation *means*, so the motion tells you where you are
/// in the flow before you have read a word:
///
/// * [morphRoute] — a shared element is carrying the continuity, so the page
///   itself must get out of the way. It only clears the stage.
/// * [pushRoute] — going deeper into a flow. Slides in from the trailing edge.
/// * [riseRoute] — a surface arriving over the current one, spring driven.
/// * [dissolveRoute] — sibling destinations that make no spatial claim on each
///   other. No translation at all, or the tabs would imply an order.
/// * [revealRoute] — a hand-off that replaces the whole context.
class AppRoutes {
  const AppRoutes._();

  /// Reduced-motion is honoured at the route level as well as inside widgets:
  /// when it is on, every route collapses to a short cross-fade rather than
  /// simply running the same translation faster.
  static bool _reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Widget _fadeOnly(Animation<double> animation, Widget child) =>
      FadeTransition(opacity: animation, child: child);

  /// Used for Home -> Detail. The hero does the talking; the incoming page just
  /// fades up from slightly scaled-down, and the outgoing page fades and blurs
  /// away beneath it.
  static PageRouteBuilder<T> morphRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Motion.medium,
      reverseTransitionDuration: Motion.normal,
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (BuildContext _, Animation<double> _, Animation<double> _) =>
          page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        if (_reduced(context)) {
          return _fadeOnly(animation, child);
        }
        final Animation<double> t = CurvedAnimation(
          parent: animation,
          curve: Ease.out,
          reverseCurve: Ease.exit,
        );
        return FadeTransition(
          opacity: t,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.965, end: 1.0).animate(t),
            child: child,
          ),
        );
      },
    );
  }

  /// Deeper into a flow: Cart -> Checkout.
  static PageRouteBuilder<T> pushRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Motion.normal,
      reverseTransitionDuration: Motion.quick,
      pageBuilder: (BuildContext _, Animation<double> _, Animation<double> _) =>
          page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        if (_reduced(context)) {
          return _fadeOnly(animation, child);
        }
        final Animation<double> t = CurvedAnimation(
          parent: animation,
          curve: Ease.out,
          reverseCurve: Ease.exit,
        );
        // The outgoing page recedes slightly instead of sitting still, which is
        // what gives the stack a sense of depth.
        final Animation<double> out = CurvedAnimation(
          parent: secondary,
          curve: Ease.standard,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.16, 0),
            end: Offset.zero,
          ).animate(t),
          child: FadeTransition(
            opacity: t,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.08, 0),
              ).animate(out),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// A surface rising over the current screen, driven by the specified spring
  /// rather than a tween — this is the one transition where the overshoot is
  /// visible and wanted.
  static PageRouteBuilder<T> riseRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: SpringCurve.settleDuration(Springs.heavy),
      reverseTransitionDuration: Motion.normal,
      pageBuilder: (BuildContext _, Animation<double> _, Animation<double> _) =>
          page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        if (_reduced(context)) {
          return _fadeOnly(animation, child);
        }
        final Animation<double> t = CurvedAnimation(
          parent: animation,
          curve: Ease.springHeavy,
          reverseCurve: Ease.exit.flipped,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(t),
          child: child,
        );
      },
    );
  }

  /// Sibling tabs. No translation — a slide would imply the destinations are
  /// ordered, which they are not.
  static PageRouteBuilder<T> dissolveRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Motion.normal,
      reverseTransitionDuration: Motion.quick,
      pageBuilder: (BuildContext _, Animation<double> _, Animation<double> _) =>
          page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        if (_reduced(context)) {
          return _fadeOnly(animation, child);
        }
        final Animation<double> t =
            CurvedAnimation(parent: animation, curve: Ease.standard);
        return FadeTransition(
          opacity: t,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.02, end: 1.0).animate(t),
            child: child,
          ),
        );
      },
    );
  }

  /// Onboarding handing off to the app, and Success handing off to Orders. The
  /// outgoing screen scales up and blurs out of the way rather than sliding,
  /// because nothing is "beside" it — it is being replaced.
  static PageRouteBuilder<T> revealRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: Motion.medium,
      reverseTransitionDuration: Motion.normal,
      pageBuilder: (BuildContext _, Animation<double> _, Animation<double> _) =>
          page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        if (_reduced(context)) {
          return _fadeOnly(animation, child);
        }
        final Animation<double> t =
            CurvedAnimation(parent: animation, curve: Ease.out);
        return FadeTransition(
          opacity: t,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.06, end: 1.0).animate(t),
            child: child,
          ),
        );
      },
    );
  }
}
