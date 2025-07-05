#!/usr/bin/env dart
// Simple test script to verify error handling behavior
// Run with: dart test_error_handling.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🧪 Testing API Error Handling');
  print('===============================\n');

  // Test 1: 404 Error (Non-existent project)
  await testProjectNotFound();

  // Test 2: 401 Error (No auth token)
  await testUnauthorized();

  // Test 3: Health check (should work)
  await testHealthCheck();
}

Future<void> testProjectNotFound() async {
  print('1️⃣  Testing 404 - Project Not Found');
  try {
    final response = await http.get(
      Uri.parse('https://api-icms.gridtokenx.com/api/projects/550e8400-e29b-41d4-a716-446655440000'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBleGFtcGxlLmNvbSIsImVtYWlsIjoiYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlIjoiQWRtaW4iLCJuYW1lIjoiQWRtaW5pc3RyYXRvciIsInVzZXJJZCI6IjgzZjA1MjNkLTI2ZjUtNGQ3Ny04YjZjLWE4MjIyMjNiMmExYyIsImV4cCI6MTc1MDIzNDU3MX0.BRhiGZfvFxF-sI2zE4nVc2Qqt4jM7kPaFNb80OtBcIQ',
      },
    );

    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');

    if (response.body.isNotEmpty) {
      try {
        final json = jsonDecode(response.body);
        print('   Parsed JSON: $json');

        if (json is Map<String, dynamic>) {
          if (json.containsKey('errors')) {
            print('   Errors field: ${json['errors']}');
          }
          if (json.containsKey('message')) {
            print('   Message field: ${json['message']}');
          }
        }
      } catch (e) {
        print('   Failed to parse JSON: $e');
      }
    }
  } catch (e) {
    print('   Exception: $e');
  }
  print('');
}

Future<void> testUnauthorized() async {
  print('2️⃣  Testing 401 - Unauthorized');
  try {
    final response = await http.get(
      Uri.parse('https://api-icms.gridtokenx.com/api/projects'),
      headers: {
        'Content-Type': 'application/json',
        // No Authorization header
      },
    );

    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');

    if (response.body.isNotEmpty) {
      try {
        final json = jsonDecode(response.body);
        print('   Parsed JSON: $json');
      } catch (e) {
        print('   Failed to parse JSON: $e');
      }
    }
  } catch (e) {
    print('   Exception: $e');
  }
  print('');
}

Future<void> testHealthCheck() async {
  print('3️⃣  Testing Health Check (should work)');
  try {
    final response = await http.get(
      Uri.parse('https://api-icms.gridtokenx.com/health'),
      headers: {'Content-Type': 'application/json'},
    );

    print('   Status: ${response.statusCode}');
    print('   Response: ${response.body}');

    if (response.body.isNotEmpty) {
      try {
        final json = jsonDecode(response.body);
        print('   Parsed JSON: $json');
      } catch (e) {
        print('   Failed to parse JSON: $e');
      }
    }
  } catch (e) {
    print('   Exception: $e');
  }
  print('');
}
