import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/models/face_analysis.dart';
import '../core/services/face_analyzer.dart';
import 'profile_provider.dart';
import 'storage_provider.dart';

class ScanState {
  final List<ScanRecord> history;
  final ScanRecord? current;
  final bool analyzing;
  final String? error;

  const ScanState({
    this.history = const [],
    this.current,
    this.analyzing = false,
    this.error,
  });

  ScanState copyWith({
    List<ScanRecord>? history,
    ScanRecord? current,
    bool? analyzing,
    String? error,
    bool clearError = false,
    bool clearCurrent = false,
  }) =>
      ScanState(
        history: history ?? this.history,
        current: clearCurrent ? null : (current ?? this.current),
        analyzing: analyzing ?? this.analyzing,
        error: clearError ? null : (error ?? this.error),
      );
}

class ScanNotifier extends Notifier<ScanState> {
  late final FaceAnalyzer _analyzer;

  @override
  ScanState build() {
    _analyzer = FaceAnalyzer();
    ref.onDispose(() => _analyzer.dispose());
    final storage = ref.read(storageServiceProvider);
    return ScanState(history: storage.loadScans());
  }

  void _persist() {
    ref.read(storageServiceProvider).saveScans(state.history);
  }

  Future<void> runScan(File pickedImage) async {
    state = state.copyWith(analyzing: true, clearError: true);
    try {
      final profile = ref.read(profileProvider);
      final analysis = await _analyzer.analyze(
        imageFile: pickedImage,
        profile: profile,
      );
      if (analysis == null) {
        state = state.copyWith(
          analyzing: false,
          error:
              'No face detected. Make sure your face is well-lit, centered, and looking at the camera.',
        );
        return;
      }

      // Copy image into app documents so its lifetime is controlled by us.
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(dir.path, 'scans'));
      if (!await scansDir.exists()) await scansDir.create(recursive: true);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final targetPath = p.join(scansDir.path, 'scan_$id.jpg');
      await pickedImage.copy(targetPath);

      final record = ScanRecord(
        id: id,
        imagePath: targetPath,
        analysis: analysis,
      );

      final history = [record, ...state.history].take(100).toList();
      state = state.copyWith(
        history: history,
        current: record,
        analyzing: false,
      );
      _persist();

      await ref.read(profileProvider.notifier).consumeScanToken();
      await ref.read(profileProvider.notifier).recordScanForStreak();
    } catch (e) {
      state = state.copyWith(
          analyzing: false, error: 'Analysis failed: $e');
    }
  }

  void selectHistoric(ScanRecord r) {
    state = state.copyWith(current: r);
  }

  Future<void> deleteRecord(String id) async {
    final r = state.history.where((x) => x.id == id).toList();
    final history = state.history.where((x) => x.id != id).toList();
    state = state.copyWith(history: history);
    _persist();
    for (final x in r) {
      try {
        final f = File(x.imagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);
