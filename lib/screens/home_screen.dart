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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final scans = ref.watch(scanProvider).history;
    final latest = scans.isNotEmpty ? scans.first : null;

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: context.s(18), vertical: context.s(12)),
          children: [
            _TopBar(
              streakDays: profile.streakDays,
              isPro: profile.isPro,
              onSettings: () =>
                  ref.read(screenProvider.notifier).go(AppScreen.settings),
            ),
            const SizedBox(height: 18),
            if (latest == null) _EmptyHero(ref: ref, profile: profile)
            else _LatestScanCard(record: latest, profile: profile),
            const SizedBox(height: 16),
            _QuickActions(ref: ref, scanCount: scans.length),
            const SizedBox(height: 14),
            if (!profile.isPro) _ProPromo(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int streakDays;
  final bool isPro;
  final VoidCallback onSettings;
  const _TopBar({
    required this.streakDays,
    required this.isPro,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('UMAX', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 8),
        if (isPro)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: AppColors.gradientGold,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
          ),
        const Spacer(),
        if (streakDays > 0) ...[
          const Icon(Icons.local_fire_department_rounded,
              color: AppColors.warn, size: 20),
          const SizedBox(width: 2),
          Text('$streakDays',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.warn,
                  )),
          const SizedBox(width: 12),
        ],
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _EmptyHero extends StatelessWidget {
  final WidgetRef ref;
  final profile;
  const _EmptyHero({required this.ref, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.gradientMain,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(Icons.face_retouching_natural_rounded,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 18),
          Text('Ready for your first scan?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Snap a well-lit, neutral-expression selfie. UMAX will score your face across 6 traits in seconds.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Start Face Scan',
            icon: Icons.camera_alt_rounded,
            onPressed: () =>
                ref.read(screenProvider.notifier).go(AppScreen.scan),
          ),
          const SizedBox(height: 10),
          Text('You have ${profile.scanTokens} free scans',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _LatestScanCard extends ConsumerWidget {
  final record;
  final profile;
  const _LatestScanCard({required this.record, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = record.analysis;
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(record.imagePath),
                    width: 92, height: 92, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Analysis',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(a.tier,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.scoreColor(a.overall),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Face shape: ${a.faceShape}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ScoreRing(score: a.overall, size: 200, label: 'OVERALL', subLabel: 'potential ${a.potential.round()}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.result),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Full Report'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.routine),
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('My Routine'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final WidgetRef ref;
  final int scanCount;
  const _QuickActions({required this.ref, required this.scanCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.camera_alt_rounded,
            label: 'New Scan',
            subtitle: 'Re-analyze',
            onTap: () =>
                ref.read(screenProvider.notifier).go(AppScreen.scan),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.history_rounded,
            label: 'Progress',
            subtitle: '$scanCount scan${scanCount == 1 ? "" : "s"}',
            onTap: () =>
                ref.read(screenProvider.notifier).go(AppScreen.history),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProPromo extends StatelessWidget {
  final WidgetRef ref;
  const _ProPromo({required this.ref});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          ref.read(screenProvider.notifier).go(AppScreen.paywall),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.gradientGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.black, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Go UMAX Pro',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black)),
                  const SizedBox(height: 2),
                  const Text(
                      'Unlimited scans · Full glow-up plan · No ads · Priority analysis',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
