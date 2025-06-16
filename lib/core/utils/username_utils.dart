/// Utility functions for username generation and validation
class UsernameUtils {
  /// Generate a valid username from an email address
  /// Ensures the username meets API requirements (3-50 characters)
  static String generateUsernameFromEmail(String email) {
    // Extract the part before @ symbol
    String username = email.split('@').first;

    // If username is too short, enhance it to meet minimum length
    if (username.length < 3) {
      // Try different strategies to create a valid username
      username = '${username}user'; // e.g., "ab" becomes "abuser"

      // If still too short, pad with numbers
      while (username.length < 3) {
        username += '1';
      }
    }

    // Ensure username doesn't exceed 50 characters
    if (username.length > 50) {
      username = username.substring(0, 50);
    }

    // Remove any invalid characters (keep only alphanumeric and underscore)
    username = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    // If we removed characters and now it's too short, pad again
    if (username.length < 3) {
      username = '${username}user123'.substring(0, 3);
    }

    return username;
  }

  /// Validate if a username meets the API requirements
  static bool isValidUsername(String username) {
    return username.length >= 3 &&
        username.length <= 50 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  /// Get validation error message for invalid username
  static String? getValidationError(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 50) {
      return 'Username must be no more than 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null; // Valid username
  }
}
