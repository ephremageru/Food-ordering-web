import 'package:flutter/material.dart';

import '../animations/animation_constants.dart';
import '../art/pizza_painter.dart';
import '../models/menu_data.dart';
import '../models/pizza.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/stagger.dart';

/// Search, favourites and profile.
///
/// These are intentionally light. Building them out further would not exercise
/// any motion the app does not already demonstrate, and every screen added here
/// is one more surface to keep consistent.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Pizza> results = kMenu
        .where((Pizza p) =>
            _query.isEmpty ||
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.tagline.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return _TabScaffold(
      title: 'Search',
      child: Column(
        children: <Widget>[
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.chip),
              boxShadow: Shadows.card,
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    autofocus: false,
                    onChanged: (String v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Search the menu',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 130),
              children: <Widget>[
                for (final Pizza p in results) _MenuRow(pizza: p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cart = CartScope.of(context);
    final List<Pizza> favourites =
        kMenu.where((Pizza p) => cart.isFavourite(p.id)).toList();

    return _TabScaffold(
      title: 'Favourites',
      child: favourites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.favorite_border_rounded,
                      size: 44, color: AppColors.muted),
                  const SizedBox(height: 14),
                  Text('Nothing saved yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('Tap the heart on any pizza.',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 130),
              children: <Widget>[
                for (final Pizza p in favourites) _MenuRow(pizza: p),
              ],
            ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Profile',
      child: StaggerGroup(
        step: Motion.staggerNormal,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: AppColors.panel,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    size: 32, color: AppColors.muted),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Guest', style: Theme.of(context).textTheme.titleLarge),
                  Text('11/2 Diriyah, Riyadh',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 26),
          for (final ({IconData icon, String label}) row
              in const <({IconData icon, String label})>[
            (icon: Icons.location_on_outlined, label: 'Delivery addresses'),
            (icon: Icons.credit_card_rounded, label: 'Payment methods'),
            (icon: Icons.notifications_none_rounded, label: 'Notifications'),
            (icon: Icons.help_outline_rounded, label: 'Help & support'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.field),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(row.icon, size: 20, color: AppColors.inkSoft),
                    const SizedBox(width: 12),
                    Text(row.label,
                        style: Theme.of(context).textTheme.labelLarge),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.pizza});

  final Pizza pizza;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          PizzaDisc(pizza: pizza, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(pizza.name,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(pizza.tagline,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '\$${pizza.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double hPad = width >= 820 ? 40 : 20;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 18),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
