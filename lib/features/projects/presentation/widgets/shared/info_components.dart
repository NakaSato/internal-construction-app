import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';

/// Utility class for formatting values consistently across info components
class InfoFormatters {
  InfoFormatters._(); // Private constructor to prevent instantiation

  /// Formats currency with proper number separators
  static String formatCurrency(double amount, String currencySymbol) {
    final formatted = amount
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    return '$currencySymbol$formatted';
  }

  /// Formats date with optional time
  static String formatDate(DateTime date, {bool includeTime = false}) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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

  /// Formats technical specifications with units
  static String formatSpec(double value, String unit, {int precision = 1}) {
    return '${value.toStringAsFixed(precision)} $unit';
  }

  /// Handles null/empty value display consistently
  static String handleEmptyValue(String? value, {String fallback = 'Not Set'}) {
    if (value == null || value.isEmpty || value == 'null' || value == 'N/A') {
      return fallback;
    }
    return value;
  }

  /// Checks if a value should be considered empty
  static bool isEmptyValue(String? value) {
    return value == null || value.isEmpty || value == 'null' || value == 'N/A';
  }

  /// Formats large numbers with appropriate suffixes (K, M, B)
  static String formatLargeNumber(double number, {int precision = 1}) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(precision)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(precision)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(precision)}K';
    }
    return number.toStringAsFixed(precision);
  }

  /// Formats duration in a human-readable format
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Formats file size in appropriate units
  static String formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes bytes';
  }

  /// Truncates text with ellipsis if it exceeds maxLength
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalizes the first letter of each word
  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Reusable card structure for grouping related information on detail screens
///
/// Features:
/// - Clear title with optional icon
/// - Consistent padding and Material Design 3 styling
/// - Divider between title and content for visual separation
/// - Customizable background color
/// - Responsive design with proper elevation and borders
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.children, this.icon, this.backgroundColor});

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: SolarSpacing.sm),
        elevation: 2,
        color: backgroundColor ?? context.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SolarBorderRadius.md),
          side: BorderSide(
            color: Color.alphaBlend(context.colorScheme.outlineVariant.withOpacity(0.3), Colors.transparent),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SolarSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card title with optional icon
              _InfoCardHeader(title: title, icon: icon),

              const SizedBox(height: SolarSpacing.md),

              // Divider
              _InfoCardDivider(),

              const SizedBox(height: SolarSpacing.md),

              // Content
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Optimized header widget for InfoCard
class _InfoCardHeader extends StatelessWidget {
  const _InfoCardHeader({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: context.colorScheme.primary, size: 20),
          const SizedBox(width: SolarSpacing.sm),
        ],
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Optimized divider widget for InfoCard
class _InfoCardDivider extends StatelessWidget {
  const _InfoCardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Color.alphaBlend(context.colorScheme.outlineVariant.withOpacity(0.3), Colors.transparent),
    );
  }
}

/// Individual information row within an InfoCard
///
/// Features:
/// - Optional leading icon
/// - Bold label and formatted value
/// - Consistent spacing and theming
/// - Handles null/empty values gracefully
/// - Optional copy-to-clipboard functionality
/// - Tap interaction support
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
    final isEmpty = InfoFormatters.isEmptyValue(value);
    final displayValue = InfoFormatters.handleEmptyValue(value);
    final textColor = isEmpty
        ? context.colorScheme.onSurface.withValues(alpha: 0.5)
        : valueColor ?? context.colorScheme.onSurface;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: SolarSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional leading icon
          if (icon != null) ...[
            Icon(icon, color: context.colorScheme.onSurface.withValues(alpha: 0.7), size: 16),
            const SizedBox(width: SolarSpacing.md),
          ],

          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(width: SolarSpacing.lg),

          // Value with optional copy button
          Expanded(flex: 3, child: _buildValueSection(context, displayValue, isEmpty, textColor)),
        ],
      ),
    );

    // Wrap with tap interaction if provided
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SolarSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.sm),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildValueSection(BuildContext context, String displayValue, bool isEmpty, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            displayValue,
            style: context.textTheme.bodyMedium?.copyWith(
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
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Copy to clipboard',
          ),
        ],
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Copied "$text" to clipboard'), duration: const Duration(seconds: 2)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to copy to clipboard'), duration: Duration(seconds: 2)));
      }
    }
  }
}

/// Specialized InfoRow for displaying currency values
///
/// Features:
/// - Automatic currency formatting with separators
/// - Customizable currency symbol
/// - Green color for monetary values
/// - Handles null amounts gracefully
class CurrencyInfoRow extends StatelessWidget {
  const CurrencyInfoRow({super.key, required this.label, required this.amount, this.icon, this.currency = '฿'});

  final String label;
  final double? amount;
  final IconData? icon;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount != null ? InfoFormatters.formatCurrency(amount!, currency) : 'Not Set';

    return InfoRow(
      label: label,
      value: formattedAmount,
      icon: icon,
      valueColor: amount != null ? Colors.green.shade700 : null,
    );
  }
}

