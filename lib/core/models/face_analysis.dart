import 'package:equatable/equatable.dart';

class TraitScore extends Equatable {
  final String key;          // "jawline", "symmetry", "eyes", "skin", etc.
  final String label;
  final double score;        // 0-100
  final String insight;      // one-line explanation
  const TraitScore({
    required this.key,
    required this.label,
    required this.score,
    required this.insight,
  });

  Map<String, dynamic> toJson() =>
      {'key': key, 'label': label, 'score': score, 'insight': insight};
  factory TraitScore.fromJson(Map<String, dynamic> j) => TraitScore(
        key: j['key'] as String,
        label: j['label'] as String,
        score: (j['score'] as num).toDouble(),
        insight: j['insight'] as String? ?? '',
      );

  @override
  List<Object?> get props => [key, label, score, insight];
}

class FaceAnalysis extends Equatable {
  final double overall;               // 0-100
  final double potential;             // 0-100, what you could hit
  final String faceShape;
  final String tier;                  // "Below Average", "Average", "Above Avg", "Chad/Queen", "Godlike"
  final List<TraitScore> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final String summary;
  final DateTime timestamp;

  const FaceAnalysis({
    required this.overall,
    required this.potential,
    required this.faceShape,
    required this.tier,
    required this.traits,
    required this.strengths,
    required this.weaknesses,
    required this.summary,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'potential': potential,
        'faceShape': faceShape,
        'tier': tier,
        'traits': traits.map((t) => t.toJson()).toList(),
        'strengths': strengths,
        'weaknesses': weaknesses,
        'summary': summary,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FaceAnalysis.fromJson(Map<String, dynamic> j) => FaceAnalysis(
        overall: (j['overall'] as num).toDouble(),
        potential: (j['potential'] as num).toDouble(),
        faceShape: j['faceShape'] as String? ?? 'Oval',
        tier: j['tier'] as String? ?? 'Average',
        traits: (j['traits'] as List<dynamic>? ?? [])
            .map((e) => TraitScore.fromJson(e as Map<String, dynamic>))
            .toList(),
        strengths: (j['strengths'] as List<dynamic>? ?? []).cast<String>(),
        weaknesses: (j['weaknesses'] as List<dynamic>? ?? []).cast<String>(),
        summary: j['summary'] as String? ?? '',
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  List<Object?> get props =>
      [overall, potential, faceShape, tier, traits, strengths, weaknesses, summary, timestamp];
}

class ScanRecord extends Equatable {
  final String id;
  final String imagePath;    // local file path
  final FaceAnalysis analysis;

  const ScanRecord({
    required this.id,
    required this.imagePath,
    required this.analysis,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'imagePath': imagePath, 'analysis': analysis.toJson()};
  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
        id: j['id'] as String,
        imagePath: j['imagePath'] as String,
        analysis: FaceAnalysis.fromJson(j['analysis'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [id, imagePath, analysis];
}
