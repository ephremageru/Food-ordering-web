import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/onboarding_screen.dart';
import 'state/cart_controller.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const PizzafyApp());
}

class PizzafyApp extends StatefulWidget {
  const PizzafyApp({super.key});

  @override
  State<PizzafyApp> createState() => _PizzafyAppState();
}

class _PizzafyAppState extends State<PizzafyApp> {
  final CartController _cart = CartController();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      controller: _cart,
      child: MaterialApp(
        title: 'Pizzafy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const OnboardingScreen(),
        builder: (BuildContext context, Widget? child) {
          // The app is designed for a handheld surface. On a wide window it
          // runs inside a phone-shaped frame rather than stretching, because
          // the whole motion system — arcs, flights, a thumb-reachable nav —
          // is calibrated to that aspect ratio.
          return _DeviceFrame(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  static const double _breakpoint = 760;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.width < _breakpoint) {
      return child;
    }

    final double h = (size.height * 0.92).clamp(560.0, 900.0);
    final double w = h * 0.475;

    return ColoredBox(
      color: const Color(0xFF201D1A),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(42),
          child: SizedBox(
            width: w,
            height: h,
            child: MediaQuery(
              // The frame is a viewport, so the inner app must be told its real
              // size and that it has no system insets of its own.
              data: MediaQuery.of(context).copyWith(
                size: Size(w, h),
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
