import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/project.dart';
import '../../application/project_bloc.dart';
import '../../../authorization/presentation/widgets/authorization_widgets.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';

/// Screen for creating new projects with authorization checks
/// Only users with 'projects:create' permission (Admin/Manager) can access this screen
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientInfoController = TextEditingController();

  late ProjectBloc _projectBloc;
  ProjectPriority _selectedPriority = ProjectPriority.medium;
  String _selectedStatus = 'Planning';
  DateTime? _startDate;
  DateTime? _estimatedEndDate;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<ProjectBloc>();
    _initializeDefaultValues();
  }

  void _initializeDefaultValues() {
    // Set default start date to today
    _startDate = DateTime.now();
    // Set default end date to 3 months from now
    _estimatedEndDate = DateTime.now().add(const Duration(days: 90));
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return _buildUnauthenticatedView();
        }

        final user = authState.user;

        return PermissionBuilder(
          user: user,
          resource: 'projects',
          action: 'create',
          fallback: _buildAccessDeniedView(),
          loading: _buildLoadingView(),
          builder: (context, hasPermission) {
            if (!hasPermission) {
              return _buildAccessDeniedView();
            }
            return _buildCreateForm();
          },
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildAccessDeniedView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.error),
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
                'You need Admin or Manager permissions to create projects.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please log in to create projects.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Project'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [IconButton(onPressed: _saveProject, icon: const Icon(Icons.save), tooltip: 'Create Project')],
      ),
      body: BlocProvider.value(
        value: _projectBloc,
        child: BlocListener<ProjectBloc, ProjectState>(
          listener: (context, state) {
            if (state is ProjectOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              // Navigate back or to the new project
              context.pop(true);
            } else if (state is ProjectError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
              );
            }
          },
          child: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              final isLoading = state is ProjectLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      // Project Information Section
                      _buildSectionTitle('Project Information'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _projectNameController,
                        label: 'Project Name *',
                        hint: 'Enter a descriptive project name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Project name is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Project name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe the project scope and objectives',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Project Address *',
                        hint: 'Enter the project location',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Project address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _clientInfoController,
                        label: 'Client Information *',
                        hint: 'Enter client name and contact details',
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
                        label: 'Start Date *',
                        selectedDate: _startDate,
                        onDateSelected: (date) {
                          setState(() {
                            _startDate = date;
                            // Ensure end date is after start date
                            if (_estimatedEndDate != null && _estimatedEndDate!.isBefore(date)) {
                              _estimatedEndDate = date.add(const Duration(days: 30));
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildDateSelector(
                        label: 'Estimated End Date *',
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
                              onPressed: isLoading ? null : () => context.pop(),
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
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Create Project'),
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

  Widget _buildWelcomeCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: theme.colorScheme.onPrimaryContainer, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Create New Project',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details below to create a new project. All required fields are marked with an asterisk (*).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: ProjectPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: _getPriorityColor(priority), shape: BoxShape.circle),
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
    final statuses = ['Planning', 'In Progress', 'On Hold', 'Completed', 'Cancelled'];

    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: _getStatusColorFromString(status), shape: BoxShape.circle),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Future<void> _selectDate(DateTime? currentDate, Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select start date and estimated end date')));
      return;
    }

    if (_estimatedEndDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date cannot be before start date')));
      return;
    }

    // Generate a unique project ID
    final projectId = 'proj_${DateTime.now().millisecondsSinceEpoch}';

    final newProject = Project(
      projectId: projectId,
      projectName: _projectNameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      clientInfo: _clientInfoController.text.trim(),
      priority: _selectedPriority,
      status: _selectedStatus,
      startDate: _startDate!,
      estimatedEndDate: _estimatedEndDate!,
      createdAt: DateTime.now(),
      taskCount: 0,
      completedTaskCount: 0,
    );

    // Convert project to Map for the enhanced API
    final projectData = {
      'name': newProject.name,
      'description': newProject.description,
      'status': newProject.status,
      'priority': newProject.priority.toString().split('.').last,
      'address': newProject.address,
      'clientInfo': newProject.clientInfo,
      'startDate': newProject.startDate.toIso8601String(),
      'estimatedEndDate': newProject.estimatedEndDate.toIso8601String(),
    };

    _projectBloc.add(CreateProjectRequested(projectData: projectData));
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
