import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project.dart';
import '../../../authentication/domain/entities/user.dart';

part 'project_response.g.dart';

/// Response model for project API calls
@JsonSerializable()
class ProjectResponse {
  const ProjectResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final ProjectData data;
  final List<String> errors;

  factory ProjectResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectResponseToJson(this);
}

/// Project data container for paginated results
@JsonSerializable()
class ProjectData {
  const ProjectData({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ProjectDto> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  factory ProjectData.fromJson(Map<String, dynamic> json) =>
      _$ProjectDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDataToJson(this);
}

/// Project DTO from API
@JsonSerializable()
class ProjectDto {
  const ProjectDto({
    required this.projectId,
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.status,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    this.projectManager,
    this.taskCount = 0,
    this.completedTaskCount = 0,
  });

  final String projectId;
  final String projectName;
  final String address;
  final String clientInfo;
  final String status;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;
  final UserDto? projectManager;
  final int taskCount;
  final int completedTaskCount;

  /// Convert to domain entity
  Project toEntity() {
    return Project(
      projectId: projectId,
      projectName: projectName,
      address: address,
      clientInfo: clientInfo,
      status: status,
      startDate: startDate,
      estimatedEndDate: estimatedEndDate,
      actualEndDate: actualEndDate,
      projectManager: projectManager?.toEntity(),
      taskCount: taskCount,
      completedTaskCount: completedTaskCount,
    );
  }

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}

/// User DTO from API (simplified for project context)
@JsonSerializable()
class UserDto {
  const UserDto({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roleName,
    this.isActive = true,
    this.profileImageUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String username;
  final String email;
  final String fullName;
  final String roleName;
  final bool isActive;
  final String? profileImageUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Convert to domain entity
  User toEntity() {
    return User(
      userId: userId,
      username: username,
      email: email,
      fullName: fullName,
      roleName: roleName,
      isActive: isActive,
      profileImageUrl: profileImageUrl,
      phoneNumber: phoneNumber,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

/// Projects list request parameters
@JsonSerializable()
class ProjectsListRequest {
  const ProjectsListRequest({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.managerId,
  });

  final int pageNumber;
  final int pageSize;
  final String? managerId;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (managerId != null) {
      params['managerId'] = managerId;
    }

    return params;
  }

  factory ProjectsListRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectsListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectsListRequestToJson(this);
}
