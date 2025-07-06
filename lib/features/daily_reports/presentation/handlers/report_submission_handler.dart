import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';
import '../../domain/entities/daily_report.dart';

/// Handles report submission logic and network connectivity
class ReportSubmissionHandler {
  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final Uuid _uuid = const Uuid();

  ReportSubmissionHandler({required this.context, required this.formKey});

  /// Submits a daily report (create or update)
  Future<void> submitReport({
    required DailyReport? existingReport,
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController projectController,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required TextEditingController locationController,
    required List<XFile> images,
    required LocationData? locationData,
    required Function(bool) setLoading,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setLoading(true);

    try {
      final hasNetwork = await _checkNetworkConnectivity();
      final isEditing = existingReport != null;

      if (!hasNetwork) {
        await _handleOfflineSubmission(
          existingReport: existingReport,
          selectedProjectId: selectedProjectId,
          selectedDate: selectedDate,
          projectController: projectController,
          workDescriptionController: workDescriptionController,
          hoursWorkedController: hoursWorkedController,
          weatherController: weatherController,
          safetyController: safetyController,
          notesController: notesController,
          locationController: locationController,
          images: images,
          locationData: locationData,
          setLoading: setLoading,
        );
        return;
      }

      // Upload images first
      final imageIds = await _uploadImages(images, setLoading);

      // Create or update report
      if (isEditing) {
        await _updateReport(
          existingReport: existingReport,
          selectedProjectId: selectedProjectId,
          selectedDate: selectedDate,
          workDescriptionController: workDescriptionController,
          hoursWorkedController: hoursWorkedController,
          weatherController: weatherController,
          safetyController: safetyController,
          notesController: notesController,
          imageIds: imageIds,
        );
      } else {
        await _createReport(
          selectedProjectId: selectedProjectId,
          selectedDate: selectedDate,
          workDescriptionController: workDescriptionController,
          hoursWorkedController: hoursWorkedController,
          weatherController: weatherController,
          safetyController: safetyController,
          notesController: notesController,
          imageIds: imageIds,
        );
      }
    } catch (e) {
      setLoading(false);
      _showError('Error: $e');
    }
  }

  /// Saves a draft report locally
  Future<void> saveDraft({
    required DailyReport? existingReport,
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController projectController,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required TextEditingController locationController,
    required List<XFile> images,
    required LocationData? locationData,
    required Function(bool) setLoading,
    required Function(bool) setSavingDraft,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setLoading(true);
    setSavingDraft(true);

    try {
      final draftReport = _createReportFromForm(
        existingReport: existingReport,
        status: DailyReportStatus.draft,
        selectedProjectId: selectedProjectId,
        selectedDate: selectedDate,
        projectController: projectController,
        workDescriptionController: workDescriptionController,
        hoursWorkedController: hoursWorkedController,
        weatherController: weatherController,
        safetyController: safetyController,
        notesController: notesController,
        locationController: locationController,
        images: images,
        locationData: locationData,
      );

      await context.read<DailyReportsCubit>().saveDraftLocally(draftReport);

      final state = context.read<DailyReportsCubit>().state;
      if (state is DailyReportDraftSaved) {
        _showSuccess('Draft saved locally. Will sync when online.');
      } else if (state is DailyReportOperationFailure) {
        _showError('Error saving draft: ${state.message}');
      }
    } catch (e) {
      _showError('Error saving draft: $e');
    } finally {
      setLoading(false);
      setSavingDraft(false);
    }
  }

  /// Creates a report entity from form data
  DailyReport _createReportFromForm({
    required DailyReport? existingReport,
    required DailyReportStatus status,
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController projectController,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required TextEditingController locationController,
    required List<XFile> images,
    required LocationData? locationData,
  }) {
    final reportId = existingReport?.reportId ?? _uuid.v4();

    LocationInfo? locationInfo;
    if (locationData != null) {
      locationInfo = LocationInfo(
        latitude: locationData.latitude ?? 0,
        longitude: locationData.longitude ?? 0,
        address: locationController.text,
        timestamp: DateTime.now(),
      );
    }

    return DailyReport(
      reportId: reportId,
      projectId: selectedProjectId ?? '',
      technicianId: 'current_user_id',
      reportDate: selectedDate,
      status: status,
      workStartTime: '09:00',
      workEndTime: '17:00',
      weatherConditions: weatherController.text,
      overallNotes: notesController.text,
      safetyNotes: safetyController.text,
      delaysOrIssues: '',
      photosCount: images.length,
      createdAt: existingReport?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      project: ProjectInfo(
        projectId: selectedProjectId ?? '',
        projectName: projectController.text,
        address: locationController.text,
      ),
      location: locationInfo,
      workProgressItems: [
        WorkProgressItem(
          workProgressId: _uuid.v4(),
          reportId: reportId,
          taskDescription: workDescriptionController.text,
          hoursWorked: double.tryParse(hoursWorkedController.text) ?? 0,
          percentageComplete: 100,
          notes: '',
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  /// Checks network connectivity
  Future<bool> _checkNetworkConnectivity() async {
    try {
      // In a real app, use connectivity_plus package
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handles offline submission
  Future<void> _handleOfflineSubmission({
    required DailyReport? existingReport,
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController projectController,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required TextEditingController locationController,
    required List<XFile> images,
    required LocationData? locationData,
    required Function(bool) setLoading,
  }) async {
    try {
      final report = _createReportFromForm(
        existingReport: existingReport,
        status: DailyReportStatus.submitted,
        selectedProjectId: selectedProjectId,
        selectedDate: selectedDate,
        projectController: projectController,
        workDescriptionController: workDescriptionController,
        hoursWorkedController: hoursWorkedController,
        weatherController: weatherController,
        safetyController: safetyController,
        notesController: notesController,
        locationController: locationController,
        images: images,
        locationData: locationData,
      );

      await context.read<DailyReportsCubit>().saveDraftLocally(report);
      setLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No network connection. Report saved locally and will be submitted when online.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setLoading(false);
      _showError('Error saving offline: $e');
    }
  }

  /// Uploads images and returns their IDs
  Future<List<String>> _uploadImages(List<XFile> images, Function(bool) setLoading) async {
    if (images.isEmpty) return [];

    final List<String> imageIds = [];

    for (int i = 0; i < images.length; i++) {
      try {
        // Simulate image upload
        await Future.delayed(const Duration(milliseconds: 500));
        final imageId = _uuid.v4();
        imageIds.add(imageId);
      } catch (e) {
        throw Exception('Failed to upload image: $e');
      }
    }

    return imageIds;
  }

  /// Creates a new report
  Future<void> _createReport({
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required List<String> imageIds,
  }) async {
    final hours = double.tryParse(hoursWorkedController.text) ?? 0;

    final workProgressItem = WorkProgressItem(
      workProgressId: _uuid.v4(),
      reportId: _uuid.v4(),
      taskDescription: workDescriptionController.text,
      hoursWorked: hours,
      percentageComplete: 100,
      notes: notesController.text,
      createdAt: DateTime.now(),
    );

    final report = DailyReport(
      reportId: _uuid.v4(),
      projectId: selectedProjectId!,
      technicianId: 'current-user-id',
      reportDate: selectedDate,
      status: DailyReportStatus.submitted,
      workStartTime: '08:00 AM',
      workEndTime: '05:00 PM',
      weatherConditions: weatherController.text,
      overallNotes: notesController.text,
      safetyNotes: safetyController.text,
      delaysOrIssues: '',
      photosCount: imageIds.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      workProgressItems: [workProgressItem],
      submittedAt: DateTime.now(),
    );

    await context.read<DailyReportsCubit>().createDailyReport(report);
  }

  /// Updates an existing report
  Future<void> _updateReport({
    required DailyReport existingReport,
    required String? selectedProjectId,
    required DateTime selectedDate,
    required TextEditingController workDescriptionController,
    required TextEditingController hoursWorkedController,
    required TextEditingController weatherController,
    required TextEditingController safetyController,
    required TextEditingController notesController,
    required List<String> imageIds,
  }) async {
    final hours = double.tryParse(hoursWorkedController.text) ?? 0;

    List<WorkProgressItem> workProgressItems = [];

    if (existingReport.workProgressItems.isNotEmpty) {
      final existingItem = existingReport.workProgressItems.first;
      workProgressItems.add(
        WorkProgressItem(
          workProgressId: existingItem.workProgressId,
          reportId: existingReport.reportId,
          taskDescription: workDescriptionController.text,
          hoursWorked: hours,
          percentageComplete: existingItem.percentageComplete,
          notes: notesController.text,
          createdAt: existingItem.createdAt,
        ),
      );

      if (existingReport.workProgressItems.length > 1) {
        workProgressItems.addAll(existingReport.workProgressItems.skip(1));
      }
    } else {
      workProgressItems.add(
        WorkProgressItem(
          workProgressId: _uuid.v4(),
          reportId: existingReport.reportId,
          taskDescription: workDescriptionController.text,
          hoursWorked: hours,
          percentageComplete: 100,
          notes: notesController.text,
          createdAt: DateTime.now(),
        ),
      );
    }

    final updatedReport = existingReport.copyWith(
      projectId: selectedProjectId,
      reportDate: selectedDate,
      weatherConditions: weatherController.text,
      overallNotes: notesController.text,
      safetyNotes: safetyController.text,
      photosCount: existingReport.photosCount + imageIds.length,
      updatedAt: DateTime.now(),
      workProgressItems: workProgressItems,
    );

    await context.read<DailyReportsCubit>().updateDailyReport(updatedReport);
  }

  /// Shows success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  /// Shows error message
  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error));
  }
}
