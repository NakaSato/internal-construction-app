// Domain
export 'domain/entities/work_request.dart';
export 'domain/entities/approval_history.dart';
export 'domain/entities/approval_statistics.dart';
export 'domain/entities/approval_requests.dart';
export 'domain/repositories/work_request_approval_repository.dart';
export 'domain/usecases/get_my_work_requests_usecase.dart';
export 'domain/usecases/get_pending_approvals_usecase.dart';
export 'domain/usecases/process_approval_usecase.dart';
export 'domain/usecases/get_approval_history_usecase.dart';
export 'domain/usecases/get_approval_statistics_usecase.dart';

// Application
export 'application/cubits/my_work_requests_cubit.dart';
export 'application/cubits/pending_approvals_cubit.dart';
export 'application/cubits/process_approval_cubit.dart';

// Infrastructure
export 'infrastructure/repositories/mock_work_request_approval_repository.dart';
export 'infrastructure/datasources/mock_work_request_service.dart';

// Presentation
export 'presentation/screens/my_work_requests_screen.dart';
export 'presentation/screens/pending_approvals_screen.dart';
export 'presentation/screens/process_approval_screen.dart';
export 'presentation/screens/approval_status_screen.dart';
export 'presentation/screens/approval_dashboard_screen.dart';
export 'presentation/widgets/work_request_card.dart';
export 'presentation/widgets/pending_approval_card.dart';
export 'presentation/widgets/approval_status_card.dart';
export 'presentation/widgets/approval_history_card.dart';
