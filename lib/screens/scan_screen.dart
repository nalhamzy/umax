import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../providers/ad_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _picker = ImagePicker();
  File? _picked;

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 92,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (x != null) {
      setState(() => _picked = File(x.path));
    }
  }

  Future<void> _analyze() async {
    if (_picked == null) return;
    final profile = ref.read(profileProvider);

    if (!profile.isPro && profile.scanTokens <= 0) {
      // Offer rewarded ad or paywall
      await _noTokensSheet();
      return;
    }

    await ref.read(scanProvider.notifier).runScan(_picked!);
    final s = ref.read(scanProvider);
    if (s.error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.error!), backgroundColor: AppColors.danger),
      );
      ref.read(scanProvider.notifier).clearError();
      return;
    }

    // Frequency-capped interstitial then jump to result.
    if (!profile.isPro) {
      await ref.read(adServiceProvider).maybeShowInterstitial();
    }
    if (!mounted) return;
    ref.read(screenProvider.notifier).go(AppScreen.result);
  }

  Future<void> _noTokensSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.warn, size: 40),
              const SizedBox(height: 12),
              Text('You\'re out of free scans',
                  style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Watch a short ad for +1 scan, or go Pro for unlimited.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Watch Ad for +1 Scan',
                icon: Icons.play_circle_fill_rounded,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final earned =
                      await ref.read(adServiceProvider).showRewarded();
                  if (earned) {
                    await ref.read(profileProvider.notifier).grantBonusScan();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('+1 scan unlocked!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(screenProvider.notifier).go(AppScreen.paywall);
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Go Pro — Unlimited'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyzing = ref.watch(scanProvider).analyzing;
    final profile = ref.watch(profileProvider);

    return SafeArea(
      child: ResponsiveContentBox(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.s(18), vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(screenProvider.notifier)
                        .go(AppScreen.home),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  Text('New Scan',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.border, width: 1),
                          ),
                          child: _picked == null
                              ? const _Placeholder()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.file(_picked!,
                                      fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: analyzing
                                  ? null
                                  : () => _pick(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: analyzing
                                  ? null
                                  : () => _pick(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded),
                              label: const Text('Library'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const SectionCard(
                        child: _TipsBlock(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: analyzing ? 'Analyzing…' : 'Analyze Face',
                icon: Icons.auto_awesome_rounded,
                onPressed: _picked == null || analyzing ? null : _analyze,
                loading: analyzing,
              ),
              const SizedBox(height: 8),
              Text(
                profile.isPro
                    ? 'Pro: unlimited scans'
                    : '${profile.scanTokens} free scan${profile.scanTokens == 1 ? "" : "s"} left',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.face_retouching_natural_rounded,
              size: 72, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text('Take a selfie or choose from library',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TipsBlock extends StatelessWidget {
  const _TipsBlock();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('For best accuracy',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _tip(context, Icons.wb_sunny_outlined,
            'Good, even lighting (natural daylight works best).'),
        _tip(context, Icons.center_focus_strong_outlined,
            'Face centered, looking straight at the camera.'),
        _tip(context, Icons.mood_outlined,
            'Neutral expression — no smile, relaxed jaw.'),
        _tip(context, Icons.visibility_off_outlined,
            'No glasses, no hair covering your forehead.'),
      ],
    );
  }

  Widget _tip(BuildContext ctx, IconData i, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i, size: 18, color: AppColors.accent2),
            const SizedBox(width: 10),
            Expanded(
                child: Text(t,
                    style: Theme.of(ctx).textTheme.bodyMedium)),
          ],
        ),
      );
}
