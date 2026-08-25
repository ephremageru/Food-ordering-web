import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/cart_flight.dart';
import '../animations/hero_transitions.dart';
import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../models/pizza.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/price_text.dart';
import '../widgets/pressable.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/stagger.dart';
import 'cart_screen.dart';

/// The product detail screen.
///
/// Two animations matter most here. The hero lands the pizza from the home
/// grid into the slot on the right, and the add-to-cart sequence sends it back
/// out: the page blurs away, the pizza arcs into the bag icon on the button,
/// the button collapses to a circle, and only then does the cart open.
class PizzaDetailScreen extends StatefulWidget {
  const PizzaDetailScreen({super.key, required this.pizza});

  final Pizza pizza;

  @override
  State<PizzaDetailScreen> createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends State<PizzaDetailScreen>
    with SingleTickerProviderStateMixin {
  PizzaSize _size = PizzaSize.medium;
  final Set<String> _toppings = <String>{};
  int _quantity = 1;

  AddToCartPhase _phase = AddToCartPhase.idle;

  /// Drives the page dissolving behind the departing pizza.
  late final AnimationController _dispatch = AnimationController(
    vsync: this,
    duration: Motion.normal,
  );

  final GlobalKey _heroKey = GlobalKey(debugLabel: 'detail-hero');
  final GlobalKey _bagKey = GlobalKey(debugLabel: 'detail-bag');

  @override
  void dispose() {
    _dispatch.dispose();
    super.dispose();
  }

  double get _price => widget.pizza.priceFor(_size, _toppings) * _quantity;

  Rect? _rectOf(GlobalKey key) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _addToCart() async {
    if (_phase != AddToCartPhase.idle) {
      return;
    }

    final Rect? from = _rectOf(_heroKey);
    final Rect? to = _rectOf(_bagKey);
    final CartController cart = CartScope.read(context);

    if (from == null || to == null) {
      cart.add(widget.pizza, _size, _toppings, _quantity);
      if (mounted) {
        Navigator.of(context).push(AppRoutes.pushRoute<void>(const CartScreen()));
      }
      return;
    }

    setState(() => _phase = AddToCartPhase.flying);
    _dispatch.forward();

    await CartFlight.launch(
      context: context,
      pizza: widget.pizza,
      from: from,
      to: to,
      onArrive: () {
        if (!mounted) {
          return;
        }
        cart.add(widget.pizza, _size, _toppings, _quantity);
        setState(() => _phase = AddToCartPhase.landed);
      },
    );

    if (!mounted) {
      return;
    }
    // A short beat on the tick before leaving, so the confirmation is seen
    // rather than merely rendered.
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) {
      return;
    }
    await Navigator.of(context)
        .push(AppRoutes.pushRoute<void>(const CartScreen()));

    // Coming back from the cart, reset to idle so the screen is usable again.
    if (mounted) {
      setState(() => _phase = AddToCartPhase.idle);
      _dispatch.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cart = CartScope.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final bool wide = screen.width >= 820;
    final double hPad = wide ? 40 : 22;
    final double disc = (wide ? screen.width * 0.30 : screen.width * 0.62)
        .clamp(180.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: <Widget>[
          // Everything except the pizza and the button dissolves during the
          // flight. The pizza stays sharp because it is the thing moving, and
          // the button stays sharp because it is the destination.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _dispatch,
              builder: (BuildContext context, Widget? child) {
                final double t = Ease.standard.transform(_dispatch.value);
                if (t < 0.01) {
                  return child!;
                }
                return Opacity(
                  opacity: 1 - t * 0.85,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: t * 9,
                      sigmaY: t * 9,
                      tileMode: TileMode.decal,
                    ),
                    child: child,
                  ),
                );
              },
              child: _content(context, cart, hPad, disc, wide),
            ),
          ),

          // The pizza sits above the dissolving layer so it stays sharp.
          Positioned(
            right: wide ? screen.width * 0.10 : -disc * 0.16,
            top: MediaQuery.paddingOf(context).top + (wide ? 130 : 112),
            child: AnimatedScale(
              duration: Motion.medium,
              curve: Ease.spring,
              scale: _size.scale,
              child: AnimatedOpacity(
                // Hidden the moment the overlay copy takes over, so there is
                // never a duplicate pizza on screen mid-flight.
                duration: const Duration(milliseconds: 1),
                opacity: _phase == AddToCartPhase.idle ? 1 : 0,
                child: SizedBox(
                  key: _heroKey,
                  width: disc,
                  height: disc,
                  child: PizzaHero(pizza: widget.pizza, size: disc),
                ),
              ),
            ),
          ),

