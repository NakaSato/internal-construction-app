/// Response model for single project API calls
/// Simplified version without code generation for now
class SingleProjectResponse {
  const SingleProjectResponse({required this.success, required this.message, this.data, this.errors = const []});

  final bool success;
  final String message;
  final Map<String, dynamic>? data; // Make data nullable
  final List<String> errors;

  factory SingleProjectResponse.fromJson(Map<String, dynamic> json) {
    return SingleProjectResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] as Map<String, dynamic>?, // Allow null
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e?.toString() ?? '').toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data, // Keep null if it's null
    'errors': errors,
  };
}
