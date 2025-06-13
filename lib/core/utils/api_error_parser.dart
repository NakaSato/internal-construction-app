import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiErrorParser {
  static String parseError(DioException error) {
    try {
      if (kDebugMode) {
        debugPrint('=== ApiErrorParser Debug ===');
        debugPrint('Status Code: ${error.response?.statusCode}');
        debugPrint('Response Type: ${error.response?.data.runtimeType}');
        debugPrint('Raw Response: ${error.response?.data}');
        debugPrint('============================');
      }

      if (error.response?.statusCode == 400) {
        final responseData = error.response?.data;

        if (responseData is String) {
          try {
            final jsonData = json.decode(responseData);
            return _extractValidationErrors(jsonData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to parse JSON string: $e');
            }
            return responseData.isNotEmpty
                ? responseData
                : _getDefaultErrorMessage(400);
          }
        } else if (responseData is Map<String, dynamic>) {
          return _extractValidationErrors(responseData);
        }
      }

      return _getDefaultErrorMessage(error.response?.statusCode);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ApiErrorParser exception: $e');
      }
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _extractValidationErrors(Map<String, dynamic> responseData) {
    if (kDebugMode) {
      debugPrint('=== Extracting Validation Errors ===');
      debugPrint('Response Data Keys: ${responseData.keys.toList()}');
      debugPrint('Full Response: $responseData');
    }

    // Handle ASP.NET Core validation error format
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'];
      final errorMessages = <String>[];

      if (kDebugMode) {
        debugPrint('Errors field type: ${errors.runtimeType}');
        debugPrint('Errors content: $errors');
      }

      if (errors is Map<String, dynamic>) {
        // Handle field-specific validation errors
        errors.forEach((field, messages) {
          if (messages is List) {
            for (final message in messages) {
              errorMessages.add(message.toString());
            }
          } else if (messages is String) {
            errorMessages.add(messages);
          }
        });
      } else if (errors is List) {
        // Handle general error list
        for (final error in errors) {
          errorMessages.add(error.toString());
        }
      }

      if (errorMessages.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Extracted error messages: $errorMessages');
        }

        // Format password errors specially for better UX
        if (errorMessages.length == 1 &&
            isPasswordValidationError(errorMessages.first)) {
          return formatPasswordValidationError(errorMessages.first);
        }

        // Join multiple errors with bullet points for better readability
        if (errorMessages.length == 1) {
          return errorMessages.first;
        } else {
          return errorMessages.map((msg) => '• $msg').join('\n');
        }
      }
    }

    // Handle ASP.NET Core title/detail format
    if (responseData.containsKey('title')) {
      final title = responseData['title'] as String;
      if (kDebugMode) {
        debugPrint('Using title as error: $title');
      }
      return title;
    }

    // Handle detail field
    if (responseData.containsKey('detail')) {
      final detail = responseData['detail'] as String;
      if (kDebugMode) {
        debugPrint('Using detail as error: $detail');
      }
      return detail;
    }

    if (kDebugMode) {
      debugPrint('No recognizable error format found, using default message');
    }
    return 'Validation failed. Please check your input.';
  }

  static String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please check your credentials.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Format password validation errors to be more user-friendly
  static String formatPasswordValidationError(String error) {
    if (error.toLowerCase().contains('password must contain')) {
      // Extract the requirements and format them nicely
      if (error.contains('uppercase') ||
          error.contains('lowercase') ||
          error.contains('digit') ||
          error.contains('special character')) {
        return 'Password requirements:\n'
            '• At least one uppercase letter (A-Z)\n'
            '• At least one lowercase letter (a-z)\n'
            '• At least one digit (0-9)\n'
            '• At least one special character (!@#\$%^&*)';
      }
    }
    return error;
  }

  /// Check if the error is a password validation error
  static bool isPasswordValidationError(String error) {
    return error.toLowerCase().contains('password must contain') ||
        error.toLowerCase().contains('uppercase') ||
        error.toLowerCase().contains('lowercase') ||
        error.toLowerCase().contains('digit') ||
        error.toLowerCase().contains('special character');
  }
}