          _bottomBar(context, hPad),
        ],
      ),
    );
  }

  Widget _content(
    BuildContext context,
    CartController cart,
    double hPad,
    double disc,
    bool wide,
  ) {
    final TextTheme text = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 190),
        child: StaggerGroup(
          step: Motion.staggerTight,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _CircleIcon(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                _FavouriteButton(
                  active: cart.isFavourite(widget.pizza.id),
                  onTap: () => cart.toggleFavourite(widget.pizza.id),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Text column is held to the left half so it never runs under the
            // pizza, which overhangs the right edge.
            SizedBox(
              width: wide ? null : MediaQuery.sizeOf(context).width * 0.46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(widget.pizza.name, style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(widget.pizza.tagline, style: text.bodySmall),
                  const SizedBox(height: 10),
                  _Rating(rating: widget.pizza.rating),
                  const SizedBox(height: 14),
                  PriceText(value: _price, size: 30),
                  const SizedBox(height: 22),
                  _Spec(
                    label: 'Calories',
                    value: '${widget.pizza.calories} Cal',
                  ),
                  const SizedBox(height: 14),
                  _Spec(
                    label: 'Diameter / Portion',
                    value: '${_size.inches}" / ${_size.slices} Slices',
                  ),
                ],
              ),
            ),

            SizedBox(height: wide ? 34 : disc * 0.36),

            Text('Size', style: text.bodySmall),
            const SizedBox(height: 10),
            _SizeSelector(
              value: _size,
              onChanged: (PizzaSize s) => setState(() => _size = s),
            ),
            const SizedBox(height: 24),

            Text('Extra topping', style: text.bodySmall),
            const SizedBox(height: 10),
            _ToppingRow(
              selected: _toppings,
              onToggle: (String id) => setState(() {
                if (!_toppings.remove(id)) {
                  _toppings.add(id);
                }
              }),
            ),
            const SizedBox(height: 24),

            Text(widget.pizza.description, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, double hPad) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          hPad,
          14,
          hPad,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: <Widget>[
            AnimatedOpacity(
              duration: Motion.quick,
              opacity: _phase == AddToCartPhase.idle ? 1 : 0,
              child: QuantitySelector(
                value: _quantity,
                onChanged: (int q) => setState(() => _quantity = q),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AddToCartButton(
                phase: _phase,
                bagKey: _bagKey,
                onTap: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.value, required this.onChanged});

  final PizzaSize value;
  final ValueChanged<PizzaSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final PizzaSize s in PizzaSize.values) ...<Widget>[
          Expanded(
            child: Pressable(
              onTap: () => onChanged(s),
              scale: 0.94,
              semanticLabel: '${s.label} size',
              child: AnimatedContainer(
                duration: Motion.normal,
                curve: Ease.standard,
                height: 44,
                decoration: BoxDecoration(
                  color: s == value ? AppColors.orange : AppColors.background,
                  borderRadius: BorderRadius.circular(Radii.chip),
                  border: Border.all(
                    color: s == value ? AppColors.orange : AppColors.hairline,
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: Motion.normal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: s == value ? FontWeight.w700 : FontWeight.w500,
                      color: s == value ? Colors.white : AppColors.inkSoft,
                    ),
                    child: Text(s.label),
                  ),
                ),
              ),
            ),
          ),
          if (s != PizzaSize.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ToppingRow extends StatelessWidget {
  const _ToppingRow({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final Topping t in Topping.all)
          _ToppingChip(
            topping: t,
            selected: selected.contains(t.id),
            onTap: () => onToggle(t.id),
          ),
      ],
    );
  }
}

class _ToppingChip extends StatelessWidget {
  const _ToppingChip({
    required this.topping,
    required this.selected,
    required this.onTap,
  });

  final Topping topping;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.93,
      semanticLabel: '${topping.name}, ${selected ? "selected" : "not selected"}',
      child: AnimatedScale(
        duration: Motion.normal,
        curve: Ease.spring,
        scale: selected ? 1.04 : 1.0,
        child: AnimatedContainer(
          duration: Motion.normal,
          curve: Ease.standard,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.orangeSoft : AppColors.background,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(
              color: selected ? AppColors.orange : AppColors.hairline,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedSwitcher(
                duration: Motion.quick,
                switchInCurve: Ease.springPop,
                transitionBuilder: (Widget child, Animation<double> a) =>
                    ScaleTransition(scale: a, child: child),
                child: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        key: ValueKey<String>('on'),
                        size: 17,
                        color: AppColors.orange,
                      )
                    : const Icon(
                        Icons.add_circle_outline_rounded,
                        key: ValueKey<String>('off'),
                        size: 17,
                        color: AppColors.muted,
                      ),
              ),
              const SizedBox(width: 7),
              Text(
                topping.name,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.ink : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$rating out of 5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < 5; i++)
            Icon(
              i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 15,
              color: AppColors.star,
            ),
          const SizedBox(width: 6),
          Text('($rating)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        // Only the value swaps when the size changes — the label is stable, so
        // animating it too would draw the eye to the wrong thing.
        AnimatedSwitcher(
          duration: Motion.quick,
          switchInCurve: Ease.out,
          switchOutCurve: Ease.exit,
          transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          ),
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      semanticLabel: label,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hairline),
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  const _FavouriteButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.85,
      semanticLabel: active ? 'Remove from favourites' : 'Add to favourites',
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hairline),
        ),
        child: Center(
          // The heart pops on a spring when it turns on — the one place in the
          // app where a purely decorative flourish earns its keep, because
          // favouriting has no other feedback.
          child: AnimatedScale(
            duration: Motion.medium,
            curve: Ease.springPop,
            scale: active ? 1.18 : 1.0,
            child: AnimatedSwitcher(
              duration: Motion.quick,
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(scale: a, child: child),
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(active),
                size: 20,
                color: active ? AppColors.orange : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
