import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

Gender genderFromString(String? s) {
  switch (s) {
    case 'female': return Gender.female;
    case 'other':  return Gender.other;
    default:       return Gender.male;
  }
}

String genderToString(Gender g) => g.name;

enum ProTier { none, weekly, monthly, yearly, lifetime }

class UserProfile extends Equatable {
  final bool onboarded;
  final Gender gender;
  final int age;            // 14-99
  final ProTier proTier;
  final int scanTokens;     // free scans remaining this cycle
  final int streakDays;
  final String lastScanDate; // yyyy-MM-dd

  const UserProfile({
    this.onboarded = false,
    this.gender = Gender.male,
    this.age = 20,
    this.proTier = ProTier.none,
    this.scanTokens = 3,
    this.streakDays = 0,
    this.lastScanDate = '',
  });

  bool get isPro => proTier != ProTier.none;

  UserProfile copyWith({
    bool? onboarded,
    Gender? gender,
    int? age,
    ProTier? proTier,
    int? scanTokens,
    int? streakDays,
    String? lastScanDate,
  }) => UserProfile(
        onboarded: onboarded ?? this.onboarded,
        gender: gender ?? this.gender,
        age: age ?? this.age,
        proTier: proTier ?? this.proTier,
        scanTokens: scanTokens ?? this.scanTokens,
        streakDays: streakDays ?? this.streakDays,
        lastScanDate: lastScanDate ?? this.lastScanDate,
      );

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'gender': genderToString(gender),
        'age': age,
        'proTier': proTier.name,
        'scanTokens': scanTokens,
        'streakDays': streakDays,
        'lastScanDate': lastScanDate,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        onboarded: j['onboarded'] as bool? ?? false,
        gender: genderFromString(j['gender'] as String?),
        age: (j['age'] as num?)?.toInt() ?? 20,
        proTier: ProTier.values.firstWhere(
          (t) => t.name == j['proTier'],
          orElse: () => ProTier.none,
        ),
        scanTokens: (j['scanTokens'] as num?)?.toInt() ?? 3,
        streakDays: (j['streakDays'] as num?)?.toInt() ?? 0,
        lastScanDate: j['lastScanDate'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [onboarded, gender, age, proTier, scanTokens, streakDays, lastScanDate];
}
