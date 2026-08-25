import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../art/pizza_painter.dart';
import '../models/cart_item.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/stagger.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.embedded = false});

  /// True when shown inside the tab shell, which supplies its own chrome.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final CartController cart = CartScope.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final double hPad = width >= 820 ? 40 : 20;

    final Widget body = cart.orders.isEmpty
        ? const _NoOrders()
        : ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, embedded ? 130 : 24),
            children: <Widget>[
              for (final PlacedOrder o in cart.orders) _OrderCard(order: o),
            ],
          );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 6),
              child: Row(
                children: <Widget>[
                  if (!embedded)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.ink,
                    ),
                  Expanded(
                    child: Text(
                      'My Orders',
                      textAlign: embedded ? TextAlign.left : TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (!embedded) const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: StaggerGroup(
        step: Motion.staggerTight,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: AppColors.hairline),
              boxShadow: Shadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Order ${order.reference}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.orangeSoft,
                        borderRadius: BorderRadius.circular(Radii.chip),
                      ),
                      child: const Text(
                        'Preparing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final CartItem item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: <Widget>[
                        PizzaDisc(
                          pizza: item.pizza,
                          size: 44,
                          slices: item.size.slices,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                item.pizza.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${item.quantity} × ${item.size.label}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${item.lineTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                Divider(height: 20, color: AppColors.hairline),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Total',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.receipt_long_outlined,
              size: 44, color: AppColors.muted),
          const SizedBox(height: 14),
          Text('No orders yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Your next pizza will show up here.',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
