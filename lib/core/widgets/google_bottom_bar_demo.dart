import 'package:flutter/material.dart';
import 'google_bottom_bar.dart';

/// Demo screen showing the GoogleBottomBar component
class GoogleBottomBarDemo extends StatefulWidget {
  const GoogleBottomBarDemo({super.key});

  @override
  State<GoogleBottomBarDemo> createState() => _GoogleBottomBarDemoState();
}

class _GoogleBottomBarDemoState extends State<GoogleBottomBarDemo> {
  int _currentIndex = 0;

  final List<String> _pageNames = [
    'Dashboard',
    'Featured',
    'Calendar',
    'Location',
    'Profile',
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.star,
    Icons.calendar_today,
    Icons.location_on,
    Icons.person,
  ];

  final List<Color> _pageColors = [
    Colors.blue,
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleBottomBar Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _pageIcons[_currentIndex],
              size: 120,
              color: _pageColors[_currentIndex],
            ),
            const SizedBox(height: 32),
            Text(
              _pageNames[_currentIndex],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _pageColors[_currentIndex],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Currently viewing the ${_pageNames[_currentIndex]} page',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'GoogleBottomBar Features:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Beautiful Material Design 3 styling\n'
                    '• Smooth animations and transitions\n'
                    '• Customizable colors and margins\n'
                    '• Built with Salomon Bottom Bar\n'
                    '• Google-style shadow and rounded corners',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GoogleBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // You can customize the appearance:
        // backgroundColor: Colors.white,
        // selectedItemColor: Colors.blue,
        // unselectedItemColor: Colors.grey,
        // margin: EdgeInsets.all(20),
      ),
    );
  }
}
