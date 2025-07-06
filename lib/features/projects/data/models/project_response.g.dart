// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectResponse _$ProjectResponseFromJson(Map<String, dynamic> json) =>
    ProjectResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ProjectData.fromJson(json['data'] as Map<String, dynamic>),
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProjectResponseToJson(ProjectResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'errors': instance.errors,
    };

ProjectData _$ProjectDataFromJson(Map<String, dynamic> json) => ProjectData(
  items: (json['items'] as List<dynamic>)
      .map((e) => ProjectDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  pageNumber: (json['pageNumber'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$ProjectDataToJson(ProjectData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
  projectId: json['projectId'] as String,
  projectName: json['projectName'] as String,
  address: json['address'] as String,
  clientInfo: json['clientInfo'] as String,
  status: json['status'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  estimatedEndDate: DateTime.parse(json['estimatedEndDate'] as String),
  actualEndDate: json['actualEndDate'] == null
      ? null
      : DateTime.parse(json['actualEndDate'] as String),
  projectManager: json['projectManager'] == null
      ? null
      : UserDto.fromJson(json['projectManager'] as Map<String, dynamic>),
  taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
  completedTaskCount: (json['completedTaskCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'projectName': instance.projectName,
      'address': instance.address,
      'clientInfo': instance.clientInfo,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'estimatedEndDate': instance.estimatedEndDate.toIso8601String(),
      'actualEndDate': instance.actualEndDate?.toIso8601String(),
      'projectManager': instance.projectManager,
      'taskCount': instance.taskCount,
      'completedTaskCount': instance.completedTaskCount,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  userId: json['userId'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  roleName: json['roleName'] as String,
  isActive: json['isActive'] as bool? ?? true,
  profileImageUrl: json['profileImageUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'email': instance.email,
  'fullName': instance.fullName,
  'roleName': instance.roleName,
  'isActive': instance.isActive,
  'profileImageUrl': instance.profileImageUrl,
  'phoneNumber': instance.phoneNumber,
  'isEmailVerified': instance.isEmailVerified,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

ProjectsListRequest _$ProjectsListRequestFromJson(Map<String, dynamic> json) =>
    ProjectsListRequest(
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      managerId: json['managerId'] as String?,
    );

Map<String, dynamic> _$ProjectsListRequestToJson(
  ProjectsListRequest instance,
) => <String, dynamic>{
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'managerId': instance.managerId,
};
