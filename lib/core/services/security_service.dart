import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'token_service.dart';
import '../storage/secure_storage_service.dart';

/// Service responsible for security operations, input validation, and threat protection.
///
/// This service implements security best practices including:
/// - Input sanitization and validation
/// - Rate limiting for authentication attempts
/// - Session security monitoring
/// - Data encryption helpers
/// - Security event logging
/// - Protection against common attacks (XSS, injection, etc.)
@LazySingleton()
class SecurityService {
  const SecurityService(this._tokenService, this._secureStorage);

  final TokenService _tokenService;
  final SecureStorageService _secureStorage;

  // Security configuration constants
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _sessionTimeoutMinutes = 60;
  static const int _minPasswordLength = 8;

  // Keys for security storage
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lastLoginAttemptKey = 'last_login_attempt';
  static const String _lockoutUntilKey = 'lockout_until';
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionStartKey = 'session_start';
  static const String _securityEventsKey = 'security_events';

  /// Validate password strength according to security policy
  PasswordValidationResult validatePassword(String password) {
    final errors = <String>[];

    if (password.length < _minPasswordLength) {
      errors.add('Password must be at least $_minPasswordLength characters long');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number');
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Password must contain at least one special character');
    }

    // Check for common weak patterns
    if (RegExp(r'^(.)\1+$').hasMatch(password)) {
      errors.add('Password cannot consist of repeated characters');
    }

    if (RegExp(r'(012|123|234|345|456|567|678|789|890)').hasMatch(password)) {
      errors.add('Password cannot contain sequential numbers');
    }

    if (RegExp(
      r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
      caseSensitive: false,
    ).hasMatch(password)) {
      errors.add('Password cannot contain sequential letters');
    }

    final strength = _calculatePasswordStrength(password);

    return PasswordValidationResult(
      isValid: errors.isEmpty && strength >= PasswordStrength.medium,
      errors: errors,
      strength: strength,
    );
  }

  /// Calculate password strength score
  PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;

    // Length bonus
    score += (password.length - 8) * 2;

    // Character variety bonus
    if (RegExp(r'[a-z]').hasMatch(password)) score += 5;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 5;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 5;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 10;

    // Uniqueness bonus
    final uniqueChars = password.split('').toSet().length;
    score += uniqueChars;

