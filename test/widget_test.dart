import 'package:flutter_test/flutter_test.dart';
import 'package:umax/core/models/user_profile.dart';

void main() {
  test('UserProfile round-trips JSON', () {
    const p = UserProfile(
      onboarded: true,
      gender: Gender.female,
      age: 22,
      proTier: ProTier.yearly,
      scanTokens: 2,
      streakDays: 5,
      lastScanDate: '2026-04-17',
    );
    final restored = UserProfile.fromJson(p.toJson());
    expect(restored, equals(p));
    expect(restored.isPro, isTrue);
  });
}
