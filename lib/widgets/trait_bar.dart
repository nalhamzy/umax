import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/models/face_analysis.dart';

class TraitBar extends StatelessWidget {
  final TraitScore trait;
  const TraitBar({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(trait.score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                trait.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${trait.score.round()}',
              style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: trait.score / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          trait.insight,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
