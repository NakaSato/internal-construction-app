import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project_detail.dart';

class ProjectInfoCards extends StatelessWidget {
  const ProjectInfoCards({super.key, required this.projectDetail});

  final ProjectDetail projectDetail;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(child: _buildLocationCard(context)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateCard(
                  context,
                  title: 'Start Date',
                  date: dateFormat.format(projectDetail.startDate),
                  icon: Icons.play_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateCard(
                  context,
                  title: 'End Date',
                  date: dateFormat.format(projectDetail.endDate),
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildLocationCard(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    context,
                    title: 'Start Date',
                    date: dateFormat.format(projectDetail.startDate),
                    icon: Icons.play_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateCard(
                    context,
                    title: 'End Date',
                    date: dateFormat.format(projectDetail.endDate),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: colorScheme.onTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    projectDetail.location,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required String title,
    required String date,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
