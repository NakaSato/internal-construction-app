import 'package:flutter/material.dart';
import '../config/environment_config.dart';

/// Widget for selecting API environment during development
/// Should only be shown in debug mode or development builds
class ApiEnvironmentSelector extends StatefulWidget {
  const ApiEnvironmentSelector({super.key, this.onEnvironmentChanged, this.showInProduction = false});

  final void Function(Environment)? onEnvironmentChanged;
  final bool showInProduction;

  @override
  State<ApiEnvironmentSelector> createState() => _ApiEnvironmentSelectorState();
}

class _ApiEnvironmentSelectorState extends State<ApiEnvironmentSelector> {
  @override
  Widget build(BuildContext context) {
    // Don't show in production unless explicitly allowed
    if (EnvironmentConfig.isProduction && !widget.showInProduction) {
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
                Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'API Environment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Current Environment: ${_getEnvironmentDisplayName(EnvironmentConfig.currentEnvironment)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getEnvironmentColor(EnvironmentConfig.currentEnvironment).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getEnvironmentColor(EnvironmentConfig.currentEnvironment).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getEnvironmentIcon(EnvironmentConfig.currentEnvironment),
                    size: 16,
                    color: _getEnvironmentColor(EnvironmentConfig.currentEnvironment),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getEnvironmentDisplayName(EnvironmentConfig.currentEnvironment),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getEnvironmentColor(EnvironmentConfig.currentEnvironment),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'API Base URL:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                EnvironmentConfig.apiBaseUrl,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
            if (!EnvironmentConfig.isProduction) ...[
              const SizedBox(height: 16),
              Text(
                'Environment Details:',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              _buildInfoChip('Debug Mode', EnvironmentConfig.debugMode.toString()),
              const SizedBox(height: 4),
              _buildInfoChip('Development', EnvironmentConfig.isDevelopment.toString()),
              const SizedBox(height: 4),
              _buildInfoChip('Local', EnvironmentConfig.isLocal.toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getEnvironmentDisplayName(Environment environment) {
    return switch (environment) {
      Environment.development => 'Development',
      Environment.production => 'Production',
      Environment.local => 'Local',
    };
  }

  IconData _getEnvironmentIcon(Environment environment) {
    return switch (environment) {
      Environment.development => Icons.code,
      Environment.production => Icons.cloud,
      Environment.local => Icons.computer,
    };
  }

  Color _getEnvironmentColor(Environment environment) {
    return switch (environment) {
      Environment.development => Colors.orange,
      Environment.production => Colors.green,
      Environment.local => Colors.blue,
    };
  }
}

/// Simplified environment indicator for debug builds
class EnvironmentIndicator extends StatelessWidget {
  const EnvironmentIndicator({super.key, this.showInProduction = false});

  final bool showInProduction;

  @override
  Widget build(BuildContext context) {
    // Don't show in production unless explicitly allowed
    if (EnvironmentConfig.isProduction && !showInProduction) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getEnvironmentColor().withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getEnvironmentIcon(), size: 12, color: _getEnvironmentColor()),
          const SizedBox(width: 4),
          Text(
            EnvironmentConfig.currentEnvironment.name.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _getEnvironmentColor(), fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _getEnvironmentIcon() {
    return switch (EnvironmentConfig.currentEnvironment) {
      Environment.development => Icons.code,
      Environment.production => Icons.cloud,
      Environment.local => Icons.computer,
    };
  }

  Color _getEnvironmentColor() {
    return switch (EnvironmentConfig.currentEnvironment) {
      Environment.development => Colors.orange,
      Environment.production => Colors.green,
      Environment.local => Colors.blue,
    };
  }
}
