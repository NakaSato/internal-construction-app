import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';
import '../api/api_config.dart';
import '../../features/authorization/config/authorization_di.dart';
import '../../features/calendar_management/config/mock_calendar_management_di.dart';
import '../../features/daily_reports/config/daily_reports_di.dart';
import '../../features/project_management/config/project_management_di.dart';
import '../../features/work_calendar/config/mock_work_calendar_di.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

/// Initialize all dependencies for the application
Future<void> initializeDependencies() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize API environment configuration
  ApiConfig.initializeEnvironment();

  configureDependencies();

  // Configure authorization dependencies
  configureAuthorizationDependencies();

  // Configure calendar management dependencies with mock implementations
  configureCalendarManagementDependencies();

  // Configure work calendar dependencies with mock implementations
  configureWorkCalendarDependencies();

  // Configure project management dependencies
  configureProjectManagementDependencies();

  // Configure daily reports dependencies
  configureDailyReportsDependencies();
}

@module
abstract class ExternalDependenciesModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  String get baseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://solar-projects-api.azurewebsites.net';
}
