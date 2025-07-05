import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/design_system/design_system.dart';
import '../../domain/entities/daily_report.dart';

/// Widget to display a daily report card in the list
class DailyReportCard extends StatelessWidget {
  final DailyReport report;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isSelectionMode;

  const DailyReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingXs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [colorScheme.primaryContainer.withOpacity(0.3), colorScheme.primaryContainer.withOpacity(0.1)]
              : [colorScheme.surface, colorScheme.surfaceContainerLowest],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: (isSelected ? colorScheme.primary : colorScheme.primary).withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isSelected ? colorScheme.primary.withOpacity(0.5) : colorScheme.outlineVariant.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.all(AppDesignTokens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with project name and date with enhanced styling
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.project?.projectName ?? 'Unknown Project',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppDesignTokens.spacingXs),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDesignTokens.spacingSm,
                              vertical: AppDesignTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                              border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: AppDesignTokens.iconSm, color: colorScheme.primary),
                                SizedBox(width: AppDesignTokens.spacingXs),
                                Text(
                                  _formatDate(report.reportDate),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDesignTokens.spacingSm),
                    _buildStatusChip(context),
                  ],
                ),

                SizedBox(height: AppDesignTokens.spacingLg),

                // Enhanced technician and hours section
                Container(
                  padding: EdgeInsets.all(AppDesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.1), width: 1),
                  ),
                  child: Row(
                    children: [
                      // Technician info with avatar-style icon
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppDesignTokens.spacingXs),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: AppDesignTokens.iconMd,
                                color: colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: AppDesignTokens.spacingSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Technician',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppDesignTokens.spacingXxs),
                                  Text(
                                    report.technician?.fullName ?? 'Unknown User',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppDesignTokens.spacingMd),
                      _buildHoursWidget(context),
                    ],
                  ),
                ),

                SizedBox(height: AppDesignTokens.spacingMd),

                // Enhanced footer with photos and navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Photos count with better styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacingSm,
                        vertical: AppDesignTokens.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_rounded, size: AppDesignTokens.iconSm, color: colorScheme.secondary),
                          SizedBox(width: AppDesignTokens.spacingXs),
                          Text(
                            '${report.photosCount} ${report.photosCount == 1 ? 'photo' : 'photos'}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Navigation hint
                    Container(
                      padding: EdgeInsets.all(AppDesignTokens.spacingXs),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: AppDesignTokens.spacingXs),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: AppDesignTokens.iconSm,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  Widget _buildHoursWidget(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate total hours from work progress items
    double totalHours = 0;
    for (final item in report.workProgressItems) {
      totalHours += item.hoursWorked;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingSm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.secondary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_rounded, size: AppDesignTokens.iconMd, color: colorScheme.secondary),
          SizedBox(height: AppDesignTokens.spacingXs),
          Text(
            '${totalHours.toStringAsFixed(1)}h',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
          ),
          Text(
            'Hours',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    IconData icon;
    String label;

    switch (report.status) {
      case DailyReportStatus.draft:
        color = colorScheme.tertiary;
        icon = Icons.edit_rounded;
        label = 'DRAFT';
        break;
      case DailyReportStatus.submitted:
        color = Colors.blue;
        icon = Icons.send_rounded;
        label = 'SUBMITTED';
        break;
      case DailyReportStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        label = 'APPROVED';
        break;
      case DailyReportStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel_rounded;
        label = 'REJECTED';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingMd, vertical: AppDesignTokens.spacingXs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppDesignTokens.spacingXxs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
            ),
            child: Icon(icon, size: AppDesignTokens.iconSm, color: color),
          ),
          SizedBox(width: AppDesignTokens.spacingXs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
