import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/face_analysis.dart';
import '../models/user_profile.dart';

class StorageService {
  static const _kProfile = 'umax.profile.v1';
  static const _kScans = 'umax.scans.v1';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  UserProfile loadProfile() {
    final raw = _prefs.getString(_kProfile);
    if (raw == null || raw.isEmpty) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile p) =>
      _prefs.setString(_kProfile, jsonEncode(p.toJson()));

  List<ScanRecord> loadScans() {
    final raw = _prefs.getString(_kScans);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScanRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveScans(List<ScanRecord> scans) => _prefs.setString(
      _kScans, jsonEncode(scans.map((s) => s.toJson()).toList()));
}
