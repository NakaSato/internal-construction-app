import 'package:equatable/equatable.dart';

/// Data transfer object for project information
class ProjectDto extends Equatable {
  const ProjectDto({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.managerId,
    required this.budget,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.completionPercentage,
    this.teamMembers,
    this.tasks,
  });

  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String managerId;
  final double budget;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clientName;
  final double? completionPercentage;
  final List<String>? teamMembers;
  final List<String>? tasks;

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      managerId: json['manager_id'] as String,
      budget: (json['budget'] as num).toDouble(),
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clientName: json['client_name'] as String?,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
      teamMembers: (json['team_members'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'manager_id': managerId,
      'budget': budget,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (clientName != null) 'client_name': clientName,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (teamMembers != null) 'team_members': teamMembers,
      if (tasks != null) 'tasks': tasks,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    startDate,
    endDate,
    status,
    managerId,
    budget,
    location,
    createdAt,
    updatedAt,
    clientName,
    completionPercentage,
    teamMembers,
    tasks,
  ];
}

/// Request model for creating a new project
class CreateProjectRequest extends Equatable {
  const CreateProjectRequest({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.managerId,
    required this.budget,
    required this.location,
    this.clientName,
    this.teamMembers,
  });

  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String managerId;
  final double budget;
  final String location;
  final String? clientName;
  final List<String>? teamMembers;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'manager_id': managerId,
      'budget': budget,
      'location': location,
      if (clientName != null) 'client_name': clientName,
      if (teamMembers != null) 'team_members': teamMembers,
    };
  }

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    managerId,
    budget,
    location,
    clientName,
    teamMembers,
  ];
}

/// Request model for updating an existing project
class UpdateProjectRequest extends Equatable {
  const UpdateProjectRequest({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.managerId,
    required this.budget,
    required this.location,
    required this.status,
    this.clientName,
    this.completionPercentage,
    this.teamMembers,
  });

  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String managerId;
  final double budget;
  final String location;
  final String status;
  final String? clientName;
  final double? completionPercentage;
  final List<String>? teamMembers;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'manager_id': managerId,
      'budget': budget,
      'location': location,
      'status': status,
      if (clientName != null) 'client_name': clientName,
      if (completionPercentage != null)
        'completion_percentage': completionPercentage,
      if (teamMembers != null) 'team_members': teamMembers,
    };
  }

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    managerId,
    budget,
    location,
    status,
    clientName,
    completionPercentage,
    teamMembers,
  ];
}

/// Request model for partially updating a project
class PatchProjectRequest extends Equatable {
  const PatchProjectRequest({
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.managerId,
    this.budget,
    this.location,
    this.status,
    this.clientName,
    this.completionPercentage,
    this.teamMembers,
  });

  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? managerId;
  final double? budget;
  final String? location;
  final String? status;
  final String? clientName;
  final double? completionPercentage;
  final List<String>? teamMembers;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (startDate != null) json['start_date'] = startDate!.toIso8601String();
    if (endDate != null) json['end_date'] = endDate!.toIso8601String();
    if (managerId != null) json['manager_id'] = managerId;
    if (budget != null) json['budget'] = budget;
    if (location != null) json['location'] = location;
    if (status != null) json['status'] = status;
    if (clientName != null) json['client_name'] = clientName;
    if (completionPercentage != null)
      json['completion_percentage'] = completionPercentage;
    if (teamMembers != null) json['team_members'] = teamMembers;
    return json;
  }

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    managerId,
    budget,
    location,
    status,
    clientName,
    completionPercentage,
    teamMembers,
  ];
}

/// Data transfer object for project status information
class ProjectStatusDto extends Equatable {
  const ProjectStatusDto({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProjectStatusDto.fromJson(Map<String, dynamic> json) {
    return ProjectStatusDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    isActive,
    createdAt,
    updatedAt,
  ];
}

/// Data transfer object for project statistics
class ProjectStatisticsDto extends Equatable {
  const ProjectStatisticsDto({
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.overdueProjects,
    required this.totalBudget,
    required this.spentBudget,
    required this.averageCompletionPercentage,
    this.projectsByStatus,
    this.monthlyProgress,
  });

  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final int overdueProjects;
  final double totalBudget;
  final double spentBudget;
  final double averageCompletionPercentage;
  final Map<String, int>? projectsByStatus;
  final Map<String, double>? monthlyProgress;

  factory ProjectStatisticsDto.fromJson(Map<String, dynamic> json) {
    return ProjectStatisticsDto(
      totalProjects: json['total_projects'] as int,
      activeProjects: json['active_projects'] as int,
      completedProjects: json['completed_projects'] as int,
      overdueProjects: json['overdue_projects'] as int,
      totalBudget: (json['total_budget'] as num).toDouble(),
      spentBudget: (json['spent_budget'] as num).toDouble(),
      averageCompletionPercentage:
          (json['average_completion_percentage'] as num).toDouble(),
      projectsByStatus: (json['projects_by_status'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int)),
      monthlyProgress: (json['monthly_progress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_projects': totalProjects,
      'active_projects': activeProjects,
      'completed_projects': completedProjects,
      'overdue_projects': overdueProjects,
      'total_budget': totalBudget,
      'spent_budget': spentBudget,
      'average_completion_percentage': averageCompletionPercentage,
      if (projectsByStatus != null) 'projects_by_status': projectsByStatus,
      if (monthlyProgress != null) 'monthly_progress': monthlyProgress,
    };
  }

  @override
  List<Object?> get props => [
    totalProjects,
    activeProjects,
    completedProjects,
    overdueProjects,
    totalBudget,
    spentBudget,
    averageCompletionPercentage,
    projectsByStatus,
    monthlyProgress,
  ];
}

/// Data transfer object for team member information
class TeamMemberDto extends Equatable {
  const TeamMemberDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.phone,
    this.avatar,
    this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;
  final String? phone;
  final String? avatar;
  final bool? isActive;

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
      if (isActive != null) 'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    joinedAt,
    phone,
    avatar,
    isActive,
  ];
}