    if (score < 20) return PasswordStrength.weak;
    if (score < 40) return PasswordStrength.medium;
    if (score < 60) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// Sanitize input to prevent XSS and injection attacks
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('/', '&#x2F;')
        .trim();
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate username format
  bool isValidUsername(String username) {
    // Username must be 3-20 characters, alphanumeric plus underscore
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  /// Check if account is currently locked due to failed login attempts
  Future<bool> isAccountLocked() async {
    final lockoutUntilStr = await _secureStorage.read(key: _lockoutUntilKey);
    if (lockoutUntilStr == null) return false;

    final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
    if (lockoutUntil == null) return false;

    return DateTime.now().isBefore(lockoutUntil);
  }

  /// Record a failed login attempt
  Future<void> recordFailedLoginAttempt() async {
    final attemptsStr = await _secureStorage.read(key: _loginAttemptsKey) ?? '0';
    final attempts = int.tryParse(attemptsStr) ?? 0;
    final newAttempts = attempts + 1;

    await _secureStorage.write(key: _loginAttemptsKey, value: newAttempts.toString());
    await _secureStorage.write(key: _lastLoginAttemptKey, value: DateTime.now().toIso8601String());

    if (newAttempts >= _maxLoginAttempts) {
      final lockoutUntil = DateTime.now().add(Duration(minutes: _lockoutDurationMinutes));
      await _secureStorage.write(key: _lockoutUntilKey, value: lockoutUntil.toIso8601String());

      await _logSecurityEvent(
        SecurityEvent(
          type: SecurityEventType.accountLocked,
          message: 'Account locked due to excessive failed login attempts',
          timestamp: DateTime.now(),
          severity: SecuritySeverity.high,
        ),
      );
    }
  }

  /// Reset login attempts counter (call on successful login)
  Future<void> resetLoginAttempts() async {
    await Future.wait([
      _secureStorage.delete(key: _loginAttemptsKey),
      _secureStorage.delete(key: _lastLoginAttemptKey),
      _secureStorage.delete(key: _lockoutUntilKey),
    ]);
  }

  /// Start a new security session
  Future<void> startSecuritySession() async {
    final now = DateTime.now();
    await Future.wait([
      _secureStorage.write(key: _sessionStartKey, value: now.toIso8601String()),
      _secureStorage.write(key: _lastActivityKey, value: now.toIso8601String()),
    ]);

    await _logSecurityEvent(
      SecurityEvent(
        type: SecurityEventType.sessionStarted,
        message: 'Security session started',
        timestamp: now,
        severity: SecuritySeverity.info,
      ),
    );
  }

  /// Update last activity timestamp
  Future<void> updateLastActivity() async {
    await _secureStorage.write(key: _lastActivityKey, value: DateTime.now().toIso8601String());
  }

  /// Check if the current session has timed out
  Future<bool> isSessionTimedOut() async {
    final lastActivityStr = await _secureStorage.read(key: _lastActivityKey);
    if (lastActivityStr == null) return true;

    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return true;

    final sessionTimeout = Duration(minutes: _sessionTimeoutMinutes);
    return DateTime.now().difference(lastActivity) > sessionTimeout;
  }

  /// End the security session and clean up
  Future<void> endSecuritySession() async {
    await Future.wait([_secureStorage.delete(key: _sessionStartKey), _secureStorage.delete(key: _lastActivityKey)]);

    await _logSecurityEvent(
      SecurityEvent(
        type: SecurityEventType.sessionEnded,
        message: 'Security session ended',
        timestamp: DateTime.now(),
        severity: SecuritySeverity.info,
      ),
    );
  }

  /// Generate a secure random string for CSRF tokens, etc.
  String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Hash sensitive data using SHA-256
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data against its hash
  bool verifyHash(String data, String hash) {
    return hashData(data) == hash;
  }

  /// Log security events for monitoring and audit
  Future<void> _logSecurityEvent(SecurityEvent event) async {
    try {
      // In production, you might want to send this to a logging service
      if (kDebugMode) {
        print('Security Event: ${event.type.name} - ${event.message}');
      }

      // Store locally for audit trail
      final eventsJson = await _secureStorage.read(key: _securityEventsKey) ?? '[]';
      final events = List<Map<String, dynamic>>.from(json.decode(eventsJson));

      events.add(event.toJson());

      // Keep only last 100 events to avoid storage bloat
      if (events.length > 100) {
        events.removeRange(0, events.length - 100);
      }

      await _secureStorage.write(key: _securityEventsKey, value: json.encode(events));
    } catch (e) {
      // Fail silently to avoid disrupting app flow
      if (kDebugMode) {
        print('Failed to log security event: $e');
      }
    }
  }

  /// Get security events for audit
  Future<List<SecurityEvent>> getSecurityEvents() async {
    try {
      final eventsJson = await _secureStorage.read(key: _securityEventsKey) ?? '[]';
      final events = List<Map<String, dynamic>>.from(json.decode(eventsJson));
      return events.map((e) => SecurityEvent.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all security events
  Future<void> clearSecurityEvents() async {
    await _secureStorage.delete(key: _securityEventsKey);
  }

  /// Validate app integrity (basic check)
  Future<bool> validateAppIntegrity() async {
    // In a production app, you might check:
    // - App signature
    // - Root/jailbreak detection
    // - Debugger detection
    // - Certificate pinning verification

    // For now, just basic checks
    return !kDebugMode; // Returns false in debug mode, true in release
  }

  /// Check if device is compromised (basic check)
  Future<SecurityRiskLevel> assessDeviceRisk() async {
    var riskLevel = SecurityRiskLevel.low;

    // Check if running in debug mode
    if (kDebugMode) {
      riskLevel = SecurityRiskLevel.medium;
    }

    // Additional checks could include:
    // - Root/jailbreak detection
    // - Malware scanner results
    // - Device encryption status
    // - Screen recording detection

    return riskLevel;
  }

  /// Secure logout with comprehensive cleanup
  Future<void> secureLogout() async {
    await Future.wait([
      _tokenService.logout(notifyServer: true),
      endSecuritySession(),
      resetLoginAttempts(),
      clearSecurityEvents(),
    ]);

    await _logSecurityEvent(
      SecurityEvent(
        type: SecurityEventType.logout,
        message: 'Secure logout completed',
        timestamp: DateTime.now(),
        severity: SecuritySeverity.info,
      ),
    );
  }
}

/// Password validation result
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final PasswordStrength strength;

  const PasswordValidationResult({required this.isValid, required this.errors, required this.strength});
}

/// Password strength levels
enum PasswordStrength {
  weak(0),
  medium(1),
  strong(2),
  veryStrong(3);

  const PasswordStrength(this.value);
  final int value;

  bool operator >=(PasswordStrength other) => value >= other.value;
  bool operator >(PasswordStrength other) => value > other.value;
  bool operator <=(PasswordStrength other) => value <= other.value;
  bool operator <(PasswordStrength other) => value < other.value;
}

/// Security event types
enum SecurityEventType {
  login,
  logout,
  sessionStarted,
  sessionEnded,
  sessionTimeout,
  accountLocked,
  passwordChanged,
  suspiciousActivity,
  authenticationFailed,
}

/// Security severity levels
enum SecuritySeverity { info, low, medium, high, critical }

/// Security risk assessment levels
enum SecurityRiskLevel { low, medium, high, critical }

/// Security event for logging and monitoring
class SecurityEvent {
  final SecurityEventType type;
  final String message;
  final DateTime timestamp;
  final SecuritySeverity severity;
  final Map<String, dynamic>? metadata;

  const SecurityEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'metadata': metadata,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      type: SecurityEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SecurityEventType.suspiciousActivity,
      ),
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      severity: SecuritySeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecuritySeverity.info,
      ),
      metadata: json['metadata'],
    );
  }
}
