import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_number.dart';
import '../widgets/pressable.dart';
import '../widgets/stagger.dart';
import 'cart_screen.dart';
import 'success_screen.dart';

enum PayMethod { card, paypal, applePay }

enum PayState { idle, processing }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PayMethod _method = PayMethod.card;
  PayState _state = PayState.idle;

  /// Totals frozen at the moment payment starts.
  ///
  /// Placing the order empties the cart, but this screen is still on screen and
  /// animating out while that happens — without a snapshot every figure rolls
  /// down toward zero in front of the user, which reads as the order being
  /// cancelled at the exact moment it succeeded.
  _Totals? _frozen;

  Future<void> _pay() async {
    if (_state == PayState.processing) {
      return;
    }
    setState(() {
      _state = PayState.processing;
      _frozen = _Totals.of(CartScope.read(context));
    });
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) {
      return;
    }
    final PlacedOrder order = CartScope.read(context).placeOrder();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushAndRemoveUntil(
      AppRoutes.revealRoute<void>(SuccessScreen(order: order)),
      (Route<dynamic> r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _Totals totals = _frozen ?? _Totals.of(CartScope.of(context));
    final double width = MediaQuery.sizeOf(context).width;
    final double hPad = width >= 820 ? 40 : 20;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SharedTitleBar(
              title: 'Checkout',
              subtitle: 'Confirm and pay',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 24),
                child: StaggerGroup(
                  step: Motion.staggerNormal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _SectionLabel('Payment method'),
                    const SizedBox(height: 10),
                    for (final PayMethod m in PayMethod.values) ...<Widget>[
                      _PaymentTile(
                        method: m,
                        selected: _method == m,
                        onTap: () => setState(() => _method = m),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const _AddPaymentMethod(),
                    const SizedBox(height: 26),
                    _SectionLabel('Delivery address'),
                    const SizedBox(height: 10),
                    const _AddressTile(),
                    const SizedBox(height: 26),
                    _SectionLabel('Order summary'),
                    const SizedBox(height: 10),
                    _SummaryCard(totals: totals),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 18),
              child: _PayButton(
                state: _state,
                total: totals.total,
                onTap: _pay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pay button.
///
/// Its size is pinned across both states. A button that resizes when it starts
/// working shifts everything around it at the exact moment the user is watching
/// for confirmation, which reads as an error even when nothing is wrong.
class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.state,
    required this.total,
    required this.onTap,
  });

  final PayState state;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool busy = state == PayState.processing;
    return Pressable(
      onTap: busy ? null : onTap,
      scale: 0.97,
      semanticLabel: busy ? 'Processing payment' : 'Pay now',
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: busy ? AppColors.inkSoft : AppColors.navBar,
          borderRadius: BorderRadius.circular(Radii.chip),
          boxShadow: Shadows.lifted,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: Motion.quick,
            switchInCurve: Ease.out,
            switchOutCurve: Ease.exit,
            child: busy
                ? Row(
                    key: const ValueKey<String>('busy'),
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey<String>('idle'),
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedNumber(
                        value: total,
                        prefix: '\$',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  ({IconData icon, String name, String detail, Color tint}) get _spec =>
      switch (method) {
        PayMethod.card => (
            icon: Icons.credit_card_rounded,
            name: 'Master Card',
            detail: '•••• •••• •••• 5421',
            tint: const Color(0xFFEB5B2D),
          ),
        PayMethod.paypal => (
            icon: Icons.account_balance_wallet_outlined,
            name: 'Paypal',
            detail: 'you@example.com',
            tint: const Color(0xFF2B6CB0),
          ),
        PayMethod.applePay => (
            icon: Icons.apple_rounded,
            name: 'Apple Pay',
            detail: 'Touch to confirm',
            tint: AppColors.ink,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final ({Color tint, String detail, IconData icon, String name}) s = _spec;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      semanticLabel: '${s.name}${selected ? ", selected" : ""}',
      child: AnimatedContainer(
        duration: Motion.normal,
        curve: Ease.standard,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeSoft.withValues(alpha: 0.45) : AppColors.background,
          borderRadius: BorderRadius.circular(Radii.field),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.hairline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(s.icon, size: 22, color: s.tint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(s.name, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(s.detail, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            // The radio scales in rather than appearing, so the eye is drawn to
            // where the selection went.
            AnimatedSwitcher(
              duration: Motion.quick,
              switchInCurve: Ease.springPop,
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(scale: a, child: child),
              child: selected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey<String>('on'),
                      size: 22,
                      color: AppColors.orange,
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      key: ValueKey<String>('off'),
                      size: 22,
                      color: AppColors.muted,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentMethod extends StatelessWidget {
  const _AddPaymentMethod();

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {},
      scale: 0.98,
      semanticLabel: 'Add payment method',
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.field),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_rounded, size: 18, color: AppColors.inkSoft),
            const SizedBox(width: 8),
            Text('Add Payment Method',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(Radii.field),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.location_on_outlined, size: 21, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('11/2 Diriyah, Road no A3',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text('Riyadh, KSA',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

/// An immutable snapshot of the order figures.
class _Totals {
  const _Totals({
    required this.subtotal,
    required this.promo,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  factory _Totals.of(CartController cart) => _Totals(
        subtotal: cart.subtotal,
        promo: cart.promo,
        delivery: cart.delivery,
        tax: cart.tax,
        total: cart.total,
      );

  final double subtotal;
  final double promo;
  final double delivery;
  final double tax;
  final double total;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totals});

  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(Radii.field),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: <Widget>[
          _Line(label: 'Order Amount', value: totals.subtotal),
          _Line(label: 'Promo code', value: -totals.promo, accent: true),
          _Line(label: 'Delivery', value: totals.delivery),
          _Line(label: 'Tax', value: totals.tax),
          const SizedBox(height: 8),
          Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Total Amount',
                  style: Theme.of(context).textTheme.titleMedium),
              AnimatedNumber(
                value: totals.total,
                prefix: '\$',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.accent = false});

  final String label;
  final double value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          AnimatedNumber(
            // The sign lives in the prefix; feeding a negative number through
            // as well would render it twice.
            value: value.abs(),
            prefix: value < 0 ? '-\$' : '\$',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accent ? AppColors.orange : AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
