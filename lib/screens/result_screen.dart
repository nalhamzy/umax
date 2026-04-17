import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/score_ring.dart';
import '../widgets/section_card.dart';
import '../widgets/trait_bar.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scanProvider);
    final record = s.current;
    final profile = ref.watch(profileProvider);

    if (record == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('No scan selected.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(screenProvider.notifier).go(AppScreen.home),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final a = record.analysis;
    final locked = !profile.isPro;

    return SafeArea(
      child: ResponsiveContentBox(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.bg,
              leading: IconButton(
                onPressed: () =>
                    ref.read(screenProvider.notifier).go(AppScreen.home),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Analysis'),
              actions: [
                IconButton(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.routine),
                  icon: const Icon(Icons.checklist_rounded),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.s(16), vertical: 4),
                child: Column(
                  children: [
                    _Hero(record: record),
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _Stat(
                                  label: 'Tier',
                                  value: a.tier,
                                  color: AppColors.scoreColor(a.overall),
                                ),
                              ),
                              Expanded(
                                child: _Stat(
                                  label: 'Face shape',
                                  value: a.faceShape,
                                  color: AppColors.accent2,
                                ),
                              ),
                              Expanded(
                                child: _Stat(
                                  label: 'Potential',
                                  value: '${a.potential.round()}',
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(a.summary,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trait Breakdown',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 14),
                          for (int i = 0; i < a.traits.length; i++) ...[
                            Opacity(
                              opacity: (locked && i >= 3) ? 0.35 : 1.0,
                              child: TraitBar(trait: a.traits[i]),
                            ),
                            if (i != a.traits.length - 1)
                              const SizedBox(height: 16),
                          ],
                          if (locked) ...[
                            const SizedBox(height: 12),
                            _UnlockMore(ref: ref),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Strengths',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          for (final s in a.strengths)
                            _bullet(context, AppColors.success, s),
                          const SizedBox(height: 14),
                          Text('Biggest Levers',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          for (final s in a.weaknesses)
                            _bullet(context, AppColors.accent3, s),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GradientButton(
                      label: 'Show My 30-Day Routine',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: () => ref
                          .read(screenProvider.notifier)
                          .go(AppScreen.routine),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(BuildContext ctx, Color color, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6, height: 6,
              margin: const EdgeInsets.only(top: 8, right: 10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3)),
            ),
            Expanded(
                child: Text(text,
                    style: Theme.of(ctx).textTheme.bodyLarge)),
          ],
        ),
      );
}

class _Hero extends StatelessWidget {
  final record;
  const _Hero({required this.record});

  @override
  Widget build(BuildContext context) {
    final a = record.analysis;
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(File(record.imagePath), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          ScoreRing(score: a.overall, size: 200, label: 'OVERALL', subLabel: a.tier),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _UnlockMore extends StatelessWidget {
  final WidgetRef ref;
  const _UnlockMore({required this.ref});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ref.read(screenProvider.notifier).go(AppScreen.paywall),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Unlock full trait breakdown with UMAX Pro',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gold, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
