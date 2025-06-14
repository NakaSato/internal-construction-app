/// Extension methods for String
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Convert to title case
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Validate email for form validation
  String? validateEmail() {
    if (isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail) {
      return 'Please enter a valid email format';
    }
    return null;
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
}

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Format as 'MMM dd, yyyy'
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} ${day.toString().padLeft(2, '0')}, $year';
  }

  /// Format as 'HH:mm'
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }
}

/// Extension methods for List
extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if list is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Get first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Add element if condition is true
  void addIf(bool condition, T element) {
    if (condition) add(element);
  }

  /// Add all elements if condition is true
  void addAllIf(bool condition, Iterable<T> elements) {
    if (condition) addAll(elements);
  }
}
