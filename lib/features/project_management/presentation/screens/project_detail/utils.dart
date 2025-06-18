import 'package:flutter/material.dart';
import '../../../../domain/entities/project.dart';
import 'constants.dart';

/// Utility methods for project detail screen
class ProjectDetailUtils {
  
  /// Format date for daily report display
  static String formatReportDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get user initials from full name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  /// Show feature coming soon snackbar
  static void showFeatureComingSoonSnackBar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName functionality coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show delete project confirmation dialog
  static void showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.projectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Extension methods for Project entity
extension ProjectExtensions on Project {
  List<ProjectTask> get tasks => [];
  List<RecentReport> get recentReports => [];
  double? get budget => null;
  double? get actualCost => null;
  int? get totalTasks => taskCount;
  int? get completedTasks => completedTaskCount;
}

/// Helper classes for project tasks and reports
class ProjectTask {
  final String title;
  final String status;
  final DateTime dueDate;

  ProjectTask({
    required this.title,
    required this.status,
    required this.dueDate,
  });
}

class RecentReport {
  final DateTime reportDate;
  final String userName;
  final String hoursWorked;

  RecentReport({
    required this.reportDate,
    required this.userName,
    required this.hoursWorked,
  });
}
