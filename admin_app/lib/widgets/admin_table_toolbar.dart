import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Presentation toolbar for admin tables and catalog management lists
class AdminTableToolbar extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;
  final String? countLabel;
  final List<Widget>? filterChips;
  final List<Widget>? actions;

  const AdminTableToolbar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.searchHint = 'Search...',
    this.countLabel,
    this.filterChips,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.space16),
      decoration: const BoxDecoration(
        color: AdminTheme.surfaceCard,
        border: Border(
          bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchInput(),
                if (filterChips != null && filterChips!.isNotEmpty) ...[
                  const SizedBox(height: AdminTheme.space12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: filterChips!),
                  ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: AdminTheme.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (countLabel != null)
                        Text(
                          countLabel!,
                          style: AdminTheme.tableCellMuted,
                        )
                      else
                        const SizedBox.shrink(),
                      Row(children: actions!),
                    ],
                  ),
                ],
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Search input and optional filters
              Expanded(
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: _buildSearchInput(),
                    ),
                    if (filterChips != null && filterChips!.isNotEmpty) ...[
                      const SizedBox(width: AdminTheme.space16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: filterChips!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AdminTheme.space16),

              // Action buttons & count
              Row(
                children: [
                  if (countLabel != null) ...[
                    Text(
                      countLabel!,
                      style: AdminTheme.tableCellMuted,
                    ),
                    const SizedBox(width: AdminTheme.space16),
                  ],
                  ...?actions,
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchInput() {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(fontSize: 13, color: AdminTheme.textPrimary),
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: const TextStyle(fontSize: 13, color: AdminTheme.textMuted),
          prefixIcon: const Icon(Icons.search, size: 18, color: AdminTheme.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          filled: true,
          fillColor: AdminTheme.bgSidebar,
          border: OutlineInputBorder(
            borderRadius: AdminTheme.roundedSm,
            borderSide: const BorderSide(color: AdminTheme.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AdminTheme.roundedSm,
            borderSide: const BorderSide(color: AdminTheme.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AdminTheme.roundedSm,
            borderSide: const BorderSide(color: AdminTheme.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
