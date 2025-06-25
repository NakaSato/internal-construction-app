import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API environment enumeration
enum ApiEnvironment { development, production, local }

/// API configuration and endpoint definitions for Solar Projects API
class ApiConfig {
  // =============================================================================
  // ENVIRONMENT CONFIGURATION
  // =============================================================================

  /// Environment-specific base URLs
  static const Map<ApiEnvironment, String> _environmentUrls = {
    ApiEnvironment.development:
        'https://dev-solar-projects-api.azurewebsites.net',
    ApiEnvironment.production: 'https://solar-projects-api.azurewebsites.net',
    ApiEnvironment.local: 'http://localhost:3000',
  };

  /// Current environment (defaults to production)
  static ApiEnvironment _currentEnvironment = ApiEnvironment.production;

  /// Get the current environment
  static ApiEnvironment get currentEnvironment => _currentEnvironment;

  /// Set the current environment
  static void setEnvironment(ApiEnvironment environment) {
    _currentEnvironment = environment;
  }

  /// Get base URL for a specific environment
  static String getEnvironmentUrl(ApiEnvironment environment) {
    return _environmentUrls[environment] ??
        _environmentUrls[ApiEnvironment.production]!;
  }

  /// Production API base URL (backward compatibility)
  static const String baseUrl = 'https://solar-projects-api.azurewebsites.net';

  /// Get the configured base URL with environment support
  static String get configuredBaseUrl {
    // Priority:
    // 1. Environment variable from .env
    // 2. Current selected environment
    // 3. Production fallback
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return getEnvironmentUrl(_currentEnvironment);
  }

  /// Initialize environment from .env file
  static void initializeEnvironment() {
    final envName = dotenv.env['API_ENVIRONMENT']?.toLowerCase();
    if (envName != null) {
      switch (envName) {
        case 'development':
        case 'dev':
          _currentEnvironment = ApiEnvironment.development;
          break;
        case 'production':
        case 'prod':
          _currentEnvironment = ApiEnvironment.production;
          break;
        case 'local':
          _currentEnvironment = ApiEnvironment.local;
          break;
        default:
          _currentEnvironment = ApiEnvironment.production;
      }
    }
  }

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
  static const String projects = '/api/v1/projects';
  static const String projectById = '/api/v1/projects/{id}';
  static const String projectTasks = '/api/v1/projects/{id}/tasks';
  static const String projectReports = '/api/v1/projects/{id}/reports';
  static const String projectTeamMembers = '/api/v1/projects/{id}/team';

  // =============================================================================
  // WORK CALENDAR ENDPOINTS
  // =============================================================================

  /// Work calendar endpoints
  static const String workCalendarEvents = '/api/v1/work-calendar/events';
  static const String workCalendarTasks = '/api/v1/work-calendar/tasks';
  static const String workCalendarSchedule = '/api/v1/work-calendar/schedule';
  static const String workCalendarAvailability =
      '/api/v1/work-calendar/availability';

  // =============================================================================
  // TASK MANAGEMENT ENDPOINTS
  // =============================================================================

  /// Task management endpoints
  static const String tasks = '/api/v1/tasks';
  static const String taskById = '/api/v1/tasks/{id}';
  static const String taskAssignments = '/api/v1/tasks/assignments';
  static const String taskProgress = '/api/v1/tasks/{id}/progress';

  // =============================================================================
  // DAILY REPORTS ENDPOINTS
  // =============================================================================

  /// Daily reports endpoints
  static const String dailyReports = '/api/v1/daily-reports';
  static const String dailyReportById = '/api/v1/daily-reports/{id}';
  static const String dailyReportsByProject =
      '/api/v1/daily-reports/project/{projectId}';
  static const String dailyReportSubmit = '/api/v1/daily-reports/submit';

  // =============================================================================
  // WORK REQUEST APPROVAL ENDPOINTS
  // =============================================================================

  /// Work request approval endpoints
  static const String workRequests = '/api/v1/work-requests';
  static const String workRequestById = '/api/v1/work-requests/{id}';
  static const String workRequestApproval =
      '/api/v1/work-requests/{id}/approve';
  static const String workRequestRejection =
      '/api/v1/work-requests/{id}/reject';
  static const String workRequestPending = '/api/v1/work-requests/pending';

  // =============================================================================
  // AUTHORIZATION ENDPOINTS
  // =============================================================================

  /// Authorization endpoints
  static const String userRoles = '/api/v1/auth/roles';
  static const String userPermissions = '/api/v1/auth/permissions';
  static const String roleAssignment = '/api/v1/auth/roles/assign';
  static const String permissionCheck = '/api/v1/auth/permissions/check';

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Build full URL for an endpoint
  static String fullUrl(String endpoint) {
    return '$configuredBaseUrl$endpoint';
  }

  /// Replace path parameters in endpoint URLs
  static String buildEndpoint(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Build project-specific endpoint
  static String projectEndpoint(String projectId, String endpoint) {
    return buildEndpoint(endpoint, {'id': projectId});
  }

  /// Build task-specific endpoint
  static String taskEndpoint(String taskId, String endpoint) {
    return buildEndpoint(endpoint, {'id': taskId});
  }

  /// Build daily report-specific endpoint
  static String dailyReportEndpoint(String reportId, String endpoint) {
    return buildEndpoint(endpoint, {'id': reportId});
  }

  /// Build work request-specific endpoint
  static String workRequestEndpoint(String requestId, String endpoint) {
    return buildEndpoint(endpoint, {'id': requestId});
  }

  // =============================================================================
  // REQUEST TIMEOUT CONFIGURATIONS
  // =============================================================================

  /// API timeout configurations (in seconds)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// File upload timeout (longer for large files)
  static const Duration uploadTimeout = Duration(minutes: 5);

  // =============================================================================
  // PAGINATION DEFAULTS
  // =============================================================================

  /// Default pagination parameters
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int defaultPageNumber = 1;

  // =============================================================================
  // ENVIRONMENT UTILITY METHODS
  // =============================================================================

  /// Get current environment name as string
  static String get environmentName {
    switch (_currentEnvironment) {
      case ApiEnvironment.development:
        return 'Development';
      case ApiEnvironment.production:
        return 'Production';
      case ApiEnvironment.local:
        return 'Local';
    }
  }

  /// Check if current environment is production
  static bool get isProduction =>
      _currentEnvironment == ApiEnvironment.production;

  /// Check if current environment is development
  static bool get isDevelopment =>
      _currentEnvironment == ApiEnvironment.development;

  /// Check if current environment is local
  static bool get isLocal => _currentEnvironment == ApiEnvironment.local;

  /// Get all available environments for UI selection
  static List<ApiEnvironment> get availableEnvironments =>
      ApiEnvironment.values;

  /// Get environment display names for UI
  static Map<ApiEnvironment, String> get environmentDisplayNames => {
    ApiEnvironment.development: 'Development',
    ApiEnvironment.production: 'Production',
    ApiEnvironment.local: 'Local Development',
  };

  /// Get current configuration summary for debugging
  static Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'baseUrl': configuredBaseUrl,
    'isDevelopment': isDevelopment,
    'isProduction': isProduction,
    'fromEnvFile': dotenv.env['API_BASE_URL'] != null,
  };
}
