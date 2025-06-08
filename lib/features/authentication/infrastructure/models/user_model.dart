import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model for User entity
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String username,
    required String email,
    required String fullName,
    required String roleName,
    @Default(true) bool isActive,
    String? profileImageUrl,
    String? phoneNumber,
    @Default(false) bool isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create model from domain entity
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      fullName: entity.fullName,
      roleName: entity.roleName,
      isActive: entity.isActive,
      profileImageUrl: entity.profileImageUrl,
      phoneNumber: entity.phoneNumber,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Extension to convert between model and entity
extension UserModelX on UserModel {
  /// Convert model to domain entity
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
}

/// Extension to convert from entity to model
extension UserX on User {
  /// Convert domain entity to model
  UserModel toModel() {
    return UserModel.fromEntity(this);
  }
}
