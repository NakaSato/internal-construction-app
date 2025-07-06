import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

/// API configuration and endpoint definitions for Solar Projects API
/// All configuration now comes from .env file via EnvironmentConfig
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // =============================================================================
  // BASE URL CONFIGURATION
  // =============================================================================

  /// Get the configured base URL from centralized environment config
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  /// Backward compatibility - same as baseUrl
  static String get configuredBaseUrl => baseUrl;

  // =============================================================================
  // TIMEOUT CONFIGURATIONS
  // =============================================================================

  static Duration get connectTimeout => Duration(milliseconds: EnvironmentConfig.connectTimeoutMs);
  static Duration get receiveTimeout => Duration(milliseconds: EnvironmentConfig.receiveTimeoutMs);
  static Duration get sendTimeout => Duration(milliseconds: EnvironmentConfig.sendTimeoutMs);

  // =============================================================================
  // AUTHENTICATION ENDPOINTS
  // =============================================================================

  /// Authentication endpoints
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authProfile = '/api/v1/auth/profile';

  // =============================================================================
  // CALENDAR MANAGEMENT ENDPOINTS
  // =============================================================================

  /// Calendar management endpoints
  static const String calendarEvents = '/api/v1/calendar';
  static const String calendarEventById = '/api/v1/calendar/{id}';
  static const String calendarEventsByDateRange = '/api/v1/calendar/range';
  static const String calendarEventConflicts = '/api/v1/calendar/conflicts';
  static const String calendarEventRecurring = '/api/v1/calendar/recurring';

  // =============================================================================
  // PROJECT MANAGEMENT ENDPOINTS
  // =============================================================================

  /// Project management endpoints
  static const String projects = '/api/projects';
  static const String projectById = '/api/projects/{id}';
  static const String projectsByManager = '/api/projects/manager/{managerId}';
  static const String projectsByStatus = '/api/projects/status/{status}';
  static const String projectsSearch = '/api/projects/search';
  static const String projectsStatistics = '/api/projects/statistics';
  static const String projectsNearLocation = '/api/projects/location';

  // =============================================================================
  // DAILY REPORTS ENDPOINTS
  // =============================================================================

  /// Daily reports endpoints
  static const String dailyReports = '/api/v1/daily-reports';
  static const String dailyReportById = '/api/v1/daily-reports/{id}';
  static const String dailyReportsByProject = '/api/v1/daily-reports/project/{projectId}';
  static const String dailyReportsByDate = '/api/v1/daily-reports/date';
  static const String dailyReportsApproval = '/api/v1/daily-reports/{id}/approval';

  // Additional Daily Reports endpoints
  static const String dailyReportsValidate = '/api/v1/daily-reports/validate';
  static const String dailyReportsExport = '/api/v1/daily-reports/export';
  static const String dailyReportsWeeklySummary = '/api/v1/daily-reports/weekly-summary';

  // Project-specific Daily Reports endpoints
  static const String dailyReportsProjectAnalytics = '/api/v1/daily-reports/projects/{projectId}/analytics';
  static const String dailyReportsProjectWeeklyReport = '/api/v1/daily-reports/projects/{projectId}/weekly-report';
  static const String dailyReportsProjectInsights = '/api/v1/daily-reports/projects/{projectId}/insights';
  static const String dailyReportsProjectTemplates = '/api/v1/daily-reports/projects/{projectId}/templates';

  // Workflow Management endpoints
  static const String dailyReportsSubmit = '/api/v1/daily-reports/{id}/submit';
  static const String dailyReportsApprove = '/api/v1/daily-reports/{id}/approve';
  static const String dailyReportsReject = '/api/v1/daily-reports/{id}/reject';
  static const String dailyReportsPendingApproval = '/api/v1/daily-reports/pending-approval';
  static const String dailyReportsApprovalHistory = '/api/v1/daily-reports/{reportId}/approval-history';

  // Bulk Operations endpoints
  static const String dailyReportsBulkApprove = '/api/v1/daily-reports/bulk-approve';
  static const String dailyReportsBulkReject = '/api/v1/daily-reports/bulk-reject';

  // Attachment Management endpoints
  static const String dailyReportsAttachments = '/api/v1/daily-reports/{id}/attachments';

  // =============================================================================
  // WORK CALENDAR ENDPOINTS
  // =============================================================================

  /// Work calendar endpoints
  static const String workCalendar = '/api/v1/work-calendar';
  static const String workCalendarEvents = '/api/v1/work-calendar/events';
  static const String workCalendarEventById = '/api/v1/work-calendar/events/{id}';
  static const String workCalendarTasks = '/api/v1/work-calendar/tasks';

  // =============================================================================
  // AUTHORIZATION ENDPOINTS
  // =============================================================================

  /// Authorization and permissions endpoints
  static const String permissions = '/api/v1/permissions';
  static const String roles = '/api/v1/roles';
  static const String userPermissions = '/api/v1/users/{userId}/permissions';
  static const String rolePermissions = '/api/v1/roles/{roleId}/permissions';

  // =============================================================================
  // WORK BREAKDOWN STRUCTURE (WBS) ENDPOINTS
  // =============================================================================

  /// Work Breakdown Structure endpoints
  static const String wbsEndpoint = '/api/v1/wbs';

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Build full URL with base URL
  static String buildUrl(String endpoint) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  /// Replace path parameters in endpoint
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return buildUrl(url);
  }

  /// Build Daily Reports URL with specific report ID
  static String buildDailyReportUrl(String reportId) {
    return buildUrlWithParams(dailyReportById, {'id': reportId});
  }

  /// Build Daily Reports project analytics URL
  static String buildDailyReportsAnalyticsUrl(String projectId) {
    return buildUrlWithParams(dailyReportsProjectAnalytics, {'projectId': projectId});
  }

  /// Build Daily Reports workflow URL
  static String buildDailyReportsWorkflowUrl(String reportId, String action) {
    final endpoints = {'submit': dailyReportsSubmit, 'approve': dailyReportsApprove, 'reject': dailyReportsReject};
    final endpoint = endpoints[action] ?? dailyReportsSubmit;
    return buildUrlWithParams(endpoint, {'id': reportId});
  }

  /// Build Daily Reports attachment URL
  static String buildDailyReportsAttachmentUrl(String reportId) {
    return buildUrlWithParams(dailyReportsAttachments, {'id': reportId});
  }

  /// Get all API configuration for debugging
  static Map<String, dynamic> getDebugInfo() {
    return {
      'baseUrl': baseUrl,
      'environment': EnvironmentConfig.currentEnvironment.name,
      'timeouts': {
        'connect': '${connectTimeout.inMilliseconds}ms',
        'receive': '${receiveTimeout.inMilliseconds}ms',
        'send': '${sendTimeout.inMilliseconds}ms',
      },
      'endpoints': {
        'auth': {
          'login': buildUrl(authLogin),
          'register': buildUrl(authRegister),
          'profile': buildUrl(authProfile),
          'refresh': buildUrl(authRefresh),
          'logout': buildUrl(authLogout),
        },
        'projects': {
          'list': buildUrl(projects),
          'byId': buildUrl(projectById.replaceAll('{id}', 'PROJECT_ID')),
          'search': buildUrl(projectsSearch),
          'statistics': buildUrl(projectsStatistics),
        },
        'dailyReports': {
          'list': buildUrl(dailyReports),
          'byId': buildUrl(dailyReportById.replaceAll('{id}', 'REPORT_ID')),
          'analytics': buildUrl(dailyReportsProjectAnalytics.replaceAll('{projectId}', 'PROJECT_ID')),
          'export': buildUrl(dailyReportsExport),
          'pendingApproval': buildUrl(dailyReportsPendingApproval),
        },
        'calendar': {
          'events': buildUrl(calendarEvents),
          'byId': buildUrl(calendarEventById.replaceAll('{id}', 'EVENT_ID')),
        },
        'workCalendar': {'events': buildUrl(workCalendarEvents), 'tasks': buildUrl(workCalendarTasks)},
        'authorization': {'permissions': buildUrl(permissions), 'roles': buildUrl(roles)},
      },
    };
  }

  /// Print API configuration for debugging
  static void printDebugInfo() {
    if (!EnvironmentConfig.debugMode) return;

    debugPrint('🔗 API Configuration Debug Info:');
    final info = getDebugInfo();
    debugPrint('  Base URL: ${info['baseUrl']}');
    debugPrint('  Environment: ${info['environment']}');
    debugPrint('  Timeouts: ${info['timeouts']}');
  }
}
