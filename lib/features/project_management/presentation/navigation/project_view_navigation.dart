import 'package:flutter/material.dart';
import '../screens/image_project_card_list_screen.dart';

/// Helper class to manage navigation between different project management views
/// Provides both engineer-focused and general user interfaces
class ProjectManagementNavigation {
  ProjectManagementNavigation._();

  /// Shows a bottom sheet allowing users to choose between view modes
  static void showViewModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _ViewModeSelector(),
    );
  }

  /// Navigate to engineer-focused table view
  static void navigateToEngineerTableView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageProjectCardListScreen(),
      ),
    );
  }

  /// Navigate to standard card view
  static void navigateToCardView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageProjectCardListScreen(),
      ),
    );
  }

  /// Navigate to engineer-focused project detail
  static void navigateToEngineerDetail(BuildContext context, String projectId) {
    // TODO: Implement enhanced project detail screen
    // For now, navigate back to project list
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageProjectCardListScreen(),
      ),
    );
  }

  /// Navigate to standard project detail
  static void navigateToStandardDetail(BuildContext context, String projectId) {
    // TODO: Implement enhanced project detail screen
    // For now, navigate back to project list
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageProjectCardListScreen(),
      ),
    );
  }
}

/// Bottom sheet widget for selecting view mode
class _ViewModeSelector extends StatelessWidget {
  const _ViewModeSelector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.view_module, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Choose View Mode',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select the interface that best suits your workflow',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Engineer View Option
          _ViewModeOption(
            icon: Icons.table_rows,
            title: 'Engineer View',
            subtitle: 'Data-dense table with technical focus',
            features: [
              'Sortable table with key metrics',
              'Advanced filtering capabilities',
              'Quick access to technical data',
              'Optimized for on-site use',
            ],
            onTap: () {
              Navigator.pop(context);
              ProjectManagementNavigation.navigateToEngineerTableView(context);
            },
          ),

          const SizedBox(height: 16),

          // Standard View Option
          _ViewModeOption(
            icon: Icons.view_module,
            title: 'Standard View',
            subtitle: 'Visual cards with project overview',
            features: [
              'Project image cards',
              'Visual progress indicators',
              'Easy browsing experience',
              'Better for project overview',
            ],
            onTap: () {
              Navigator.pop(context);
              ProjectManagementNavigation.navigateToCardView(context);
            },
          ),

          const SizedBox(height: 16),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual view mode option widget
class _ViewModeOption extends StatelessWidget {
  const _ViewModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Features list
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
