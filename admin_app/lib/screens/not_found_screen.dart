import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Branded 404 Not Found Screen for ShopEase Admin Console
class AdminNotFoundScreen extends StatelessWidget {
  final String? route;

  const AdminNotFoundScreen({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Page Not Found (404) | ShopEase Admin',
      color: AdminTheme.accent,
      child: Scaffold(
        backgroundColor: AdminTheme.bgWorkspace,
        appBar: AppBar(
          backgroundColor: AdminTheme.bgSidebar,
          elevation: 0,
          title: const Text('404: Page Not Found'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                color: AdminTheme.surfaceCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AdminTheme.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminTheme.accentSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          size: 48,
                          color: AdminTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Route Not Found',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        route != null && route!.isNotEmpty
                            ? 'The administrative module "$route" does not exist or has been relocated.'
                            : 'The requested administrative resource could not be found.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AdminTheme.textMuted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                          icon: const Icon(Icons.dashboard_outlined, size: 16),
                          label: const Text('Return to Dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminTheme.accent,
                            foregroundColor: AdminTheme.bgSidebar,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
