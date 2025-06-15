import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Quick Actions', style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              QuickActionTile(
                title: 'Add Task',
                icon: Icons.task,
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement add task
                },
              ),
              QuickActionTile(
                title: 'Add Report',
                icon: Icons.description,
                color: theme.colorScheme.secondary,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement add report
                },
              ),
              QuickActionTile(
                title: 'Work Request',
                icon: Icons.work,
                color: theme.colorScheme.tertiary,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement work request
                },
              ),
              QuickActionTile(
                title: 'Add Note',
                icon: Icons.note_add,
                color: Colors.amber,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement add note
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static void show(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => QuickActionsBottomSheet(project: project),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 4 - 20;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
