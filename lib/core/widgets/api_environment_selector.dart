import 'package:flutter/material.dart';
import '../../core/api/api_config.dart';

/// Widget for selecting API environment during development
/// Should only be shown in debug mode or development builds
class ApiEnvironmentSelector extends StatefulWidget {
  const ApiEnvironmentSelector({
    super.key,
    this.onEnvironmentChanged,
    this.showInProduction = false,
  });

  final void Function(ApiEnvironment)? onEnvironmentChanged;
  final bool showInProduction;

  @override
  State<ApiEnvironmentSelector> createState() => _ApiEnvironmentSelectorState();
}

class _ApiEnvironmentSelectorState extends State<ApiEnvironmentSelector> {
  @override
  Widget build(BuildContext context) {
    // Don't show in production unless explicitly allowed
    if (ApiConfig.isProduction && !widget.showInProduction) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'API Environment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Environment selector
            DropdownButtonFormField<ApiEnvironment>(
              value: ApiConfig.currentEnvironment,
              decoration: InputDecoration(
                labelText: 'Select Environment',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _getEnvironmentIcon(ApiConfig.currentEnvironment),
                  color: _getEnvironmentColor(ApiConfig.currentEnvironment),
                ),
              ),
              items: ApiConfig.availableEnvironments.map((environment) {
                return DropdownMenuItem(
                  value: environment,
                  child: Row(
                    children: [
                      Icon(
                        _getEnvironmentIcon(environment),
                        size: 16,
                        color: _getEnvironmentColor(environment),
                      ),
                      const SizedBox(width: 8),
                      Text(ApiConfig.environmentDisplayNames[environment]!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (environment) {
                if (environment != null) {
                  setState(() {
                    ApiConfig.setEnvironment(environment);
                  });
                  widget.onEnvironmentChanged?.call(environment);

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Environment changed to ${ApiConfig.environmentName}',
                      ),
                      backgroundColor: _getEnvironmentColor(environment),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            // Current URL display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current URL:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    ApiConfig.configuredBaseUrl,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Debug info
            if (!ApiConfig.isProduction) ...[
              const SizedBox(height: 8),
              Text(
                'Debug Mode: Environment switching enabled',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEnvironmentIcon(ApiEnvironment environment) {
    switch (environment) {
      case ApiEnvironment.development:
        return Icons.code;
      case ApiEnvironment.production:
        return Icons.public;
      case ApiEnvironment.local:
        return Icons.computer;
    }
  }

  Color _getEnvironmentColor(ApiEnvironment environment) {
    switch (environment) {
      case ApiEnvironment.development:
        return Colors.orange;
      case ApiEnvironment.production:
        return Colors.green;
      case ApiEnvironment.local:
        return Colors.purple;
    }
  }
}

/// Simple environment indicator widget for app bar or status display
class ApiEnvironmentIndicator extends StatelessWidget {
  const ApiEnvironmentIndicator({super.key, this.showInProduction = false});

  final bool showInProduction;

  @override
  Widget build(BuildContext context) {
    // Don't show in production unless explicitly allowed
    if (ApiConfig.isProduction && !showInProduction) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEnvironmentColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getEnvironmentColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getEnvironmentIcon(), size: 12, color: _getEnvironmentColor()),
          const SizedBox(width: 4),
          Text(
            ApiConfig.environmentName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getEnvironmentColor(),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEnvironmentIcon() {
    switch (ApiConfig.currentEnvironment) {
      case ApiEnvironment.development:
        return Icons.code;
      case ApiEnvironment.production:
        return Icons.public;
      case ApiEnvironment.local:
        return Icons.computer;
    }
  }

  Color _getEnvironmentColor() {
    switch (ApiConfig.currentEnvironment) {
      case ApiEnvironment.development:
        return Colors.orange;
      case ApiEnvironment.production:
        return Colors.green;
      case ApiEnvironment.local:
        return Colors.purple;
    }
  }
}
