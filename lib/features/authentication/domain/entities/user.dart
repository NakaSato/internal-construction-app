import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  const User({
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

  /// Legacy getter for backward compatibility
  String get id => userId;

  /// Legacy getter for backward compatibility
  String get name => fullName;

  /// Create a copy of this user with updated values
  User copyWith({
    String? userId,
    String? username,
    String? email,
    String? fullName,
    String? roleName,
    bool? isActive,
    String? profileImageUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create user from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      roleName: json['roleName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert user to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roleName': roleName,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    userId,
    username,
    email,
    fullName,
    roleName,
    isActive,
    profileImageUrl,
    phoneNumber,
    isEmailVerified,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'User(userId: $userId, username: $username, email: $email, fullName: $fullName)';
  }
}