/// Specialized InfoRow for displaying dates
///
/// Features:
/// - Consistent date formatting (MMM d, yyyy)
/// - Optional time display (HH:mm)
/// - Handles null dates gracefully
/// - Readable month abbreviations
class DateInfoRow extends StatelessWidget {
  const DateInfoRow({super.key, required this.label, required this.date, this.icon, this.showTime = false});

  final String label;
  final DateTime? date;
  final IconData? icon;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final formattedDate = date != null ? InfoFormatters.formatDate(date!, includeTime: showTime) : 'Not Set';

    return InfoRow(label: label, value: formattedDate, icon: icon);
  }
}

/// Specialized InfoRow for technical specifications
///
/// Features:
/// - Consistent numeric formatting with units
/// - Configurable decimal precision
/// - Handles null values gracefully
/// - Proper unit spacing and display
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
    final formattedValue = value != null ? InfoFormatters.formatSpec(value!, unit, precision: precision) : 'Not Set';

    return InfoRow(label: label, value: formattedValue, icon: icon);
  }
}

/// Specialized InfoRow for displaying percentage values
///
/// Features:
/// - Automatic percentage formatting
/// - Color coding based on percentage ranges
/// - Configurable decimal precision
/// - Progress bar visualization option
class PercentageInfoRow extends StatelessWidget {
  const PercentageInfoRow({
    super.key,
    required this.label,
    required this.percentage,
    this.icon,
    this.precision = 1,
    this.showProgressBar = false,
    this.colorCoded = true,
  });

  final String label;
  final double? percentage;
  final IconData? icon;
  final int precision;
  final bool showProgressBar;
  final bool colorCoded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (percentage == null) {
      return InfoRow(label: label, value: 'Not Set', icon: icon);
    }

    final formattedPercentage = '${percentage!.toStringAsFixed(precision)}%';
    final color = colorCoded ? _getPercentageColor(percentage!) : null;

    if (showProgressBar) {
      return _buildWithProgressBar(theme, formattedPercentage, color);
    }

    return InfoRow(label: label, value: formattedPercentage, icon: icon, valueColor: color);
  }

  Widget _buildWithProgressBar(ThemeData theme, String formattedPercentage, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: label, value: formattedPercentage, icon: icon, valueColor: color),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (percentage! / 100).clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color ?? theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double value) {
    if (value >= 90) return Colors.green.shade700;
    if (value >= 70) return Colors.lightGreen.shade700;
    if (value >= 50) return Colors.orange.shade700;
    if (value >= 30) return Colors.deepOrange.shade700;
    return Colors.red.shade700;
  }
}

/// Specialized InfoRow for displaying status with color coding
///
/// Features:
/// - Status badge with background color
/// - Predefined status colors
/// - Custom status color support
/// - Icon integration
class StatusInfoRow extends StatelessWidget {
  const StatusInfoRow({
    super.key,
    required this.label,
    required this.status,
    this.icon,
    this.statusColor,
    this.showBadge = true,
  });

  final String label;
  final String status;
  final IconData? icon;
  final Color? statusColor;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = statusColor ?? _getDefaultStatusColor(status);

    if (showBadge) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 16),
              const SizedBox(width: 12),
            ],
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
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InfoRow(label: label, value: status, icon: icon, valueColor: color);
  }

  Color _getDefaultStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'success':
        return Colors.green.shade700;
      case 'pending':
      case 'in progress':
      case 'processing':
        return Colors.orange.shade700;
      case 'cancelled':
      case 'failed':
      case 'error':
        return Colors.red.shade700;
      case 'on hold':
      case 'paused':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade700;
    }
  }
}

/// Specialized InfoRow for displaying contact information
///
/// Features:
/// - Clickable email and phone links
/// - Copy to clipboard functionality
/// - Proper contact formatting
/// - Icon integration for contact types
class ContactInfoRow extends StatelessWidget {
  const ContactInfoRow({
    super.key,
    required this.label,
    required this.contact,
    this.contactType = ContactType.general,
    this.icon,
  });

  final String label;
  final String contact;
  final ContactType contactType;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InfoRow(
      label: label,
      value: contact,
      icon: icon ?? _getDefaultIcon(),
      copyable: true,
      onTap: () => _handleContactTap(context),
    );
  }

  IconData _getDefaultIcon() {
    switch (contactType) {
      case ContactType.email:
        return Icons.email_outlined;
      case ContactType.phone:
        return Icons.phone_outlined;
      case ContactType.website:
        return Icons.language_outlined;
      case ContactType.general:
        return Icons.contact_page_outlined;
    }
  }

  void _handleContactTap(BuildContext context) {
    // Here you could implement actual contact functionality
    // like opening email client, phone dialer, or web browser
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Contact action for: $contact'), duration: const Duration(seconds: 2)));
  }
}

/// Enumeration for contact types
enum ContactType { email, phone, website, general }
