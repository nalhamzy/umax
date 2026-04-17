import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/services/iap_product_ids.dart';
import '../core/services/iap_service.dart';
import '../core/utils/responsive.dart';
import '../providers/iap_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selected = IapProductIds.proYearly;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final iap = ref.read(iapServiceProvider);
    final products = iap.allProducts();
    final profile = ref.watch(profileProvider);

    if (profile.isPro) {
      return _AlreadyProView(onBack: _back);
    }

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.s(18), vertical: 8),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.close_rounded),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await iap.restorePurchases();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restore requested')),
                    );
                  },
                  child: const Text('Restore'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Hero(),
            const SizedBox(height: 20),
            _Benefits(),
            const SizedBox(height: 20),
            for (final id in [
              IapProductIds.proYearly,
              IapProductIds.proMonthly,
              IapProductIds.proWeekly,
              IapProductIds.lifetime,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductTile(
                  product: products.firstWhere(
                    (p) => p.id == id,
                    orElse: () => _fallback(id),
                  ),
                  isSelected: _selected == id,
                  onTap: () => setState(() => _selected = id),
                  highlight: id == IapProductIds.proYearly,
                  sublabel: _sublabel(id),
                ),
              ),
            const SizedBox(height: 16),
            GradientButton(
              label: _busy ? 'Processing…' : 'Continue',
              icon: Icons.rocket_launch_rounded,
              loading: _busy,
              onPressed: _busy ? null : _purchase,
            ),
            const SizedBox(height: 10),
            Text(
              'Transparent pricing. Cancel anytime in your App Store / Play Store settings. No hidden fees.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IapProduct _fallback(String id) {
    final titles = {
      IapProductIds.proYearly: 'UMAX Pro — Yearly',
      IapProductIds.proMonthly: 'UMAX Pro — Monthly',
      IapProductIds.proWeekly: 'UMAX Pro — Weekly',
      IapProductIds.lifetime: 'UMAX Lifetime',
    };
    final prices = {
      IapProductIds.proYearly: '\$39.99',
      IapProductIds.proMonthly: '\$9.99',
      IapProductIds.proWeekly: '\$4.99',
      IapProductIds.lifetime: '\$59.99',
    };
    return IapProduct(
      id: id,
      title: titles[id] ?? id,
      price: prices[id] ?? '',
      description: '',
    );
  }

  String _sublabel(String id) => switch (id) {
        IapProductIds.proYearly => 'Best value · 67% off weekly',
        IapProductIds.proMonthly => '7-day free trial',
        IapProductIds.proWeekly => '3-day free trial',
        IapProductIds.lifetime => 'One-time · forever',
        _ => '',
      };

  Future<void> _purchase() async {
    setState(() => _busy = true);
    final iap = ref.read(iapServiceProvider);
    final ok = await iap.purchase(_selected);
    if (!mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Purchase unavailable. Set up IAP products in App Store Connect / Play Console.'),
        ),
      );
      return;
    }
    // Success callback is wired in app.dart — just close.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _busy = false);
    });
  }

  void _back() {
    ref.read(screenProvider.notifier).go(AppScreen.home);
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.gradientGold,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 30),
            ],
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.black, size: 40),
        ),
        const SizedBox(height: 14),
        Text('UMAX Pro', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Unlock your full looks potential',
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _Benefits extends StatelessWidget {
  static const _rows = [
    ['Unlimited face scans', 'Only 3 free / cycle'],
    ['Full trait breakdown', 'Only 3 visible'],
    ['Complete glow-up routine', 'First 4 actions only'],
    ['No ads, ever', 'Banner + interstitial'],
    ['Priority analysis mode', 'Standard'],
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Text('Feature',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text('PRO',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text('Free',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
          const Divider(height: 20),
          for (final r in _rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: Text(r[0],
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Icon(Icons.check_rounded,
                          color: AppColors.gold, size: 20),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(r[1],
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final IapProduct product;
  final bool isSelected;
  final bool highlight;
  final String sublabel;
  final VoidCallback onTap;
  const _ProductTile({
    required this.product,
    required this.isSelected,
    required this.highlight,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.gold : AppColors.border;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.textMuted,
                    width: 2),
                color: isSelected ? AppColors.gold : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(product.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (highlight) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BEST VALUE',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6)),
                        ),
                      ],
                    ],
                  ),
                  if (sublabel.isNotEmpty)
                    Text(sublabel,
                        style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Text(
              product.price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isSelected ? AppColors.gold : AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyProView extends StatelessWidget {
  final VoidCallback onBack;
  const _AlreadyProView({required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.gold, size: 64),
            const SizedBox(height: 12),
            Text("You're Pro! 🎉",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text('Enjoy unlimited scans, full routines and an ad-free experience.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            OutlinedButton(
                onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
