import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable form components for daily reports
class ReportFormComponents {
  /// Creates a section title widget
  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  /// Creates a reusable text field widget
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: suffixIcon,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  /// Creates a project dropdown selector
  static Widget buildProjectDropdown({
    required String? selectedProjectId,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
    List<Map<String, String>>? projects,
  }) {
    // Default projects for demo - in real app, these would come from API
    final defaultProjects =
        projects ??
        [
          {'id': 'proj-001', 'name': 'Solar Installation Alpha'},
          {'id': 'proj-002', 'name': 'Commercial Rooftop Retrofit'},
          {'id': 'proj-003', 'name': 'Residential Solar Array'},
        ];

    return DropdownButtonFormField<String>(
      value: defaultProjects.any((p) => p['id'] == selectedProjectId) ? selectedProjectId : null,
      decoration: InputDecoration(
        labelText: 'Project',
        hintText: 'Select a project',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: defaultProjects.map((project) {
        return DropdownMenuItem<String>(value: project['id'], child: Text(project['name']!));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  /// Creates a date picker widget
  static Widget buildDatePicker({
    required BuildContext context,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(context, selectedDate, onDateSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Report Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMMM d, yyyy').format(selectedDate), style: Theme.of(context).textTheme.bodyLarge),
            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// Creates a location field widget
  static Widget buildLocationField({required TextEditingController controller, required VoidCallback onRefresh}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Current Location',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh, tooltip: 'Refresh Location'),
      ),
    );
  }

  /// Creates a submit button widget
  static Widget buildSubmitButton({
    required BuildContext context,
    required bool isEditing,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(isEditing ? Icons.save : Icons.send),
        label: Text(isEditing ? 'Save Changes' : 'Submit Report'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// Helper method to show date picker
  static Future<void> _selectDate(BuildContext context, DateTime currentDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != currentDate) {
      onDateSelected(picked);
    }
  }
}

/// Form validators for daily report fields
class ReportFormValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateHours(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter hours worked';
    }
    try {
      final hours = double.parse(value);
      if (hours <= 0 || hours > 24) {
        return 'Please enter a valid number between 0 and 24';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validateProject(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a project';
    }
    return null;
  }
}
