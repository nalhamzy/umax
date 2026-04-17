import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/section_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scans = ref.watch(scanProvider).history;

    return SafeArea(
      child: ResponsiveContentBox(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 6),
                Text('Progress',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            Expanded(
              child: scans.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.s(16), vertical: 8),
                      itemCount: scans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final r = scans[i];
                        final delta = i < scans.length - 1
                            ? r.analysis.overall -
                                scans[i + 1].analysis.overall
                            : 0.0;
                        return InkWell(
                          onTap: () {
                            ref.read(scanProvider.notifier).selectHistoric(r);
                            ref.read(screenProvider.notifier).go(AppScreen.result);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: SectionCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(r.imagePath),
                                    width: 64, height: 64, fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('MMM d, yyyy · h:mm a')
                                            .format(r.analysis.timestamp),
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r.analysis.tier,
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontSize: 15,
                                              color: AppColors.scoreColor(
                                                  r.analysis.overall),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      r.analysis.overall.round().toString(),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.scoreColor(
                                            r.analysis.overall),
                                      ),
                                    ),
                                    if (delta != 0)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            delta > 0
                                                ? Icons.arrow_upward_rounded
                                                : Icons.arrow_downward_rounded,
                                            size: 14,
                                            color: delta > 0
                                                ? AppColors.success
                                                : AppColors.accent3,
                                          ),
                                          Text(
                                            delta.abs().toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: delta > 0
                                                  ? AppColors.success
                                                  : AppColors.accent3,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timeline_rounded,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No scans yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Scans you take will show up here. Re-scan every 1–2 weeks to see your glow-up.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
