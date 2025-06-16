import 'package:equatable/equatable.dart';

class ProjectDetail extends Equatable {
  const ProjectDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.budget,
    required this.actualCost,
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercentage,
    required this.tasks,
    required this.recentReports,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final double budget;
  final double actualCost;
  final int totalTasks;
  final int completedTasks;
  final double progressPercentage;
  final List<ProjectTask> tasks;
  final List<RecentReport> recentReports;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    startDate,
    endDate,
    location,
    budget,
    actualCost,
    totalTasks,
    completedTasks,
    progressPercentage,
    tasks,
    recentReports,
    createdAt,
    updatedAt,
  ];
}

class ProjectTask extends Equatable {
  const ProjectTask({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
  });

  final String id;
  final String title;
  final String status;
  final DateTime dueDate;

  @override
  List<Object?> get props => [id, title, status, dueDate];
}

class RecentReport extends Equatable {
  const RecentReport({
    required this.id,
    required this.reportDate,
    required this.userName,
    required this.hoursWorked,
  });

  final String id;
  final DateTime reportDate;
  final String userName;
  final double hoursWorked;

  @override
  List<Object?> get props => [id, reportDate, userName, hoursWorked];
}
