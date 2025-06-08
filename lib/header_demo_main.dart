import 'package:flutter/material.dart';
import 'core/widgets/app_header.dart';
import 'features/authentication/domain/entities/user.dart';

void main() {
  runApp(const HeaderDemoApp());
}

class HeaderDemoApp extends StatelessWidget {
  const HeaderDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Header Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HeaderDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HeaderDemoScreen extends StatefulWidget {
  const HeaderDemoScreen({super.key});

  @override
  State<HeaderDemoScreen> createState() => _HeaderDemoScreenState();
}

class _HeaderDemoScreenState extends State<HeaderDemoScreen> {
  int _currentDemo = 0;
  bool _showNotifications = true;
  int _notificationCount = 3;

  // Demo user data
  final _demoUsers = [
    User(
      userId: '1',
      username: 'johndoe',
      email: 'john.doe@example.com',
      fullName: 'John Doe',
      roleName: 'Manager',
      isEmailVerified: true,
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    User(
      userId: '2',
      username: 'sarahsmith',
      email: 'sarah.smith@company.com',
      fullName: 'Sarah Smith',
      roleName: 'Designer',
      isEmailVerified: true,
      profileImageUrl: null, // Will show initials
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    User(
      userId: '3',
      username: 'mikejohnson',
      email: 'mike.johnson@example.com',
      fullName: '', // Will use email as fallback
      roleName: 'Developer',
      isEmailVerified: true,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final _demoTitles = ['Dashboard', 'My Workspace', 'Project Overview'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        user: _demoUsers[_currentDemo % _demoUsers.length],
        title: _demoTitles[_currentDemo % _demoTitles.length],
        showNotificationBadge: _showNotifications,
        notificationCount: _notificationCount,
        onProfileTap: () {
          _showProfileDialog(context);
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentDemo = (_currentDemo + 1) % 3;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Switched to demo ${_currentDemo + 1}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDemoInfo(),
            const SizedBox(height: 24),
            _buildHeaderFeatures(),
            const SizedBox(height: 24),
            _buildCustomizationOptions(),
            const SizedBox(height: 24),
            _buildSimpleHeaderDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfo() {
    final currentUser = _demoUsers[_currentDemo % _demoUsers.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Header Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Showcasing the new header component with user profile on the left and actions on the right.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Current Demo: ${_currentDemo + 1}/3',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'User: ${currentUser.name.isNotEmpty ? currentUser.name : 'No name (using email)'}',
            ),
            Text('Email: ${currentUser.email}'),
            Text(
              'Profile Image: ${currentUser.profileImageUrl != null ? 'Yes' : 'No (showing initials)'}',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentDemo = (_currentDemo + 1) % 3;
                });
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('Next Demo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderFeatures() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Header Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.person_outline,
              'User Profile',
              'Profile avatar with name/initials, tap to navigate to profile',
            ),
            _buildFeatureItem(
              Icons.notifications_outlined,
              'Notifications',
              'Notification icon with badge count, customizable visibility',
            ),
            _buildFeatureItem(
              Icons.search_outlined,
              'Search',
              'Search functionality for app-wide content discovery',
            ),
            _buildFeatureItem(
              Icons.more_vert,
              'Menu Options',
              'Dropdown menu with settings, help, and feedback options',
            ),
            _buildFeatureItem(
              Icons.extension_outlined,
              'Custom Actions',
              'Support for additional custom action buttons',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customization Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Notification Badge'),
              subtitle: const Text('Toggle notification count visibility'),
              value: _showNotifications,
              onChanged: (value) {
                setState(() {
                  _showNotifications = value;
                });
              },
            ),
            ListTile(
              title: const Text('Notification Count'),
              subtitle: Text('Current count: $_notificationCount'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _notificationCount > 0
                        ? () => setState(() => _notificationCount--)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _notificationCount++),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleHeaderDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SimpleAppHeader Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'A simplified header variant for specific screens',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SimpleAppHeader(
                title: 'Simple Header Example',
                showBackButton: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final currentUser = _demoUsers[_currentDemo % _demoUsers.length];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Tapped'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This would navigate to the user profile screen.'),
              const SizedBox(height: 16),
              Text(
                'User Details:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Name: ${currentUser.name.isNotEmpty ? currentUser.name : 'Not provided'}',
              ),
              Text('Email: ${currentUser.email}'),
              Text('Role: ${currentUser.roleName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to profile screen')),
                );
              },
              child: const Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }
}
