import 'package:flutter/physics.dart';

/// Central timing table for the whole app.
///
/// Screens and widgets never inline a duration — every value used anywhere in
/// Pizzafy is named here, so the motion language can be tuned in one place.
/// The numbers come from the Master Animation Specification in
/// `docs/MASTER_ANIMATION_SPEC.md`, which was derived from the reference
/// recording frame by frame.
class Motion {
  const Motion._();

  /// Press / release feedback. Must feel instantaneous.
  static const Duration fast = Duration(milliseconds: 150);

  /// Quantity roll, chip selection, small state swaps.
  static const Duration quick = Duration(milliseconds: 200);

  /// The workhorse: page fades, indicator travel, grid reflow.
  static const Duration normal = Duration(milliseconds: 280);

  /// Larger surfaces — detail entrance, sheet, size change.
  static const Duration medium = Duration(milliseconds: 400);

  /// Hero flight between home card and detail hero slot.
  static const Duration hero = Duration(milliseconds: 520);

  /// The add-to-cart pizza flight. Specified exactly.
  static const Duration cartFlight = Duration(milliseconds: 650);

  /// Add-to-cart button collapsing into its circular confirm state.
  static const Duration buttonMorph = Duration(milliseconds: 320);

  /// Success screen ring sweep and checkmark stroke.
  static const Duration ringDraw = Duration(milliseconds: 520);
  static const Duration checkDraw = Duration(milliseconds: 420);

  /// Stagger steps for entrance choreography.
  static const Duration staggerTight = Duration(milliseconds: 35);
  static const Duration staggerNormal = Duration(milliseconds: 55);
}

/// The single spring used for everything physical in the app.
///
/// Specified as stiffness 250 / damping 25. With mass 1 the critical damping
/// coefficient is `2 * sqrt(k * m)` = 31.62, so a damping of 25 gives a damping
/// ratio of ~0.79 — underdamped, meaning one small overshoot and a quick
/// settle. That single overshoot is what makes selections and button releases
/// read as physical rather than as a tween.
class Springs {
  const Springs._();

  static const SpringDescription primary = SpringDescription(
    mass: 1.0,
    stiffness: 250.0,
    damping: 25.0,
  );

  /// Slightly heavier, for large surfaces (sheets, page-level morphs) where the
  /// specified spring alone reads as too eager.
  static const SpringDescription heavy = SpringDescription(
    mass: 1.4,
    stiffness: 250.0,
    damping: 28.0,
  );

  /// Tighter and near-critically damped, for the cart badge pop where an
  /// oscillation would look like a glitch rather than a bounce.
  static const SpringDescription pop = SpringDescription(
    mass: 0.7,
    stiffness: 320.0,
    damping: 22.0,
  );
}

/// Scale targets for the pizza when a size is selected. Specified exactly.
class SizeScale {
  const SizeScale._();
  static const double small = 0.94;
  static const double medium = 1.0;
  static const double large = 1.06;
}
