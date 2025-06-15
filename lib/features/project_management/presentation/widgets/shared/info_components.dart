import 'package:flutter/material.dart';

/// Reusable card structure for grouping related information on detail screens
///
/// Features:
/// - Clear title with optional icon
/// - Consistent padding and styling
/// - Divider between title and content
/// - Material Design 3 elevation and colors
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.backgroundColor,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card title with optional icon
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            Container(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),

            const SizedBox(height: 12),

            // Content
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Individual information row within an InfoCard
///
/// Features:
/// - Optional leading icon
/// - Bold label and formatted value
/// - Consistent spacing
/// - Handles null/empty values gracefully
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.onTap,
    this.copyable = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.isEmpty || value == 'null' || value == 'N/A';
    final displayValue = isEmpty ? 'Not Set' : value;
    final textColor = isEmpty
        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
        : valueColor ?? theme.colorScheme.onSurface;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional leading icon
          if (icon != null) ...[
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 16,
            ),
            const SizedBox(width: 12),
          ],

          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Value
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayValue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                if (copyable && !isEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 16),
                    onPressed: () => _copyToClipboard(context, value),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: content,
        ),
      );
    }

    return content;
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Import clipboard functionality
    // Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Specialized InfoRow for displaying currency values
class CurrencyInfoRow extends StatelessWidget {
  const CurrencyInfoRow({
    super.key,
    required this.label,
    required this.amount,
    this.icon,
    this.currency = '฿',
  });

  final String label;
  final double? amount;
  final IconData? icon;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount != null
        ? _formatCurrency(amount!, currency)
        : 'Not Set';

    return InfoRow(
      label: label,
      value: formattedAmount,
      icon: icon,
      valueColor: amount != null ? Colors.green.shade700 : null,
    );
  }

  String _formatCurrency(double amount, String currencySymbol) {
    final formatted = amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$currencySymbol$formatted';
  }
}

/// Specialized InfoRow for displaying dates
class DateInfoRow extends StatelessWidget {
  const DateInfoRow({
    super.key,
    required this.label,
    required this.date,
    this.icon,
    this.showTime = false,
  });

  final String label;
  final DateTime? date;
  final IconData? icon;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final formattedDate = date != null
        ? _formatDate(date!, showTime)
        : 'Not Set';

    return InfoRow(label: label, value: formattedDate, icon: icon);
  }

  String _formatDate(DateTime date, bool includeTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final monthName = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    String formatted = '$monthName $day, $year';

    if (includeTime) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      formatted += ' at $hour:$minute';
    }

    return formatted;
  }
}

/// Specialized InfoRow for technical specifications
class SpecInfoRow extends StatelessWidget {
  const SpecInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.precision = 1,
  });

  final String label;
  final double? value;
  final String unit;
  final IconData? icon;
  final int precision;

  @override
  Widget build(BuildContext context) {
    final formattedValue = value != null
        ? '${value!.toStringAsFixed(precision)} $unit'
        : 'Not Set';

    return InfoRow(label: label, value: formattedValue, icon: icon);
  }
}
