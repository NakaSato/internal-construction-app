import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection.config.dart';
import '../config/environment_config.dart' as app_env;
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/authorization/config/authorization_di.dart';
import '../../features/work_calendar/config/mock_work_calendar_di.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(initializerName: 'init', preferRelativeImports: true, asExtension: true)
void configureDependencies() => getIt.init(environment: _getInjectableEnvironment());

/// Maps app environment to Injectable environment constants
String _getInjectableEnvironment() {
  final appEnv = app_env.EnvironmentConfig.currentEnvironment;
  final injectableEnv = switch (appEnv) {
    app_env.Environment.development => Environment.dev,
    app_env.Environment.production => Environment.prod,
    app_env.Environment.local => Environment.dev, // Map local to dev
  };

  print('🔧 DI Environment mapping: $appEnv -> $injectableEnv');
  
  // Force debug output to verify the mapping
  print('🔍 Injectable constants: dev=${Environment.dev}, prod=${Environment.prod}');
  
  return injectableEnv;
}

/// Initialize all dependencies for the application
Future<void> initializeDependencies() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Print environment configuration for debugging
  if (app_env.EnvironmentConfig.debugMode) {
    app_env.EnvironmentConfig.printAllConfig();
  }

  // Configure the Injectable system
  configureDependencies();

  // Log which repository implementation is being used
  _logRepositorySelection();

  // Configure authorization dependencies
  configureAuthorizationDependencies();

  // Configure calendar management dependencies with mock implementations - disabled in favor of Injectable
  // configureCalendarManagementDependencies();

  // Configure work calendar dependencies with mock implementations
  configureWorkCalendarDependencies();

  // Note: Project management dependencies are handled by Injectable system
  // which automatically uses MockProjectRepository for dev/test and
  // ApiProjectRepository for production environments
  // await enhanced_di.setupDependencies(); // Disabled to avoid conflicts

  // Configure daily reports dependencies - disabled in favor of Injectable system
  // configureDailyReportsDependencies();

  // Configure WBS dependencies - disabled in favor of Injectable annotations
  // WbsDI.configure(getIt);

  // Note: API services are now handled by Injectable system
  // ApiServicesRegistration.registerApiServices(getIt); // Disabled to avoid conflicts
}

/// Log which repository implementation is being used for debugging
void _logRepositorySelection() {
  try {
    final repo = getIt<ProjectRepository>();
    final repoType = repo.runtimeType.toString();
    print('📦 Injected repository: $repoType');

    if (repoType.contains('Mock')) {
      print('🔨 Using MOCK repository for development/testing');
    } else if (repoType.contains('Api')) {
      print('🌐 Using API repository for production');
    } else {
      print('⚠️ Unknown repository type: $repoType');
    }
  } catch (e) {
    print('❌ Failed to resolve EnhancedProjectRepository: $e');
  }
}

@module
abstract class ExternalDependenciesModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @lazySingleton
  String get baseUrl => app_env.EnvironmentConfig.apiBaseUrl;
}
