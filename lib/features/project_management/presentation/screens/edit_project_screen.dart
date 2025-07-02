import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/project.dart';
import '../../application/project_bloc.dart';
import '../../../authorization/presentation/widgets/authorization_widgets.dart';
import '../../../authentication/domain/entities/user.dart';

/// Screen for editing project details with authorization checks
class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.project,
    required this.user,
  });

  final Project project;
  final User user;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientInfoController = TextEditingController();

  late EnhancedProjectBloc _projectBloc;
  ProjectPriority _selectedPriority = ProjectPriority.medium;
  String _selectedStatus = 'Planning';
  DateTime? _startDate;
  DateTime? _estimatedEndDate;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<EnhancedProjectBloc>();
    _initializeForm();
  }

  void _initializeForm() {
    _projectNameController.text = widget.project.projectName;
    _descriptionController.text = widget.project.description;
    _addressController.text = widget.project.address;
    _clientInfoController.text = widget.project.clientInfo;
    _selectedPriority = widget.project.priority;
    _selectedStatus = widget.project.status;
    _startDate = widget.project.startDate;
    _estimatedEndDate = widget.project.estimatedEndDate;
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _clientInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedAccessWidget(
      user: widget.user,
      fallback: _buildAccessDeniedView(),
      child: _buildEditForm(),
    );
  }

  Widget _buildAccessDeniedView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need Admin or Manager permissions to edit projects.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            onPressed: _saveProject,
            icon: const Icon(Icons.save),
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _projectBloc,
        child: BlocListener<EnhancedProjectBloc, EnhancedProjectState>(
          listener: (context, state) {
            if (state is EnhancedProjectOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(
                context,
              ).pop(true); // Return true to indicate success
            } else if (state is EnhancedProjectError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
            builder: (context, state) {
              final isLoading = state is EnhancedProjectLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Information Section
                      _buildSectionTitle('Project Information'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _projectNameController,
                        label: 'Project Name',
                        hint: 'Enter project name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Project name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter project description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Enter project address',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _clientInfoController,
                        label: 'Client Information',
                        hint: 'Enter client details',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Client information is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Project Settings Section
                      _buildSectionTitle('Project Settings'),
                      const SizedBox(height: 16),

                      _buildPriorityDropdown(),
                      const SizedBox(height: 16),

                      _buildStatusDropdown(),
                      const SizedBox(height: 24),

                      // Project Timeline Section
                      _buildSectionTitle('Project Timeline'),
                      const SizedBox(height: 16),

                      _buildDateSelector(
                        label: 'Start Date',
                        selectedDate: _startDate,
                        onDateSelected: (date) {
                          setState(() {
                            _startDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildDateSelector(
                        label: 'Estimated End Date',
                        selectedDate: _estimatedEndDate,
                        onDateSelected: (date) {
                          setState(() {
                            _estimatedEndDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: isLoading ? null : _saveProject,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<ProjectPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: ProjectPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(priority.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildStatusDropdown() {
    final statusOptions = [
      'Planning',
      'In Progress',
      'On Hold',
      'Completed',
      'Cancelled',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColorFromString(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(selectedDate, onDateSelected),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null ? _formatDate(selectedDate) : 'Select $label',
          style: TextStyle(
            color: selectedDate != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    DateTime? currentDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _saveProject() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _estimatedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date and estimated end date'),
        ),
      );
      return;
    }

    if (_estimatedEndDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    final updatedProject = widget.project.copyWith(
      projectName: _projectNameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      clientInfo: _clientInfoController.text.trim(),
      priority: _selectedPriority,
      status: _selectedStatus,
      startDate: _startDate!,
      estimatedEndDate: _estimatedEndDate!,
      updatedAt: DateTime.now(),
    );

    _projectBloc.add(
      UpdateProjectRequested(
        projectId: widget.project.projectId,
        projectData: {
          'projectName': updatedProject.projectName,
          'description': updatedProject.description,
          'address': updatedProject.address,
          'clientInfo': updatedProject.clientInfo,
          'priority': updatedProject.priority.toString(),
          'status': updatedProject.status,
          'startDate': updatedProject.startDate.toIso8601String(),
          'estimatedEndDate': updatedProject.estimatedEndDate.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  Color _getPriorityColor(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.low:
        return Colors.blue;
      case ProjectPriority.medium:
        return Colors.orange;
      case ProjectPriority.high:
        return Colors.red;
      case ProjectPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getStatusColorFromString(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.grey;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'on hold':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
