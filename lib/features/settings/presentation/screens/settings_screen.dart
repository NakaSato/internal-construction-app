import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../core/utils/api_config_verifier.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(context, 'App Settings'),

            _buildSettingItem(
              context: context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () =>
                  _showComingSoonSnackBar(context, 'Notification settings'),
            ),

            const SizedBox(height: 24),

            _buildSettingsSection(context, 'Security & Privacy'),

            _buildSettingItem(
              context: context,
              icon: Icons.security,
              title: 'Security',
              subtitle: 'Manage your account security',
              onTap: () =>
                  _showComingSoonSnackBar(context, 'Security settings'),
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.privacy_tip,
              title: 'Privacy',
              subtitle: 'Manage your privacy settings',
              onTap: () => _showComingSoonSnackBar(context, 'Privacy settings'),
            ),

            const SizedBox(height: 24),

            _buildSettingItem(
              context: context,
              icon: Icons.info,
              title: 'About App',
              subtitle: 'App version and information',
              onTap: () => _showComingSoonSnackBar(context, 'About app'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a coming soon snackbar
  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds a settings section title
  Widget _buildSettingsSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds a settings item card
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Debug section showing API configuration (only visible in development)
  Widget _buildApiConfigDebugSection(BuildContext context) {
    final config = ApiConfigVerifier.getConfigSummary();
    final isConfigValid = config['isCorrectHost'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ExpansionTile(
        leading: Icon(
          isConfigValid ? Icons.check_circle : Icons.warning,
          color: isConfigValid ? Colors.green : Colors.orange,
        ),
        title: Text(
          'API Configuration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Host: ${config['apiBaseUrl']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigRow(
                  context,
                  'Environment',
                  config['environment']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  context,
                  'Debug Mode',
                  config['debugMode']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  context,
                  'API Base URL',
                  config['apiBaseUrl']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  context,
                  'Env File Loaded',
                  config['envFileLoaded']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  context,
                  'Correct Host',
                  config['isCorrectHost']?.toString() ?? 'N/A',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds configuration row for debug section
  Widget _buildConfigRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
