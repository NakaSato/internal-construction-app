import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// Application layer imports
import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';

// Domain layer imports
import '../../domain/entities/daily_report.dart';

// Presentation layer imports
import '../mixins/location_services_mixin.dart';
import '../mixins/weather_services_mixin.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/report_form_components.dart';
import '../handlers/report_submission_handler.dart';

/// Screen for creating and editing daily reports
class CreateDailyReportScreen extends StatefulWidget {
  final DailyReport? report;

  const CreateDailyReportScreen({super.key, this.report});

  @override
  State<CreateDailyReportScreen> createState() => _CreateDailyReportScreenState();
}

class _CreateDailyReportScreenState extends State<CreateDailyReportScreen>
    with LocationServicesMixin, WeatherServicesMixin {
  // Form constants
  static const String _defaultSafetyNotes = 'None';
  static const String _locationUnavailableText = 'Location unavailable';
  static const String _locationErrorText = 'Could not determine location';

  // Form controllers and state
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
  List<XFile> _images = [];
  bool _isLoading = false;
  bool _isSavingDraft = false;

  late ReportSubmissionHandler _submissionHandler;

  @override
  void initState() {
    super.initState();
    _submissionHandler = ReportSubmissionHandler(context: context, formKey: _formKey);
    _initializeForm();
    _initializeLocation();
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
      _locationController.text = report.project?.address ?? _locationUnavailableText;
    } else {
      // New report defaults
      _safetyController.text = _defaultSafetyNotes;
    }
  }

  Future<void> _initializeLocation() async {
    final locationData = await getCurrentLocation();
    if (locationData != null) {
      setState(() {
        _locationController.text = formatLocationData(locationData);
      });
    } else {
      setState(() {
        _locationController.text = _locationErrorText;
      });
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _locationController.text = 'Obtaining location...';
    });
    await _initializeLocation();
  }

  void _onImagesChanged(List<XFile> newImages) {
    setState(() {
      _images = newImages;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _setSavingDraft(bool saving) {
    setState(() {
      _isSavingDraft = saving;
    });
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
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimary),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is DailyReportOperationError) {
            _setLoading(false);
            _setSavingDraft(false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
            );
          } else if (state is DailyReportImageUploadError) {
            _setLoading(false);
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
                      // Project Information Section
                      ReportFormComponents.buildSectionTitle(context, 'Project Information'),
                      ReportFormComponents.buildProjectDropdown(
                        selectedProjectId: _selectedProjectId,
                        onChanged: (value) {
                          setState(() {
                            _selectedProjectId = value;
                            if (value != null) {
                              // Find project name and set it
                              final projects = [
                                {'id': 'proj-001', 'name': 'Solar Installation Alpha'},
                                {'id': 'proj-002', 'name': 'Commercial Rooftop Retrofit'},
                                {'id': 'proj-003', 'name': 'Residential Solar Array'},
                              ];
                              final project = projects.firstWhere((p) => p['id'] == value);
                              _projectController.text = project['name']!;
                            }
                          });
                        },
                        validator: ReportFormValidators.validateProject,
                      ),
                      const SizedBox(height: 16),

                      // Date picker
                      ReportFormComponents.buildDatePicker(
                        context: context,
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Work Details Section
                      ReportFormComponents.buildSectionTitle(context, 'Work Details'),
                      ReportFormComponents.buildTextField(
                        controller: _workDescriptionController,
                        label: 'Work Description',
                        hint: 'Describe the work performed',
                        maxLines: 3,
                        validator: (value) => ReportFormValidators.validateRequired(value, 'work description'),
                      ),
                      const SizedBox(height: 16),

                      // Hours worked
                      ReportFormComponents.buildTextField(
                        controller: _hoursWorkedController,
                        label: 'Hours Worked',
                        hint: 'Enter total hours',
                        keyboardType: TextInputType.number,
                        validator: ReportFormValidators.validateHours,
                      ),
                      const SizedBox(height: 16),

                      // Weather conditions
                      buildWeatherField(controller: _weatherController, onRefresh: () => _fetchCurrentWeather()),
                      const SizedBox(height: 16),

                      // Safety incidents
                      ReportFormComponents.buildTextField(
                        controller: _safetyController,
                        label: 'Safety Incidents',
                        hint: 'Describe any safety incidents or concerns',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Additional notes
                      ReportFormComponents.buildTextField(
                        controller: _notesController,
                        label: 'Additional Notes',
                        hint: 'Any other information about the work',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Photos Section
                      ReportFormComponents.buildSectionTitle(context, 'Photos'),
                      PhotoUploadWidget(images: _images, onImagesChanged: _onImagesChanged, isEnabled: !_isLoading),
                      const SizedBox(height: 24),

                      // Location Section
                      ReportFormComponents.buildSectionTitle(context, 'Location'),
                      ReportFormComponents.buildLocationField(
                        controller: _locationController,
                        onRefresh: _refreshLocation,
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      ReportFormComponents.buildSubmitButton(
                        context: context,
                        isEditing: isEditing,
                        isLoading: _isLoading,
                        onPressed: () => _submitReport(isEditing),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (_isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
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
                  _isSavingDraft ? 'Saving draft...' : 'Submitting report...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCurrentWeather() async {
    final locationData = cachedLocationData ?? await getCurrentLocation();
    if (locationData == null) {
      showLocationError(context, 'Unable to get your location for weather data');
      return;
    }

    await fetchCurrentWeather(locationData: locationData, weatherController: _weatherController);
  }

  Future<void> _saveDraft() async {
    await _submissionHandler.saveDraft(
      existingReport: widget.report,
      selectedProjectId: _selectedProjectId,
      selectedDate: _selectedDate,
      projectController: _projectController,
      workDescriptionController: _workDescriptionController,
      hoursWorkedController: _hoursWorkedController,
      weatherController: _weatherController,
      safetyController: _safetyController,
      notesController: _notesController,
      locationController: _locationController,
      images: _images,
      locationData: cachedLocationData,
      setLoading: _setLoading,
      setSavingDraft: _setSavingDraft,
    );
  }

  Future<void> _submitReport(bool isEditing) async {
    await _submissionHandler.submitReport(
      existingReport: widget.report,
      selectedProjectId: _selectedProjectId,
      selectedDate: _selectedDate,
      projectController: _projectController,
      workDescriptionController: _workDescriptionController,
      hoursWorkedController: _hoursWorkedController,
      weatherController: _weatherController,
      safetyController: _safetyController,
      notesController: _notesController,
      locationController: _locationController,
      images: _images,
      locationData: cachedLocationData,
      setLoading: _setLoading,
    );
  }
}
