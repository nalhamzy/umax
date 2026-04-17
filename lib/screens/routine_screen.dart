import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/services/routine_generator.dart';
import '../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(scanProvider).current;
    final profile = ref.watch(profileProvider);

    if (record == null) {
      return const Center(child: Text('Run a scan first.'));
    }

    final items = RoutineGenerator()
        .generate(analysis: record.analysis, profile: profile);
    final locked = !profile.isPro;
    final visible = locked ? items.take(4).toList() : items;

    final grouped = <String, List<RoutineItem>>{};
    for (final it in visible) {
      grouped.putIfAbsent(it.category, () => []).add(it);
    }

    return SafeArea(
      child: ResponsiveContentBox(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.bg,
              leading: IconButton(
                onPressed: () => ref
                    .read(screenProvider.notifier)
                    .go(AppScreen.home),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Your Routine'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.s(16), vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('30-Day Glow-Up Plan',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Small habits, stacked. These target your weakest traits first for the fastest ROI.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          _categoryLabel(entry.key).toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.accent,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      for (final item in entry.value) _RoutineTile(item: item),
                      const SizedBox(height: 12),
                    ],
                    if (locked) _LockedBanner(ref: ref, hidden: items.length - visible.length),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String k) => switch (k) {
        'skin' => 'Skincare',
        'grooming' => 'Grooming',
        'body' => 'Body & Training',
        'habits' => 'Daily Habits',
        _ => k,
      };
}

class _RoutineTile extends StatelessWidget {
  final RoutineItem item;
  const _RoutineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = switch (item.category) {
      'skin' => AppColors.accent2,
      'grooming' => AppColors.accent,
      'body' => AppColors.accent3,
      _ => AppColors.warn,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SectionCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < item.impact ? Icons.bolt_rounded : Icons.bolt_outlined,
                      size: 16,
                      color: i < item.impact ? color : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.detail,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  final WidgetRef ref;
  final int hidden;
  const _LockedBanner({required this.ref, required this.hidden});
  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: '+$hidden more actions — Unlock with Pro',
      icon: Icons.lock_open_rounded,
      gradient: AppColors.gradientGold,
      onPressed: () =>
          ref.read(screenProvider.notifier).go(AppScreen.paywall),
    );
  }
}
