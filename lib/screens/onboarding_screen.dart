import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/models/user_profile.dart';
import '../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  Gender _gender = Gender.male;
  int _age = 20;

  @override
  Widget build(BuildContext context) {
    // If already onboarded, skip.
    final profile = ref.read(profileProvider);
    if (profile.onboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ref.read(screenProvider.notifier).go(AppScreen.home));
    }

    return SafeArea(
      child: ResponsiveContentBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.s(22), vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _Header(step: _step),
              const SizedBox(height: 32),
              Expanded(child: _body()),
              GradientButton(
                label: _step < 2 ? 'Continue' : 'Start My Analysis',
                icon: Icons.arrow_forward_rounded,
                onPressed: _next,
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _IntroStep();
      case 1:
        return _GenderStep(
          gender: _gender,
          onChanged: (g) => setState(() => _gender = g),
        );
      case 2:
      default:
        return _AgeStep(
          age: _age,
          onChanged: (a) => setState(() => _age = a),
        );
    }
  }

  Future<void> _next() async {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await ref
        .read(profileProvider.notifier)
        .completeOnboarding(gender: _gender, age: _age);
    ref.read(screenProvider.notifier).go(AppScreen.home);
  }
}

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('UMAX', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          'AI Looksmax · Level Up Your Face',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i <= step;
            return Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _IntroStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Find your looksmax potential.',
              style: Theme.of(context).textTheme.displaySmall ??
                  Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Get an objective, private AI analysis of your face. Score your '
            'symmetry, jawline, eyes, skin and more — then follow a personalized '
            '30-day routine.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary, height: 1.45,
                ),
          ),
          const SizedBox(height: 22),
          _Bullet(icon: Icons.lock_outline, text: 'Private: photos analyzed locally on your device.'),
          _Bullet(icon: Icons.auto_graph_rounded, text: 'Progress tracking: see your glow-up over time.'),
          _Bullet(icon: Icons.bolt_rounded, text: '3 free scans, no credit card required.'),
          _Bullet(icon: Icons.workspace_premium_rounded, text: 'Pro unlocks unlimited scans + full routines.'),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderStep extends StatelessWidget {
  final Gender gender;
  final ValueChanged<Gender> onChanged;
  const _GenderStep({required this.gender, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tell us about you.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Your routine + analysis are calibrated by gender. No data leaves this device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          for (final g in Gender.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onChanged(g),
                child: SectionCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        g == Gender.male
                            ? Icons.male_rounded
                            : g == Gender.female
                                ? Icons.female_rounded
                                : Icons.transgender_rounded,
                        color: gender == g ? AppColors.accent : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        g == Gender.male
                            ? 'Male'
                            : g == Gender.female
                                ? 'Female'
                                : 'Other',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (gender == g)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgeStep extends StatelessWidget {
  final int age;
  final ValueChanged<int> onChanged;
  const _AgeStep({required this.age, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How old are you?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'We use this to weigh certain traits (facial maturity, skin expectations).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              children: [
                Text(
                  '$age',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    min: 14, max: 80,
                    divisions: 66,
                    value: age.toDouble(),
                    onChanged: (v) => onChanged(v.round()),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('14', style: Theme.of(context).textTheme.bodyMedium),
                    Text('80', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
