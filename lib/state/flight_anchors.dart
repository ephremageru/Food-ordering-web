import 'package:flutter/widgets.dart';

/// Lets a flight find the cart icon without every screen having to thread
/// coordinates down to the button that starts one.
///
/// The header cart button registers itself here on mount and clears itself on
/// dispose; [CartFlight] asks the registry where to fly, and calls [bump] when
/// the pizza lands so the icon reacts at the exact frame of arrival rather than
/// on a guessed delay.
class CartAnchor {
  CartAnchor._();

  static final CartAnchor instance = CartAnchor._();

  GlobalKey? key;
  VoidCallback? bump;

  void register(GlobalKey k, VoidCallback onBump) {
    key = k;
    bump = onBump;
  }

  void unregister(GlobalKey k) {
    if (identical(key, k)) {
      key = null;
      bump = null;
    }
  }

  /// Global rect of the cart icon, or null when no cart icon is on screen.
  Rect? get rect {
    final BuildContext? context = key?.currentContext;
    if (context == null) {
      return null;
    }
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
