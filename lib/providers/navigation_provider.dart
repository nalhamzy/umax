import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  onboarding,
  home,
  scan,
  result,
  history,
  routine,
  paywall,
  settings,
}

class _NavNotifier extends Notifier<AppScreen> {
  @override
  AppScreen build() => AppScreen.onboarding;
  void go(AppScreen s) => state = s;
}

final screenProvider =
    NotifierProvider<_NavNotifier, AppScreen>(_NavNotifier.new);
