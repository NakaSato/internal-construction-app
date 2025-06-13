import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart';

import 'injection.config.dart';
import '../../features/authorization/config/authorization_di.dart';
import '../../features/calendar_management/config/calendar_management_di.dart';

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

  configureDependencies();

  // Configure authorization dependencies
  configureAuthorizationDependencies();

  // Configure calendar management dependencies
  configureCalendarManagementDependencies();
}

@module
abstract class ExternalDependenciesModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Location get location => Location();
}
