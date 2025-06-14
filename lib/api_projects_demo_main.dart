import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../features/authentication/domain/entities/user.dart';
import '../features/project_management/application/project_bloc.dart';
import '../features/project_management/presentation/screens/api_projects_list_screen.dart';
import '../core/widgets/app_header.dart';

/// Demo main file to showcase API-based project management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies
    await initializeDependencies();

    runApp(const ApiProjectsApp());
  } catch (e) {
    debugPrint('Failed to initialize dependencies: $e');
    runApp(const ApiProjectsApp());
  }
}

class ApiProjectsApp extends StatelessWidget {
  const ApiProjectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Projects Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: const ApiProjectsHomeScreen(),
    );
  }
}

class ApiProjectsHomeScreen extends StatelessWidget {
  const ApiProjectsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user for demo purposes
    final mockUser = User(
      userId: 'demo-user-123',
      username: 'demo.user',
      email: 'demo@example.com',
      fullName: 'Demo User',
      roleName: 'ProjectManager',
      isEmailVerified: true,
    );

    return Scaffold(
      appBar: AppHeader(
        user: mockUser,
        title: 'API Demo',
        workspaceTitle: 'API Integration',
        showNotificationBadge: true,
        notificationCount: 3,
      ),
      body: const ApiDemoBody(),
    );
  }
}

class ApiDemoBody extends StatelessWidget {
  const ApiDemoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text(
            'API Integration Demo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This demo showcases real-time project data from API with pagination support.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Features Section
          _buildFeatureCard(
            context,
            icon: Icons.api_rounded,
            title: 'Real API Integration',
            description:
                'Connects to actual backend API endpoints for project data',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.view_list_rounded,
            title: 'Pagination Support',
            description:
                'Efficient loading with pagination and infinite scroll',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.refresh_rounded,
            title: 'Real-time Updates',
            description: 'Pull-to-refresh and automatic data synchronization',
            color: Colors.orange,
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<ProjectBloc>(),
                      child: const ApiProjectsListScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.launch_rounded),
              label: const Text('View API Projects'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'API Configuration',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Endpoint: GET /api/v1/projects\nBase URL: ${getIt<String>()}\nFeatures: Pagination, Filtering, Search',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
