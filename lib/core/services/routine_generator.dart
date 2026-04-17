import '../models/face_analysis.dart';
import '../models/user_profile.dart';

class RoutineItem {
  final String title;
  final String detail;
  final String category;   // "skin", "grooming", "body", "habits"
  final int impact;        // 1-3 stars of expected impact
  const RoutineItem({
    required this.title,
    required this.detail,
    required this.category,
    required this.impact,
  });
}

class RoutineGenerator {
  List<RoutineItem> generate({
    required FaceAnalysis analysis,
    required UserProfile profile,
  }) {
    final out = <RoutineItem>[];
    final byKey = {for (final t in analysis.traits) t.key: t};

    // Skin — always ships with a baseline routine
    final skin = byKey['skin']?.score ?? 70;
    out.add(const RoutineItem(
      title: 'Morning: gentle cleanser + moisturizer + SPF 50',
      detail:
          'Skipping SPF is the #1 halo killer. 90 seconds every morning, non-negotiable.',
      category: 'skin',
      impact: 3,
    ));
    if (skin < 70) {
      out.add(const RoutineItem(
        title: 'Night: cleanser + niacinamide 10% serum',
        detail:
            'Niacinamide reduces pore size and improves skin tone in ~4 weeks. Pair with moisturizer.',
        category: 'skin',
        impact: 3,
      ));
      out.add(const RoutineItem(
        title: '2×/week exfoliate with BHA (salicylic 2%)',
        detail: 'Clears pores, reduces texture. Start slow to avoid irritation.',
        category: 'skin',
        impact: 2,
      ));
    }

    // Jawline
    final jaw = byKey['jawline']?.score ?? 70;
    if (jaw < 75) {
      out.add(const RoutineItem(
        title: 'Mewing: tongue to palate all day',
        detail:
            'Keep your tongue fully pressed on the roof of your mouth when not speaking. Compounds over months.',
        category: 'habits',
        impact: 2,
      ));
      out.add(const RoutineItem(
        title: 'Mastic gum daily (2 pieces, 20 min)',
        detail: 'Hardest chewing gum on earth. Trains masseter muscles for a wider jaw.',
        category: 'habits',
        impact: 2,
      ));
      out.add(const RoutineItem(
        title: 'Cut body fat to ≤15% (men) / ≤22% (women)',
        detail: 'Jawline is 50% muscle + 50% low body fat. Revealing the bone is the fastest ROI.',
        category: 'body',
        impact: 3,
      ));
    }

    // Eyes
    final eyes = byKey['eyes']?.score ?? 70;
    if (eyes < 75) {
      out.add(const RoutineItem(
        title: '7–9 h sleep, no phone 45 min before bed',
        detail: 'Chronic sleep debt = hooded, puffy eyes. This is free and 3-star impact.',
        category: 'habits',
        impact: 3,
      ));
      out.add(const RoutineItem(
        title: 'Morning: cold splash or ice roller',
        detail: '2 minutes de-puffs under-eyes and tightens skin briefly.',
        category: 'skin',
        impact: 1,
      ));
      out.add(const RoutineItem(
        title: 'Reduce sodium + drink 3 L water/day',
        detail: 'Sodium = eye puffiness. Water flushes it. Easy win.',
        category: 'habits',
        impact: 2,
      ));
    }

    // Proportions / thirds — grooming
    final prop = byKey['proportions']?.score ?? 70;
    final thirds = byKey['thirds']?.score ?? 70;
    if (prop < 70 || thirds < 70) {
      final isMale = profile.gender == Gender.male;
      out.add(RoutineItem(
        title: isMale
            ? 'Get a haircut that balances your face shape'
            : 'Ask stylist for a cut that frames your ${analysis.faceShape} face',
        detail:
            'Your face shape is ${analysis.faceShape}. A mid-fade + textured top (men) or curtain-frame layers (women) balances most shapes.',
        category: 'grooming',
        impact: 3,
      ));
      if (isMale) {
        out.add(const RoutineItem(
          title: 'Groom eyebrows: trim strays, keep natural arch',
          detail: 'Clean brows = +8 perceived score. 5 minutes with a small scissor.',
          category: 'grooming',
          impact: 2,
        ));
      } else {
        out.add(const RoutineItem(
          title: 'Brow shaping session (professional, once)',
          detail: 'A pro-shaped brow frames the eyes permanently with minimal upkeep.',
          category: 'grooming',
          impact: 3,
        ));
      }
    }

    // Universal
    out.add(const RoutineItem(
      title: 'Lift weights 3–4×/week, compound-lift focus',
      detail:
          'Face leanness + shoulder-to-waist ratio dominate perceived attractiveness. Squat, deadlift, bench, row.',
      category: 'body',
      impact: 3,
    ));
    out.add(const RoutineItem(
      title: 'Stand tall: shoulders back, chin forward + down',
      detail:
          'Posture adds ~5 perceived score instantly, no cost, no effort once habitual.',
      category: 'habits',
      impact: 2,
    ));

    return out;
  }
}
