import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart';

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';

/// Screen for creating and editing daily reports
class CreateDailyReportScreen extends StatefulWidget {
  final DailyReport? report;

  const CreateDailyReportScreen({super.key, this.report});

  @override
  State<CreateDailyReportScreen> createState() =>
      _CreateDailyReportScreenState();
}

class _CreateDailyReportScreenState extends State<CreateDailyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _workDescriptionController = TextEditingController();
  final _hoursWorkedController = TextEditingController();
  final _weatherController = TextEditingController();
  final _safetyController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedProjectId;
  final List<XFile> _images = [];
  LocationData? _locationData;
  bool _isLoading = false;
  bool _isSavingDraft = false;
  bool _isProcessingImages = false;

  final _uuid = const Uuid();
  final _imagePicker = ImagePicker();
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _getLocation();
  }

  @override
  void dispose() {
    _projectController.dispose();
    _workDescriptionController.dispose();
    _hoursWorkedController.dispose();
    _weatherController.dispose();
    _safetyController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.report != null) {
      // Editing existing report
      final report = widget.report!;

      _selectedDate = report.reportDate;
      _selectedProjectId = report.projectId;
      _projectController.text = report.project?.projectName ?? '';
      _safetyController.text = report.safetyNotes;
      _weatherController.text = report.weatherConditions;
      _notesController.text = report.overallNotes;

      // Initialize with work progress items
      if (report.workProgressItems.isNotEmpty) {
        final firstItem = report.workProgressItems.first;
        _workDescriptionController.text = firstItem.taskDescription;
        _hoursWorkedController.text = firstItem.hoursWorked.toString();
      }

      // Location would normally be fetched from API data
      _locationController.text =
          report.project?.address ?? 'Location unavailable';
    } else {
      // New report defaults
      _safetyController.text = 'None';
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      final locationData = await _location.getLocation();
      setState(() {
        _locationData = locationData;
        _locationController.text =
            'Lat: ${locationData.latitude?.toStringAsFixed(5)}, '
            'Long: ${locationData.longitude?.toStringAsFixed(5)}';
      });
    } catch (e) {
      _locationController.text = 'Could not determine location';
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _locationController.text = 'Obtaining location...';
    });
    await _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.report != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Report' : 'Create Report'),
        actions: [
          if (!isEditing)
            TextButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save),
              label: const Text('Save Draft'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
        ],
      ),
      body: BlocConsumer<DailyReportsCubit, DailyReportsState>(
        listenWhen: (previous, current) =>
            current is DailyReportOperationSuccess ||
            current is DailyReportOperationError ||
            current is DailyReportImageUploadSuccess ||
            current is DailyReportImageUploadError,
        listener: (context, state) {
          if (state is DailyReportOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is DailyReportOperationError) {
            setState(() {
              _isLoading = false;
              _isSavingDraft = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is DailyReportImageUploadError) {
            setState(() {
              _isProcessingImages = false;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading image: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project selector
                      _buildSectionTitle('Project Information'),
                      _buildProjectDropdown(),
                      const SizedBox(height: 16),

                      // Date picker
                      _buildDatePicker(),
                      const SizedBox(height: 24),

                      // Work description
                      _buildSectionTitle('Work Details'),
                      _buildTextField(
                        controller: _workDescriptionController,
                        label: 'Work Description',
                        hint: 'Describe the work performed',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter work description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hours worked
                      _buildTextField(
                        controller: _hoursWorkedController,
                        label: 'Hours Worked',
                        hint: 'Enter total hours',
                        keyboardType: TextInputType.number,
                        validator: (value) {
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
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weather conditions
                      _buildTextField(
                        controller: _weatherController,
                        label: 'Weather Conditions',
                        hint: 'Describe weather at the worksite',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.wb_sunny),
                          onPressed: _fetchCurrentWeather,
                          tooltip: 'Get Current Weather',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Safety incidents
                      _buildTextField(
                        controller: _safetyController,
                        label: 'Safety Incidents',
                        hint: 'Describe any safety incidents or concerns',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Additional notes
                      _buildTextField(
                        controller: _notesController,
                        label: 'Additional Notes',
                        hint: 'Any other information about the work',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Photo uploader
                      _buildSectionTitle('Photos'),
                      _buildPhotoUploader(),
                      const SizedBox(height: 24),

                      // Location
                      _buildSectionTitle('Location'),
                      _buildLocationField(),
                      const SizedBox(height: 32),

                      // Submit button
                      _buildSubmitButton(isEditing),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              _isProcessingImages
                                  ? 'Uploading photos...'
                                  : _isSavingDraft
                                  ? 'Saving draft...'
                                  : 'Submitting report...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProjectDropdown() {
    // In a real app, we'd fetch projects from API
    final projects = [
      {'id': 'proj-001', 'name': 'Solar Installation Alpha'},
      {'id': 'proj-002', 'name': 'Commercial Rooftop Retrofit'},
      {'id': 'proj-003', 'name': 'Residential Solar Array'},
    ];

    return DropdownButtonFormField<String>(
      value: projects.any((p) => p['id'] == _selectedProjectId)
          ? _selectedProjectId
          : null, // Only use the value if it exists in the list
      decoration: InputDecoration(
        labelText: 'Project',
        hintText: 'Select a project',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items: projects.map((project) {
        return DropdownMenuItem<String>(
          value: project['id'],
          child: Text(project['name']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProjectId = value;
          // Set project name in controller
          _projectController.text = projects.firstWhere(
            (p) => p['id'] == value,
          )['name']!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a project';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Report Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPhotoUploader() {
    return Column(
      children: [
        // Image thumbnails
        if (_images.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_images[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        // Add photo buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildLocationField() {
    return Stack(
      children: [
        TextFormField(
          controller: _locationController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Current Location',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshLocation,
              tooltip: 'Refresh Location',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _submitReport(isEditing),
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

  void _fetchCurrentWeather() async {
    if (_locationData == null) {
      await _getLocation();

      if (_locationData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get your location for weather data'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetching current weather...')),
    );

    // Use the cubit to fetch weather
    await context.read<DailyReportsCubit>().fetchCurrentWeather(
      _locationData!.latitude ?? 0,
      _locationData!.longitude ?? 0,
    );

    // Listen to the state changes (in a real app you'd use BlocListener)
    final state = context.read<DailyReportsCubit>().state;
    if (state is WeatherDataState && state.weatherData != null) {
      setState(() {
        _weatherController.text = state.weatherData!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weather information updated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch weather data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveDraft() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isSavingDraft = true;
      });

      try {
        // Create a draft report from form data
        final draftReport = _createReportFromForm(DailyReportStatus.draft);

        // Save the draft using the cubit
        await context.read<DailyReportsCubit>().saveDraftLocally(draftReport);

        // Handle state change (in a real app you'd use BlocListener)
        final state = context.read<DailyReportsCubit>().state;
        if (state is DailyReportDraftSaved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Draft saved locally. Will sync when online.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (state is DailyReportOperationFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving draft: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving draft: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSavingDraft = false;
          });
        }
      }
    }
  }

  /// Create a report entity from form data
  DailyReport _createReportFromForm(DailyReportStatus status) {
    // Generate a new report ID if this is a new report
    final reportId = widget.report?.reportId ?? _uuid.v4();

    // Create location info if available
    LocationInfo? locationInfo;
    if (_locationData != null) {
      locationInfo = LocationInfo(
        latitude: _locationData!.latitude ?? 0,
        longitude: _locationData!.longitude ?? 0,
        address: _locationController.text,
        timestamp: DateTime.now(),
      );
    }

    // For demonstration purposes, using simple data
    return DailyReport(
      reportId: reportId,
      projectId: _selectedProjectId ?? '',
      technicianId: 'current_user_id', // In a real app, get from auth service
      reportDate: _selectedDate,
      status: status,
      workStartTime: '09:00', // Would be from form in real implementation
      workEndTime: '17:00', // Would be from form in real implementation
      weatherConditions: _weatherController.text,
      overallNotes: _notesController.text,
      safetyNotes: _safetyController.text,
      delaysOrIssues: '',
      photosCount: _images.length,
      createdAt: widget.report?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      project: ProjectInfo(
        projectId: _selectedProjectId ?? '',
        projectName: _projectController.text,
        address: _locationController.text,
      ),
      location: locationInfo,
      workProgressItems: [
        WorkProgressItem(
          workProgressId: _uuid.v4(),
          reportId: reportId,
          taskDescription: _workDescriptionController.text,
          hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0,
          percentageComplete: 100, // Would be from form in real implementation
          notes: '',
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  void _submitReport(bool isEditing) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final hasNetwork = await _checkNetworkConnectivity();

        if (!hasNetwork) {
          // Save as offline draft if no network connectivity
          await _handleOfflineSubmission(isEditing);
          return;
        }

        // Upload images first
        final imageIds = await _uploadImages();

        // Create/update report
        if (isEditing) {
          await _updateReport(imageIds);
        } else {
          await _createReport(imageIds);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Check if network connectivity is available
  Future<bool> _checkNetworkConnectivity() async {
    try {
      // In a real app, use connectivity_plus or similar package
      // For example:
      // final connectivityResult = await Connectivity().checkConnectivity();
      // return connectivityResult != ConnectivityResult.none;

      // For this demo, simulate connectivity (always return true)
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handle offline submission by saving locally
  Future<void> _handleOfflineSubmission(bool isEditing) async {
    try {
      // Create a report with submitted status (will be queued for sync)
      final report = _createReportFromForm(DailyReportStatus.submitted);

      // Save it locally using the cubit
      await context.read<DailyReportsCubit>().saveDraftLocally(report);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No network connection. Report saved locally and will be submitted when online.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );

        // Return to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving offline: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];

    setState(() {
      _isProcessingImages = true;
    });

    final List<String> imageIds = [];

    // Process each image in the list
    for (int i = 0; i < _images.length; i++) {
      try {
        // In a real app, we'd upload each image to server and get back an ID
        // final file = _images[i];
        // final imageId = await uploadImageToServer(file);

        // For demo, we'll generate a fake ID
        await Future.delayed(const Duration(milliseconds: 500));
        final imageId = _uuid.v4();
        imageIds.add(imageId);
      } catch (e) {
        throw Exception('Failed to upload image: $e');
      }
    }

    setState(() {
      _isProcessingImages = false;
    });

    return imageIds;
  }

  Future<void> _createReport(List<String> imageIds) async {
    final hours = double.tryParse(_hoursWorkedController.text) ?? 0;

    // Create a work progress item for the main task
    final workProgressItem = WorkProgressItem(
      workProgressId: _uuid.v4(),
      reportId: _uuid.v4(), // This will be set by backend
      taskDescription: _workDescriptionController.text,
      hoursWorked: hours,
      percentageComplete: 100, // Default to 100% for simplicity
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    // Create the report
    final report = DailyReport(
      reportId: _uuid.v4(), // This will be set by backend
      projectId: _selectedProjectId!,
      technicianId: 'current-user-id', // Would come from auth in real app
      reportDate: _selectedDate,
      status: DailyReportStatus.submitted,
      workStartTime: '08:00 AM', // Hardcoded for demo
      workEndTime: '05:00 PM', // Hardcoded for demo
      weatherConditions: _weatherController.text,
      overallNotes: _notesController.text,
      safetyNotes: _safetyController.text,
      delaysOrIssues: '', // Not implemented in this form
      photosCount: imageIds.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      workProgressItems: [workProgressItem],
      submittedAt: DateTime.now(),
    );

    await context.read<DailyReportsCubit>().createDailyReport(report);
  }

  Future<void> _updateReport(List<String> imageIds) async {
    if (widget.report == null) return;

    final hours = double.tryParse(_hoursWorkedController.text) ?? 0;

    // Get existing work progress items or create a new one
    List<WorkProgressItem> workProgressItems = [];

    if (widget.report!.workProgressItems.isNotEmpty) {
      // Update the first work progress item
      final existingItem = widget.report!.workProgressItems.first;
      workProgressItems.add(
        WorkProgressItem(
          workProgressId: existingItem.workProgressId,
          reportId: widget.report!.reportId,
          taskDescription: _workDescriptionController.text,
          hoursWorked: hours,
          percentageComplete: existingItem.percentageComplete,
          notes: _notesController.text,
          createdAt: existingItem.createdAt,
        ),
      );

      // Keep any other work progress items unchanged
      if (widget.report!.workProgressItems.length > 1) {
        workProgressItems.addAll(widget.report!.workProgressItems.skip(1));
      }
    } else {
      // Create a new work progress item
      workProgressItems.add(
        WorkProgressItem(
          workProgressId: _uuid.v4(),
          reportId: widget.report!.reportId,
          taskDescription: _workDescriptionController.text,
          hoursWorked: hours,
          percentageComplete: 100, // Default to 100% for simplicity
          notes: _notesController.text,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Update the report
    final updatedReport = widget.report!.copyWith(
      projectId: _selectedProjectId,
      reportDate: _selectedDate,
      weatherConditions: _weatherController.text,
      overallNotes: _notesController.text,
      safetyNotes: _safetyController.text,
      photosCount: widget.report!.photosCount + imageIds.length,
      updatedAt: DateTime.now(),
      workProgressItems: workProgressItems,
    );

    await context.read<DailyReportsCubit>().updateDailyReport(updatedReport);
  }
}
