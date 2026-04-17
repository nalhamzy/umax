import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0B0B14);
  static const bgElevated = Color(0xFF14141F);
  static const card = Color(0xFF1C1C2B);
  static const border = Color(0xFF262638);
  static const textPrimary = Color(0xFFF2F2F7);
  static const textSecondary = Color(0xFF9B9BB3);
  static const textMuted = Color(0xFF5C5C75);

  // Accents
  static const accent = Color(0xFF7B61FF);      // electric purple
  static const accent2 = Color(0xFF00E5D1);     // cyan
  static const accent3 = Color(0xFFFF3D71);     // coral
  static const gold = Color(0xFFFFC75F);        // premium
  static const success = Color(0xFF00D17A);
  static const warn = Color(0xFFFFB547);
  static const danger = Color(0xFFFF3B30);

  static const gradientMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B61FF), Color(0xFFFF3D71)],
  );
  static const gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC75F), Color(0xFFFF8A3D)],
  );

  static Color scoreColor(double score) {
    // score is 0-100
    if (score >= 85) return const Color(0xFFFFD700);
    if (score >= 70) return success;
    if (score >= 55) return accent2;
    if (score >= 40) return warn;
    return accent3;
  }
}
