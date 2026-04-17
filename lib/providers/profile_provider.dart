import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models/user_profile.dart';
import '../core/services/iap_product_ids.dart';
import 'storage_provider.dart';
import 'ad_provider.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final storage = ref.read(storageServiceProvider);
    final p = storage.loadProfile();
    // Keep banner visibility in sync with pro tier
    Future.microtask(() {
      ref.read(adServiceProvider).setAdsRemoved(p.isPro);
    });
    return p;
  }

  void _persist() {
    ref.read(storageServiceProvider).saveProfile(state);
  }

  Future<void> completeOnboarding({
    required Gender gender,
    required int age,
  }) async {
    state = state.copyWith(onboarded: true, gender: gender, age: age);
    _persist();
  }

  Future<void> activatePro(String productId) async {
    final tier = switch (productId) {
      IapProductIds.proWeekly => ProTier.weekly,
      IapProductIds.proMonthly => ProTier.monthly,
      IapProductIds.proYearly => ProTier.yearly,
      _ => ProTier.monthly,
    };
    state = state.copyWith(proTier: tier);
    ref.read(adServiceProvider).setAdsRemoved(true);
    _persist();
  }

  Future<void> activateLifetime() async {
    state = state.copyWith(proTier: ProTier.lifetime);
    ref.read(adServiceProvider).setAdsRemoved(true);
    _persist();
  }

  Future<void> consumeScanToken() async {
    if (state.isPro) return;
    if (state.scanTokens <= 0) return;
    state = state.copyWith(scanTokens: state.scanTokens - 1);
    _persist();
  }

  Future<void> grantBonusScan() async {
    state = state.copyWith(scanTokens: state.scanTokens + 1);
    _persist();
  }

  Future<void> recordScanForStreak() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (state.lastScanDate == today) return;

    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    final newStreak = state.lastScanDate == yesterday ? state.streakDays + 1 : 1;
    state = state.copyWith(lastScanDate: today, streakDays: newStreak);
    _persist();
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);
