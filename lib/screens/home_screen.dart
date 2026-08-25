import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../animations/cart_flight.dart';
import '../animations/motion_curves.dart';
import '../animations/page_transitions.dart';
import '../models/menu_data.dart';
import '../models/pizza.dart';
import '../state/cart_controller.dart';
import '../state/flight_anchors.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_button.dart';
import '../widgets/category_selector.dart';
import '../widgets/pizza_card.dart';
import '../widgets/pressable.dart';
import '../widgets/stagger.dart';
import 'cart_screen.dart';
import 'pizza_detail_screen.dart';

/// Home: greeting, search, the category arc, and the responsive pizza grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'all';

  /// One key per pizza, so a flight launched from a card knows precisely which
  /// rect on screen it is leaving.
  final Map<String, GlobalKey> _addKeys = <String, GlobalKey>{};

  GlobalKey _keyFor(String id) =>
      _addKeys.putIfAbsent(id, () => GlobalKey(debugLabel: 'add-$id'));

  /// Columns by width. The motion language is identical at every size — only
  /// the grid changes — so a hero flight behaves the same on a phone and on a
  /// desktop window.
  int _columns(double width) {
    if (width >= 1180) {
      return 4;
    }
    if (width >= 820) {
      return 3;
    }
    return 2;
  }

  void _openDetail(Pizza pizza) {
    Navigator.of(context).push(
      AppRoutes.morphRoute<void>(PizzaDetailScreen(pizza: pizza)),
    );
  }

  void _openCart() {
    Navigator.of(context).push(AppRoutes.pushRoute<void>(const CartScreen()));
  }

  /// Quick-add from the grid: the pizza flies from its card to the header cart
  /// icon, and the cart is only updated when it lands.
  Future<void> _quickAdd(Pizza pizza) async {
    final GlobalKey key = _keyFor(pizza.id);
    final BuildContext? cardContext = key.currentContext;
    final Rect? target = CartAnchor.instance.rect;

    // The departure rect is the pizza itself, not the "+" button — the object
    // that flies has to be the object you were looking at.
    Rect? from;
    final RenderBox? box = cardContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      // Walk up to the card and take its pizza disc rect.
      final Rect addRect = box.localToGlobal(Offset.zero) & box.size;
      final double disc = addRect.width * 3.2;
      from = Rect.fromCenter(
        center: Offset(addRect.center.dx - addRect.width * 1.4,
            addRect.center.dy - disc * 0.92),
        width: disc,
        height: disc,
      );
    }

    if (from == null || target == null) {
      CartScope.read(context).add(pizza, PizzaSize.medium, <String>{}, 1);
      return;
    }

    await CartFlight.launch(
      context: context,
      pizza: pizza,
      from: from,
      to: target,
      onArrive: () {
        if (!mounted) {
          return;
        }
        CartScope.read(context).add(pizza, PizzaSize.medium, <String>{}, 1);
        CartAnchor.instance.bump?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = _columns(width);
    final List<Pizza> pizzas = menuFor(_category);
    final double hPad = width >= 820 ? 32 : 20;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: StaggerGroup(
                  step: Motion.staggerTight,
                  children: <Widget>[
                    _Header(onCartTap: _openCart),
                    const SizedBox(height: 22),
                    const _Greeting(),
                    const SizedBox(height: 18),
                    const _SearchField(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 18, left: hPad / 2, right: hPad / 2),
                child: CategorySelector(
                  selectedId: _category,
                  onSelected: (String id) {
                    if (id != _category) {
                      setState(() => _category = id);
                    }
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 140),
              // AnimatedSwitcher on the whole grid, keyed by category: the old
              // set fades and lifts out while the new set fades in, instead of
              // the grid hard-cutting to different contents.
              sliver: SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: Motion.normal,
                  switchInCurve: Ease.out,
                  switchOutCurve: Ease.exit,
                  layoutBuilder: (Widget? current, List<Widget> previous) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[...previous, ?current],
                    );
                  },
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _Grid(
                    key: ValueKey<String>(_category),
                    pizzas: pizzas,
                    columns: columns,
                    keyFor: _keyFor,
                    onTap: _openDetail,
                    onAdd: _quickAdd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    super.key,
    required this.pizzas,
    required this.columns,
    required this.keyFor,
    required this.onTap,
    required this.onAdd,
  });

  final List<Pizza> pizzas;
  final int columns;
  final GlobalKey Function(String) keyFor;
  final void Function(Pizza) onTap;
  final void Function(Pizza) onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: pizzas.length,
      // The pizza overhangs the top of each card by ~42% of its diameter, so
      // the row gap has to clear that or the next row's pizza lands on the
      // previous row's price.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 74,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (BuildContext context, int i) {
        final Pizza p = pizzas[i];
        return PizzaCard(
          pizza: p,
          addKey: keyFor(p.id),
          onTap: () => onTap(p),
          onAdd: () => onAdd(p),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCartTap});

  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.panel,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.muted, size: 24),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Delivery to', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '11/2 Diriyah, Riyadh',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
              ],
            ),
          ],
        ),
        const Spacer(),
        Pressable(
          scale: 0.9,
          semanticLabel: 'Notifications',
          onTap: () {},
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: Shadows.card,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 21, color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 10),
        CartButton(onTap: onCartTap),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.displayLarge!;
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(text: 'Hungry? ', style: base),
          TextSpan(
            text: 'Order & Eat.',
            style: base.copyWith(color: AppColors.muted.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.chip),
        boxShadow: Shadows.card,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, size: 21, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search for Pizza',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
