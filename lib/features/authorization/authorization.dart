// Authorization feature exports
library authorization;

// Domain
export 'domain/entities/permission.dart';
export 'domain/entities/role.dart';
export 'domain/repositories/authorization_repository.dart';
export 'domain/services/authorization_service.dart';
export 'domain/guards/authorization_guard.dart';
export 'domain/extensions/user_authorization_extensions.dart';

// Application
export 'application/authorization_event.dart';
export 'application/authorization_state.dart';
export 'application/authorization_bloc.dart';

// Presentation
export 'presentation/widgets/authorization_widgets.dart';

// Infrastructure
export 'infrastructure/models/permission_model.dart';
export 'infrastructure/models/role_model.dart';
export 'infrastructure/models/authorization_response_model.dart';
export 'infrastructure/repositories/api_authorization_repository.dart';
export 'infrastructure/services/authorization_api_service.dart';
export 'infrastructure/middleware/authorization_middleware.dart';

// Configuration
export 'config/authorization_config.dart';
export 'config/authorization_di.dart';
