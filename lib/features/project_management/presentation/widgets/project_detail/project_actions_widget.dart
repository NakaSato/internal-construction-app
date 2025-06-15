import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectActionsWidget extends StatelessWidget {
  const ProjectActionsWidget({
    super.key,
    required this.project,
    this.onDailyReports,
    this.onWorkRequests,
    this.onAddTask,
    this.onProjectTeam,
  });

  final Project project;
  final VoidCallback? onDailyReports;
  final VoidCallback? onWorkRequests;
  final VoidCallback? onAddTask;
  final VoidCallback? onProjectTeam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Daily Reports',
                    icon: Icons.assessment_outlined,
                    color: theme.colorScheme.primary,
                    onPressed: onDailyReports ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily reports coming soon')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: 'Work Requests',
                    icon: Icons.assignment_outlined,
                    color: theme.colorScheme.secondary,
                    onPressed: onWorkRequests ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Work requests coming soon')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Add Task',
                    icon: Icons.add_task,
                    color: theme.colorScheme.tertiary,
                    onPressed: onAddTask ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add task functionality coming soon')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: 'Project Team',
                    icon: Icons.people_outline,
                    color: Colors.indigo,
                    onPressed: onProjectTeam ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project team functionality coming soon')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
