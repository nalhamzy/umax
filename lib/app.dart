import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/theme.dart';
import 'providers/ad_provider.dart';
import 'providers/iap_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/result_screen.dart';
import 'screens/routine_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/ad_banner_widget.dart';
import 'core/services/iap_product_ids.dart';

class UmaxApp extends StatelessWidget {
  const UmaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMAX',
      debugShowCheckedModeBanner: false,
      theme: buildUmaxTheme(),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ad = ref.read(adServiceProvider);
      await ad.initialize();

      final iap = ref.read(iapServiceProvider);
      final profileNotifier = ref.read(profileProvider.notifier);
      iap.onPurchaseSuccess = (productId) {
        switch (productId) {
          case IapProductIds.proWeekly:
          case IapProductIds.proMonthly:
          case IapProductIds.proYearly:
            profileNotifier.activatePro(productId);
            break;
          case IapProductIds.lifetime:
            profileNotifier.activateLifetime();
            break;
        }
      };
      await iap.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = ref.watch(screenProvider);
    final profile = ref.watch(profileProvider);

    Widget body;
    switch (screen) {
      case AppScreen.onboarding:
        body = const OnboardingScreen();
        break;
      case AppScreen.home:
        body = const HomeScreen();
        break;
      case AppScreen.scan:
        body = const ScanScreen();
        break;
      case AppScreen.result:
        body = const ResultScreen();
        break;
      case AppScreen.history:
        body = const HistoryScreen();
        break;
      case AppScreen.routine:
        body = const RoutineScreen();
        break;
      case AppScreen.paywall:
        body = const PaywallScreen();
        break;
      case AppScreen.settings:
        body = const SettingsScreen();
        break;
    }

    final hideBanner = profile.isPro ||
        screen == AppScreen.onboarding ||
        screen == AppScreen.paywall ||
        screen == AppScreen.scan;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
      bottomNavigationBar: hideBanner ? null : const AdBannerWidget(),
    );
  }
}
