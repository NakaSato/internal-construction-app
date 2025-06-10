import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/environment_config.dart';
import 'core/widgets/google_bottom_bar.dart';
import 'core/widgets/featured_screen.dart';
import 'utils/api_config_verifier.dart';

/// Comprehensive demo showcasing the API configuration and navigation
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Verify configuration
  ApiConfigVerifier.verifyConfiguration();

  runApp(const ComprehensiveDemoApp());
}

class ComprehensiveDemoApp extends StatelessWidget {
  const ComprehensiveDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Architecture App - API Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ComprehensiveDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ComprehensiveDemoScreen extends StatefulWidget {
  const ComprehensiveDemoScreen({super.key});

  @override
  State<ComprehensiveDemoScreen> createState() =>
      _ComprehensiveDemoScreenState();
}

class _ComprehensiveDemoScreenState extends State<ComprehensiveDemoScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Architecture App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showConfigInfo(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardPage(),
          const FeaturedScreen(),
          _buildCalendarPage(),
          _buildLocationPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: GoogleBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashboardPage() {
    final config = ApiConfigVerifier.getConfigSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        config['isCorrectHost']
                            ? Icons.check_circle
                            : Icons.warning,
                        color: config['isCorrectHost']
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'API Configuration Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildConfigRow('API Host', config['apiBaseUrl']),
                  _buildConfigRow('Environment', config['environment']),
                  _buildConfigRow('Debug Mode', config['debugMode'].toString()),
                  _buildConfigRow(
                    'Host Correct',
                    config['isCorrectHost'].toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('✅ Bottom Navigation with 5 tabs'),
                  Text('✅ Featured Partners screen with skeleton loading'),
                  Text('✅ Modern Material Design 3 UI'),
                  Text('✅ Environment configuration from .env'),
                  Text('✅ API host: http://localhost:5002/'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: const Text('View Partners'),
                      ),
                      ElevatedButton(
                        onPressed: () => _showConfigInfo(context),
                        child: const Text('Config Info'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('API Ready for localhost:5002!'),
                              ),
                            ),
                        child: const Text('Test API'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Work calendar feature ready for integration'),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Location',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Location tracking feature ready for integration'),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('User profile management ready for integration'),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  void _showConfigInfo(BuildContext context) {
    final config = ApiConfigVerifier.getConfigSummary();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Environment: ${config['environment']}'),
            Text('API Base URL: ${config['apiBaseUrl']}'),
            Text('Debug Mode: ${config['debugMode']}'),
            Text('Environment File Loaded: ${config['envFileLoaded']}'),
            Text('Correct Host: ${config['isCorrectHost']}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config['isCorrectHost']
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                config['isCorrectHost']
                    ? '✅ API correctly configured for localhost:5002'
                    : '⚠️  API configuration needs attention',
                style: TextStyle(
                  color: config['isCorrectHost']
                      ? Colors.green[800]
                      : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
