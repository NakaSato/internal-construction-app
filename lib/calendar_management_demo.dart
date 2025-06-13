import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'features/calendar_management/presentation/screens/calendar_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const CalendarManagementDemoApp());
}

class CalendarManagementDemoApp extends StatelessWidget {
  const CalendarManagementDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Management Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calendar Management Feature Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This demo showcases the Calendar Management feature implementation including:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('• Event creation and editing'),
            const Text('• Event filtering and search'),
            const Text('• Multiple event types and priorities'),
            const Text('• Clean Architecture with BLoC pattern'),
            const Text('• API integration ready'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CalendarManagementScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Open Calendar Management'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Domain layer with entities and repositories'),
                    const Text(
                      '✅ Application layer with BLoC state management',
                    ),
                    const Text('✅ Infrastructure layer with API services'),
                    const Text('✅ Presentation layer with UI components'),
                    const Text('✅ Dependency injection configuration'),
                    const Text('✅ Navigation integration'),
                    const Text('⚠️  Backend API integration (requires server)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
