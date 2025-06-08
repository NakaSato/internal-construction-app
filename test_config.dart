#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple script to verify API configuration without running Flutter UI
Future<void> main() async {
  print('🔧 API Configuration Test Script');
  print('===============================');

  try {
    // Load environment file
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');

    // Check API_BASE_URL
    final apiUrl = dotenv.env['API_BASE_URL'];
    print('📡 API_BASE_URL: ${apiUrl ?? 'NOT SET'}');

    // Check other environment variables
    final debugMode = dotenv.env['DEBUG_MODE'];
    print('🐛 DEBUG_MODE: ${debugMode ?? 'NOT SET'}');

    // Validate localhost:5002 configuration
    if (apiUrl != null && apiUrl.contains('localhost:5002')) {
      print('✅ API URL correctly configured for localhost:5002');
    } else {
      print('⚠️  API URL is not configured for localhost:5002');
      print('   Current value: $apiUrl');
      print('   Expected: http://localhost:5002/');
    }

    // Test if the URL is reachable (optional)
    if (apiUrl != null) {
      try {
        final uri = Uri.parse(apiUrl);
        print('🌐 Testing connectivity to ${uri.host}:${uri.port}...');

        final socket = await Socket.connect(
          uri.host,
          uri.port,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        print('✅ Server is reachable at ${uri.host}:${uri.port}');
      } catch (e) {
        print('❌ Server not reachable: $e');
        print('   Make sure your backend server is running on localhost:5002');
      }
    }
  } catch (e) {
    print('❌ Error loading configuration: $e');
    exit(1);
  }

  print('\n===============================');
  print('Configuration test completed!');
}
