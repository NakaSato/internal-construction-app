import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/project_detail.dart';
import 'project_progress_card.dart';
import 'project_budget_card.dart';
import 'project_tasks_section.dart';
import 'recent_reports_section.dart';
import 'project_hero_section.dart';
import 'project_info_cards.dart';

class ProjectDetailContent extends StatelessWidget {
  const ProjectDetailContent({
    super.key,
    required this.projectDetail,
  });

  final ProjectDetail projectDetail;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero section with gradient background
        SliverToBoxAdapter(
          child: ProjectHeroSection(projectDetail: projectDetail),
        ),
        
        // Main content
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              
              // Project info cards in grid
              ProjectInfoCards(projectDetail: projectDetail),
              
              const SizedBox(height: 24),
              
              // Progress and Budget in a row on larger screens
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ProjectProgressCard(
                              totalTasks: projectDetail.totalTasks,
                              completedTasks: projectDetail.completedTasks,
                              progressPercentage: projectDetail.progressPercentage,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ProjectBudgetCard(
                              budget: projectDetail.budget,
                              actualCost: projectDetail.actualCost,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Stack vertically on smaller screens
                  return Column(
                    children: [
                      ProjectProgressCard(
                        totalTasks: projectDetail.totalTasks,
                        completedTasks: projectDetail.completedTasks,
                        progressPercentage: projectDetail.progressPercentage,
                      ),
                      const SizedBox(height: 16),
                      ProjectBudgetCard(
                        budget: projectDetail.budget,
                        actualCost: projectDetail.actualCost,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Tasks section
              ProjectTasksSection(tasks: projectDetail.tasks),
              
              const SizedBox(height: 24),
              
              // Recent reports section
              RecentReportsSection(reports: projectDetail.recentReports),
              
              const SizedBox(height: 32), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }
}
              'Project Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.location_on,
              label: 'Location',
              value: projectDetail.location,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: dateFormat.format(projectDetail.startDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.event,
              label: 'End Date',
              value: dateFormat.format(projectDetail.endDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
