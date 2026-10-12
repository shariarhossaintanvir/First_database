import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Presentation component for key-value specification row editor (Star Tech / Pickaboo inspired)
class AdminSpecBuilderRow extends StatelessWidget {
  final TextEditingController keyController;
  final TextEditingController valueController;
  final VoidCallback onRemove;
  final String keyHint;
  final String valueHint;

  const AdminSpecBuilderRow({
    super.key,
    required this.keyController,
    required this.valueController,
    required this.onRemove,
    this.keyHint = 'Attribute (e.g. Warranty)',
    this.valueHint = 'Value (e.g. 2 Years Official)',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminTheme.space10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Key / Attribute name
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: keyController,
                style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: keyHint,
                  hintStyle: const TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  fillColor: AdminTheme.bgSidebar,
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminTheme.space10),

          // Value / Specification detail
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: valueController,
                style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: valueHint,
                  hintStyle: const TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  filled: true,
                  fillColor: AdminTheme.bgSidebar,
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminTheme.space8),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              size: 20,
              color: AdminTheme.statusError,
            ),
            tooltip: 'Remove Specification',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Presentation card previewing product key-value specifications builder
class AdminSpecBuilderCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onAddRow;
  final String addLabel;

  const AdminSpecBuilderCard({
    super.key,
    this.title = 'Product Specifications & Attributes',
    required this.children,
    required this.onAddRow,
    this.addLabel = 'Add Attribute',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.space16),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceCard,
        borderRadius: AdminTheme.roundedMd,
        border: Border.all(color: AdminTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AdminTheme.accent,
                  ),
                  const SizedBox(width: AdminTheme.space8),
                  Text(
                    title,
                    style: AdminTheme.title.copyWith(fontSize: 14),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onAddRow,
                icon: const Icon(Icons.add, size: 16),
                label: Text(addLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminTheme.space16),
          if (children.isEmpty)
            Container(
              padding: const EdgeInsets.all(AdminTheme.space20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AdminTheme.bgSidebar,
                borderRadius: AdminTheme.roundedSm,
                border: Border.all(
                  color: AdminTheme.borderSubtle,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                'No specifications added. Click "$addLabel" to define category-specific specs (e.g. RAM, Storage, Warranty).',
                textAlign: TextAlign.center,
                style: AdminTheme.bodySmall.copyWith(color: AdminTheme.textMuted),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}
