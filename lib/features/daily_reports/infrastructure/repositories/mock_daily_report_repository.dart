import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/daily_report.dart';
import '../../domain/repositories/daily_report_repository.dart';

/// Mock implementation of the DailyReportRepository for development and testing
class MockDailyReportRepository implements DailyReportRepository {
  final List<DailyReport> _dailyReports = [];
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  // Constructor that initializes some mock data
  MockDailyReportRepository() {
    _generateMockData();
  }

  @override
  Future<Either<Failure, DailyReportListResponse>> getDailyReports({
    int pageNumber = 1,
    int pageSize = 10,
    String? projectId,
    String? technicianId,
    DailyReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Apply filters
      List<DailyReport> filteredReports = List.from(_dailyReports);

      if (projectId != null) {
        filteredReports = filteredReports
            .where((report) => report.projectId == projectId)
            .toList();
      }

      if (technicianId != null) {
        filteredReports = filteredReports
            .where((report) => report.technicianId == technicianId)
            .toList();
      }

      if (status != null) {
        filteredReports = filteredReports
            .where((report) => report.status == status)
            .toList();
      }

      if (startDate != null) {
        filteredReports = filteredReports
            .where(
              (report) =>
                  report.reportDate.isAfter(startDate) ||
                  report.reportDate.isAtSameMomentAs(startDate),
            )
            .toList();
      }

      if (endDate != null) {
        filteredReports = filteredReports
            .where(
              (report) =>
                  report.reportDate.isBefore(endDate) ||
                  report.reportDate.isAtSameMomentAs(endDate),
            )
            .toList();
      }

      // Sort by reportDate, most recent first
      filteredReports.sort((a, b) => b.reportDate.compareTo(a.reportDate));

      // Apply pagination
      final totalCount = filteredReports.length;
      final totalPages = (totalCount / pageSize).ceil();
      final startIndex = (pageNumber - 1) * pageSize;
      final endIndex = min(startIndex + pageSize, totalCount);

      final paginatedReports = startIndex < endIndex
          ? filteredReports.sublist(startIndex, endIndex)
          : <DailyReport>[];

      return Right(
        DailyReportListResponse(
          reports: paginatedReports,
          totalCount: totalCount,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get daily reports: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReportById(
    String reportId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final report = _dailyReports.firstWhere(
        (r) => r.reportId == reportId,
        orElse: () => throw Exception('Report not found'),
      );

      return Right(report);
    } catch (e) {
      return Left(NotFoundFailure('Report not found: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> createDailyReport(
    DailyReport report,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Generate a unique ID for the new report
      final String newId = _uuid.v4();
      final now = DateTime.now();

      // Create a new report with the given data plus auto-generated fields
      final newReport = report.copyWith(
        reportId: newId,
        status: DailyReportStatus.draft,
        createdAt: now,
        updatedAt: now,
        photosCount: report.photosCount,
      );

      _dailyReports.add(newReport);
      return Right(newReport);
    } catch (e) {
      return Left(ServerFailure('Failed to create report: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> updateDailyReport(
    DailyReport report,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Find the index of the report to update
      final index = _dailyReports.indexWhere(
        (r) => r.reportId == report.reportId,
      );

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Update the report with the current timestamp
      final updatedReport = report.copyWith(updatedAt: DateTime.now());

      _dailyReports[index] = updatedReport;
      return Right(updatedReport);
    } catch (e) {
      return Left(ServerFailure('Failed to update report: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDailyReport(String reportId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      // Find the report to delete
      final reportExists = _dailyReports.any((r) => r.reportId == reportId);

      if (!reportExists) {
        return Left(NotFoundFailure('Report not found'));
      }

      _dailyReports.removeWhere((r) => r.reportId == reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete report: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> submitDailyReport(
    String reportId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 700));

      // Find the index of the report to update
      final index = _dailyReports.indexWhere((r) => r.reportId == reportId);

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Check if the report is in draft status
      if (_dailyReports[index].status != DailyReportStatus.draft) {
        return Left(ValidationFailure('Only draft reports can be submitted'));
      }

      // Update the report status
      final now = DateTime.now();
      final updatedReport = _dailyReports[index].copyWith(
        status: DailyReportStatus.submitted,
        submittedAt: now,
        updatedAt: now,
      );

      _dailyReports[index] = updatedReport;
      return Right(updatedReport);
    } catch (e) {
      return Left(ServerFailure('Failed to submit report: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> approveDailyReport(
    String reportId,
    String? comments,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 700));

      // Find the index of the report to update
      final index = _dailyReports.indexWhere((r) => r.reportId == reportId);

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Check if the report is in submitted status
      if (_dailyReports[index].status != DailyReportStatus.submitted) {
        return Left(
          ValidationFailure('Only submitted reports can be approved'),
        );
      }

      // Update the report status
      final now = DateTime.now();
      final updatedReport = _dailyReports[index].copyWith(
        status: DailyReportStatus.approved,
        approvedAt: now,
        approverComments: comments,
        updatedAt: now,
      );

      _dailyReports[index] = updatedReport;
      return Right(updatedReport);
    } catch (e) {
      return Left(ServerFailure('Failed to approve report: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> rejectDailyReport(
    String reportId,
    String reason,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 700));

      // Find the index of the report to update
      final index = _dailyReports.indexWhere((r) => r.reportId == reportId);

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Check if the report is in submitted status
      if (_dailyReports[index].status != DailyReportStatus.submitted) {
        return Left(
          ValidationFailure('Only submitted reports can be rejected'),
        );
      }

      if (reason.isEmpty) {
        return Left(ValidationFailure('Rejection reason is required'));
      }

      // Update the report status
      final now = DateTime.now();
      final updatedReport = _dailyReports[index].copyWith(
        status: DailyReportStatus.rejected,
        rejectedAt: now,
        rejectionReason: reason,
        updatedAt: now,
      );

      _dailyReports[index] = updatedReport;
      return Right(updatedReport);
    } catch (e) {
      return Left(ServerFailure('Failed to reject report: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDailyReportImage(
    String reportId,
    String imagePath,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Generate an image ID
      final imageId = _uuid.v4();

      // Find the index of the report to update
      final index = _dailyReports.indexWhere((r) => r.reportId == reportId);

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Update the photos count in the report
      final updatedReport = _dailyReports[index].copyWith(
        photosCount: _dailyReports[index].photosCount + 1,
        updatedAt: DateTime.now(),
      );

      _dailyReports[index] = updatedReport;

      // Return the mock image ID
      return Right(imageId);
    } catch (e) {
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(
    String reportId,
    String imageId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the index of the report to update
      final index = _dailyReports.indexWhere((r) => r.reportId == reportId);

      if (index == -1) {
        return Left(NotFoundFailure('Report not found'));
      }

      // Make sure the photos count doesn't go below 0
      final currentPhotos = _dailyReports[index].photosCount;
      final updatedReport = _dailyReports[index].copyWith(
        photosCount: currentPhotos > 0 ? currentPhotos - 1 : 0,
        updatedAt: DateTime.now(),
      );

      _dailyReports[index] = updatedReport;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete image: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> saveDraftLocally(
    DailyReport report,
  ) async {
    try {
      // Simulate local storage operation
      await Future.delayed(const Duration(milliseconds: 300));

      // Generate a unique ID if it doesn't have one
      final String reportId = report.reportId.isEmpty
          ? _uuid.v4()
          : report.reportId;
      final now = DateTime.now();

      // Create a new report with the given data plus auto-generated fields
      final savedReport = report.copyWith(
        reportId: reportId,
        status: DailyReportStatus.draft,
        createdAt: report.createdAt == DateTime(0) ? now : report.createdAt,
        updatedAt: now,
      );

      // Check if the report already exists in the list
      final existingIndex = _dailyReports.indexWhere(
        (r) => r.reportId == reportId,
      );
      if (existingIndex >= 0) {
        _dailyReports[existingIndex] = savedReport;
      } else {
        _dailyReports.add(savedReport);
      }

      return Right(savedReport);
    } catch (e) {
      return Left(LocalDatabaseFailure('Failed to save draft locally: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyReport>>> getLocalDrafts() async {
    try {
      // Simulate local storage operation
      await Future.delayed(const Duration(milliseconds: 300));

      // Filter only draft reports
      final drafts = _dailyReports
          .where((report) => report.status == DailyReportStatus.draft)
          .toList();

      return Right(drafts);
    } catch (e) {
      return Left(LocalDatabaseFailure('Failed to get local drafts: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyReport>>> syncLocalDrafts() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // For mock implementation, we'll just assume all drafts are successfully synced
      final drafts = _dailyReports
          .where((report) => report.status == DailyReportStatus.draft)
          .map((draft) => draft.copyWith(updatedAt: DateTime.now()))
          .toList();

      // Update the reports in the list
      for (final draft in drafts) {
        final index = _dailyReports.indexWhere(
          (r) => r.reportId == draft.reportId,
        );
        if (index >= 0) {
          _dailyReports[index] = draft;
        }
      }

      return Right(drafts);
    } catch (e) {
      return Left(ServerFailure('Failed to sync drafts: $e'));
    }
  }

  // Private helper method to generate mock data
  void _generateMockData() {
    // List of project information
    final projects = [
      const ProjectInfo(
        projectId: 'proj-001',
        projectName: 'Solar Installation Project Alpha',
        address: '123 Main Street, Springfield, IL',
        clientInfo: 'SolarTech Inc. - Contact: John Smith (555-123-4567)',
      ),
      const ProjectInfo(
        projectId: 'proj-002',
        projectName: 'Commercial Rooftop Retrofit',
        address: '456 Business Ave, Chicago, IL',
        clientInfo:
            'Chicago Commercial Properties - Contact: Sarah Johnson (555-987-6543)',
      ),
      const ProjectInfo(
        projectId: 'proj-003',
        projectName: 'Residential Solar Array',
        address: '789 Homestead Rd, Austin, TX',
        clientInfo:
            'Green Home Solutions - Contact: David Martinez (555-246-8101)',
      ),
    ];

    // List of technicians
    final technicians = [
      const TechnicianInfo(
        userId: 'user-001',
        fullName: 'John Technician',
        email: 'john.tech@example.com',
        username: 'johntech',
        roleName: 'Field Technician',
      ),
      const TechnicianInfo(
        userId: 'user-002',
        fullName: 'Jane Smith',
        email: 'jane.smith@example.com',
        username: 'janesmith',
        roleName: 'Senior Technician',
      ),
      const TechnicianInfo(
        userId: 'user-003',
        fullName: 'Robert Johnson',
        email: 'robert.j@example.com',
        username: 'robertj',
        roleName: 'Field Technician',
      ),
    ];

    // Generate 15 sample reports
    for (int i = 0; i < 15; i++) {
      final projectIndex = i % projects.length;
      final technicianIndex = i % technicians.length;
      final daysAgo = i % 30;

      final reportDate = DateTime.now().subtract(Duration(days: daysAgo));
      final createdAt = reportDate.subtract(const Duration(hours: 2));
      final updatedAt = createdAt.add(const Duration(minutes: 30));

      // Determine status based on report date
      final DailyReportStatus status;
      DateTime? submittedAt, approvedAt, rejectedAt;
      String? approverComments, rejectionReason;

      if (daysAgo > 20) {
        // Older reports are approved
        status = DailyReportStatus.approved;
        submittedAt = createdAt.add(const Duration(hours: 1));
        approvedAt = submittedAt.add(const Duration(hours: 4));
        approverComments =
            'Approved with commendation for detailed documentation.';
      } else if (daysAgo > 10) {
        // Medium-aged reports are either approved or rejected
        if (i % 5 == 0) {
          status = DailyReportStatus.rejected;
          submittedAt = createdAt.add(const Duration(hours: 1));
          rejectedAt = submittedAt.add(const Duration(hours: 3));
          rejectionReason =
              'Missing safety documentation. Please provide detailed safety measures taken.';
        } else {
          status = DailyReportStatus.approved;
          submittedAt = createdAt.add(const Duration(hours: 1));
          approvedAt = submittedAt.add(const Duration(hours: 2));
          approverComments = 'Work completed as expected.';
        }
      } else if (daysAgo > 5) {
        // Recent reports are submitted
        status = DailyReportStatus.submitted;
        submittedAt = createdAt.add(const Duration(hours: 1));
      } else {
        // Very recent reports are drafts
        status = DailyReportStatus.draft;
      }

      // Generate work progress items
      final workProgressItems = <WorkProgressItem>[];
      final taskCount = 1 + _random.nextInt(3); // 1 to 3 tasks

      for (int j = 0; j < taskCount; j++) {
        workProgressItems.add(
          WorkProgressItem(
            workProgressId: 'wp-${i + 1}-${j + 1}',
            reportId: 'report-${i + 1}',
            taskDescription: _getTaskDescription(j),
            hoursWorked: 1 + _random.nextDouble() * 4, // 1 to 5 hours
            percentageComplete:
                10 +
                (_random.nextInt(10) * 10), // 10% to 100% in 10% increments
            notes: j % 2 == 0
                ? 'Completed as scheduled'
                : 'Some challenges encountered but resolved',
            createdAt: createdAt,
          ),
        );
      }

      // Generate personnel logs
      final personnelLogs = <PersonnelLog>[];
      final personnelCount = 1 + _random.nextInt(2); // 1 to 2 personnel

      for (int j = 0; j < personnelCount; j++) {
        personnelLogs.add(
          PersonnelLog(
            personnelLogId: 'pl-${i + 1}-${j + 1}',
            reportId: 'report-${i + 1}',
            personnelName: _getPersonnelName(j),
            role: _getPersonnelRole(j),
            hoursWorked: 6 + _random.nextDouble() * 4, // 6 to 10 hours
            overtimeHours: _random.nextDouble() * 2, // 0 to 2 hours
            notes: j % 2 == 0
                ? 'Regular shift'
                : 'Stayed late to complete work',
            createdAt: createdAt,
          ),
        );
      }

      // Generate material usage
      final materialUsage = <MaterialUsage>[];
      final materialCount = _random.nextInt(3); // 0 to 2 materials

      for (int j = 0; j < materialCount; j++) {
        materialUsage.add(
          MaterialUsage(
            materialUsageId: 'mu-${i + 1}-${j + 1}',
            reportId: 'report-${i + 1}',
            materialName: _getMaterialName(j),
            quantityUsed: 1 + _random.nextInt(10), // 1 to 10 units
            unit: j % 2 == 0 ? 'pieces' : 'meters',
            notes: 'Standard usage for installation',
            createdAt: createdAt,
          ),
        );
      }

      // Generate equipment logs
      final equipmentLogs = <EquipmentLog>[];
      final equipmentCount = _random.nextInt(2); // 0 to 1 equipment

      for (int j = 0; j < equipmentCount; j++) {
        equipmentLogs.add(
          EquipmentLog(
            equipmentLogId: 'el-${i + 1}-${j + 1}',
            reportId: 'report-${i + 1}',
            equipmentName: _getEquipmentName(j),
            usageHours: 1 + _random.nextDouble() * 7, // 1 to 8 hours
            condition: j % 3 == 0
                ? 'Excellent'
                : j % 3 == 1
                ? 'Good'
                : 'Fair',
            notes: j % 2 == 0
                ? 'Equipment functioning properly'
                : 'Minor maintenance needed',
            createdAt: createdAt,
          ),
        );
      }

      // Create mock report
      final photosCount = _random.nextInt(6); // 0 to 5 photos

      _dailyReports.add(
        DailyReport(
          reportId: 'report-${i + 1}',
          projectId: projects[projectIndex].projectId,
          technicianId: technicians[technicianIndex].userId,
          reportDate: reportDate,
          status: status,
          workStartTime: '08:00',
          workEndTime: '16:00',
          weatherConditions: _getWeatherCondition(i),
          overallNotes:
              'Work proceeding according to schedule. ${i % 3 == 0 ? "Minor adjustments made to accommodate customer requests." : ""}',
          safetyNotes: 'All safety protocols followed. PPE worn at all times.',
          delaysOrIssues: i % 4 == 0
              ? 'Delayed 30 minutes due to late material delivery'
              : 'None',
          photosCount: photosCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
          project: projects[projectIndex],
          technician: technicians[technicianIndex],
          workProgressItems: workProgressItems,
          personnelLogs: personnelLogs,
          materialUsage: materialUsage,
          equipmentLogs: equipmentLogs,
          approverComments: approverComments,
          rejectionReason: rejectionReason,
          submittedAt: submittedAt,
          approvedAt: approvedAt,
          rejectedAt: rejectedAt,
        ),
      );
    }
  }

  // Helper method to get random task descriptions
  String _getTaskDescription(int index) {
    final tasks = [
      'Site survey and preparation',
      'Roof structural assessment',
      'Solar panel installation',
      'Electrical wiring and connections',
      'Inverter installation and setup',
      'System testing and commissioning',
      'Quality control inspection',
      'Client walkthrough and training',
    ];

    return tasks[index % tasks.length];
  }

  // Helper method to get random personnel names
  String _getPersonnelName(int index) {
    final names = [
      'Michael Rodriguez',
      'Sarah Thompson',
      'James Wilson',
      'Lisa Johnson',
      'Kevin Lee',
      'Tanya Miller',
    ];

    return names[index % names.length];
  }

  // Helper method to get random personnel roles
  String _getPersonnelRole(int index) {
    final roles = [
      'Installer',
      'Electrician',
      'Helper',
      'Supervisor',
      'Safety Officer',
    ];

    return roles[index % roles.length];
  }

  // Helper method to get random material names
  String _getMaterialName(int index) {
    final materials = [
      'Solar Panels',
      'Mounting Rails',
      'Junction Boxes',
      'DC Cables',
      'MC4 Connectors',
      'Conduit Pipes',
    ];

    return materials[index % materials.length];
  }

  // Helper method to get random equipment names
  String _getEquipmentName(int index) {
    final equipment = [
      'Power Drill',
      'Wire Crimper',
      'Voltage Tester',
      'Aerial Lift',
      'Rooftop Safety Harness',
    ];

    return equipment[index % equipment.length];
  }

  // Helper method to get random weather conditions
  String _getWeatherCondition(int index) {
    final conditions = [
      'Sunny, 75°F',
      'Partly cloudy, 68°F',
      'Clear skies, 82°F',
      'Overcast, 65°F',
      'Light rain, 62°F',
      'Windy, 70°F',
    ];

    return conditions[index % conditions.length];
  }
}
