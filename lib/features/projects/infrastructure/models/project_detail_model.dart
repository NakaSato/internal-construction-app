import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project_detail.dart';

part 'project_detail_model.g.dart';

@JsonSerializable()
class ProjectDetailModel extends ProjectDetail {
  const ProjectDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.location,
    required super.budget,
    required super.actualCost,
    required super.totalTasks,
    required super.completedTasks,
    required super.progressPercentage,
    required super.tasks,
    required super.recentReports,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      budget: (json['budget'] as num).toDouble(),
      actualCost: (json['actualCost'] as num).toDouble(),
      totalTasks: json['totalTasks'] as int,
      completedTasks: json['completedTasks'] as int,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      tasks: (json['tasks'] as List<dynamic>)
          .map(
            (task) => ProjectTaskModel.fromJson(task as Map<String, dynamic>),
          )
          .toList(),
      recentReports: (json['recentReports'] as List<dynamic>)
          .map(
            (report) =>
                RecentReportModel.fromJson(report as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$ProjectDetailModelToJson(this);
}

@JsonSerializable()
class ProjectTaskModel extends ProjectTask {
  const ProjectTaskModel({
    required super.id,
    required super.title,
    required super.status,
    required super.dueDate,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$ProjectTaskModelToJson(this);
}

@JsonSerializable()
class RecentReportModel extends RecentReport {
  const RecentReportModel({
    required super.id,
    required super.reportDate,
    required super.userName,
    required super.hoursWorked,
  });

  factory RecentReportModel.fromJson(Map<String, dynamic> json) {
    return RecentReportModel(
      id: json['id'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      userName: json['userName'] as String,
      hoursWorked: (json['hoursWorked'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => _$RecentReportModelToJson(this);
}
