import 'dart:convert';

import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umax/core/models/face_analysis.dart';
import 'package:umax/core/models/user_profile.dart';

import 'fake_images.dart';

/// Seeds SharedPreferences with a realistic profile and multi-day scan
/// history so every screen renders populated state for store screenshots.
Future<void> seedDemoState() async {
  final face1 = await writeDemoFaceImage(
    filename: 'demo_face_1.png',
    gradient: const [Color(0xFF7B61FF), Color(0xFFFF3D71)],
  );
  final face2 = await writeDemoFaceImage(
    filename: 'demo_face_2.png',
    gradient: const [Color(0xFF00E5D1), Color(0xFF7B61FF)],
  );
  final face3 = await writeDemoFaceImage(
    filename: 'demo_face_3.png',
    gradient: const [Color(0xFFFFD700), Color(0xFF00E5D1)],
  );

  const profile = UserProfile(
    onboarded: true,
    gender: Gender.male,
    age: 22,
    proTier: ProTier.none,
    scanTokens: 2,
    streakDays: 7,
    lastScanDate: '2026-04-17',
  );

  final now = DateTime(2026, 4, 17, 19, 12);
  final traits = <TraitScore>[
    const TraitScore(
        key: 'jawline',
        label: 'Jawline',
        score: 78,
        insight: 'Sharp jawline — big asset, protect it with low body fat.'),
    const TraitScore(
        key: 'symmetry',
        label: 'Facial Symmetry',
        score: 82,
        insight:
            'Strong symmetry — symmetrical faces read as attractive universally.'),
    const TraitScore(
        key: 'eyes',
        label: 'Eye Area',
        score: 74,
        insight: 'Hunter eyes / wide-open gaze reads as confident.'),
    const TraitScore(
        key: 'skin',
        label: 'Skin Quality',
        score: 65,
        insight:
            'Decent skin. Consistency > complexity. Hit SPF daily.'),
    const TraitScore(
        key: 'proportions',
        label: 'Facial Proportions',
        score: 76,
        insight: 'Balanced proportions, close to golden-ratio range.'),
    const TraitScore(
        key: 'thirds',
        label: 'Facial Thirds',
        score: 70,
        insight: 'Facial thirds aligned — a marker of classical beauty.'),
  ];
  final scans = <ScanRecord>[
    ScanRecord(
      id: '1713380000000',
      imagePath: face1,
      analysis: FaceAnalysis(
        overall: 78.4,
        potential: 88,
        faceShape: 'Diamond',
        tier: 'Above Average',
        traits: traits,
        strengths: ['Facial Symmetry (82)', 'Jawline (78)'],
        weaknesses: ['Skin Quality (65)', 'Facial Thirds (70)'],
        summary:
            'You scored 78 — Above Average. Your potential is 88, a +10 gap. Biggest lever: improve skin over the next 30 days.',
        timestamp: now,
      ),
    ),
    ScanRecord(
      id: '1712257000000',
      imagePath: face2,
      analysis: FaceAnalysis(
        overall: 74.1,
        potential: 86,
        faceShape: 'Diamond',
        tier: 'Above Average',
        traits: [
          for (final t in traits)
            TraitScore(
                key: t.key, label: t.label, score: t.score - 4, insight: t.insight),
        ],
        strengths: ['Facial Symmetry (78)', 'Jawline (74)'],
        weaknesses: ['Skin Quality (61)', 'Eye Area (70)'],
        summary:
            'You scored 74 — Above Average. Your potential is 86, a +12 gap. Biggest lever: improve skin over the next 30 days.',
        timestamp: now.subtract(const Duration(days: 12)),
      ),
    ),
    ScanRecord(
      id: '1710890000000',
      imagePath: face3,
      analysis: FaceAnalysis(
        overall: 69.0,
        potential: 83,
        faceShape: 'Diamond',
        tier: 'Average+',
        traits: [
          for (final t in traits)
            TraitScore(
                key: t.key, label: t.label, score: t.score - 9, insight: t.insight),
        ],
        strengths: ['Facial Symmetry (73)', 'Jawline (69)'],
        weaknesses: ['Skin Quality (56)', 'Eye Area (65)'],
        summary:
            'You scored 69 — Average+. Your potential is 83, a +14 gap. Biggest lever: improve skin over the next 30 days.',
        timestamp: now.subtract(const Duration(days: 28)),
      ),
    ),
  ];

  SharedPreferences.setMockInitialValues({
    'umax.profile.v1': jsonEncode(profile.toJson()),
    'umax.scans.v1': jsonEncode(scans.map((s) => s.toJson()).toList()),
  });
}
