/// Authentication response models for API integration

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final UserDto? user;

  const LoginResponse({this.token, this.refreshToken, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
    };
  }
}

/// User DTO model for API responses
class UserDto {
  final String userId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? roleName;
  final bool isActive;

  const UserDto({
    required this.userId,
    this.username,
    this.email,
    this.fullName,
    this.roleName,
    this.isActive = true,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'] ?? json['id'] ?? '',
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      roleName: json['roleName'] as String?,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roleName': roleName,
      'isActive': isActive,
    };
  }
}

/// Login request model
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

/// Register request model
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final int roleId;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'roleId': roleId,
    };
  }
}
