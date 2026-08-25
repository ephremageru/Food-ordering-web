import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../art/pizza_painter.dart';
import '../models/cart_item.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_number.dart';
import '../widgets/pressable.dart';
import '../widgets/quantity_selector.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cart = CartScope.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final double hPad = width >= 820 ? 40 : 20;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TitleBar(
              title: 'My Cart',
              subtitle: cart.isEmpty
                  ? 'Nothing here yet'
                  : '${cart.count} item${cart.count == 1 ? "" : "s"} from your menu',
            ),
            Expanded(
              child: cart.isEmpty
                  ? const _EmptyCart()
                  : ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 24),
                      children: <Widget>[
                        for (final CartItem item in cart.items)
                          _CartRow(key: ValueKey<String>(item.key), item: item),
                      ],
                    ),
            ),
            if (!cart.isEmpty) _Summary(cart: cart, hPad: hPad),
          ],
        ),
      ),
    );
  }
}

/// A cart line that animates itself out before it is removed from the model.
///
/// Removal is a four-part motion, and all four are needed: the row fades, it
/// scales down slightly, its height collapses, and the rows beneath slide up to
/// close the gap. Dropping the height collapse is what makes most "animated"
/// list removals still feel like a jump — the row disappears smoothly but the
/// list below it teleports.
class _CartRow extends StatefulWidget {
  const _CartRow({super.key, required this.item});

  final CartItem item;

  @override
  State<_CartRow> createState() => _CartRowState();
}

class _CartRowState extends State<_CartRow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.normal,
    value: 1.0,
  );

  bool _removing = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    if (_removing) {
      return;
    }
    setState(() => _removing = true);
    final CartController cart = CartScope.read(context);
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      cart.remove(widget.item);
      return;
    }
    await _c.animateTo(0.0, duration: Motion.normal, curve: Ease.exit);
    if (mounted) {
      cart.remove(widget.item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartItem item = widget.item;
    final CartController cart = CartScope.read(context);

    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: _c.value,
          child: Opacity(
            opacity: _c.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.9 + 0.1 * _c.value,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: AppColors.hairline),
            boxShadow: Shadows.card,
          ),
          child: Row(
            children: <Widget>[
              // Deliberately not a Hero: the detail screen's pizza may still be
              // mounted behind this route, and two live heroes sharing a tag is
              // the classic cause of a flight that flickers or lands nowhere.
              PizzaDisc(pizza: item.pizza, size: 60, slices: item.size.slices),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.pizza.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.size.label} · ${item.pizza.tagline}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        AnimatedNumber(
                          value: item.lineTotal,
                          prefix: '\$',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        Pressable(
                          onTap: _remove,
                          scale: 0.85,
                          semanticLabel: 'Remove ${item.pizza.name}',
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              QuantitySelector(
                value: item.quantity,
                vertical: true,
                compact: true,
                onChanged: (int q) {
                  if (q > item.quantity) {
                    cart.increment(item);
                  } else {
                    cart.decrement(item);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.hPad});

  final CartController cart;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _SummaryRow(label: 'Subtotal', value: cart.subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery', value: cart.delivery),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Total', value: cart.total, emphasis: true),
          const SizedBox(height: 16),
          _PrimaryButton(
            label: 'Checkout',
            onTap: () => Navigator.of(context)
                .push(AppRoutes.pushRoute<void>(const CheckoutScreen())),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final double value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: emphasis
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        AnimatedNumber(
          value: value,
          prefix: '\$',
          style: TextStyle(
            fontSize: emphasis ? 20 : 14,
            fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
            color: emphasis ? AppColors.ink : AppColors.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.muted),
          const SizedBox(height: 14),
          Text('Your cart is empty', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Add a pizza and it will fly in here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Row(
        children: <Widget>[
          Pressable(
            onTap: () => Navigator.of(context).maybePop(),
            scale: 0.85,
            semanticLabel: 'Back',
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back_rounded, size: 21, color: AppColors.ink),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      semanticLabel: label,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(Radii.chip),
          boxShadow: Shadows.lifted,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared by the cart and checkout screens.
class SharedTitleBar extends StatelessWidget {
  const SharedTitleBar({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Row(
        children: <Widget>[
          Pressable(
            onTap: () => Navigator.of(context).maybePop(),
            scale: 0.85,
            semanticLabel: 'Back',
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back_rounded, size: 21, color: AppColors.ink),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}

/// Reused by checkout for its pay button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _PrimaryButton(label: label, onTap: onTap);
}
