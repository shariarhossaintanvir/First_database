import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Presentation row for category-specific product specifications (Star Tech / Pickaboo inspired)
class SpecAttributeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;
  final bool isZebra;

  const SpecAttributeRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
    this.isZebra = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isZebra ? AppTheme.bgSecondary.withValues(alpha: 0.5) : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Specification Key / Attribute Label
              SizedBox(
                width: 140,
                child: Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),

              // Specification Value
              Expanded(
                child: Text(
                  value,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: AppTheme.space12),
            const Divider(color: AppTheme.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }
}

/// Presentation card displaying a structured list or map of product specifications
class SpecAttributeTable extends StatelessWidget {
  final String? title;
  final Map<String, String> specifications;

  const SpecAttributeTable({
    super.key,
    this.title,
    required this.specifications,
  });

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) return const SizedBox.shrink();

    final entries = specifications.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: AppTheme.roundedMd,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Text(
                    title!,
                    style: AppTheme.title.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.borderSubtle, height: 1),
          ],
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isLast = index == entries.length - 1;
              return SpecAttributeRow(
                label: entry.key,
                value: entry.value,
                showDivider: !isLast,
                isZebra: index.isOdd,
              );
            },
          ),
        ],
      ),
    );
  }
}
