#!/usr/bin/env dart
// Simple test to verify environment configuration

import 'dart:io';

void main() {
  print('🔧 Environment Configuration Test');
  print('==================================');

  // Check if .env file exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    exit(1);
  }

  print('✅ .env file exists');

  // Read .env file content
  final envContent = envFile.readAsStringSync();
  print('\n📄 .env file contents:');
  print(envContent);

  // Check for API_BASE_URL
  final lines = envContent.split('\n');
  String? apiUrl;

  for (final line in lines) {
    if (line.startsWith('API_BASE_URL=')) {
      apiUrl = line.split('=')[1];
      break;
    }
  }

  if (apiUrl != null && apiUrl.isNotEmpty) {
    print('✅ API_BASE_URL found: $apiUrl');

    if (apiUrl.contains('localhost:5002')) {
      print('✅ Correctly configured for localhost:5002');
    } else {
      print('⚠️  Not configured for localhost:5002');
    }
  } else {
    print('❌ API_BASE_URL not found in .env file');
    exit(1);
  }

  print('\n==================================');
  print('✅ Configuration test completed successfully!');
}
