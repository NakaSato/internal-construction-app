import 'package:flutter/material.dart';
import 'core/widgets/main_screen.dart';

void main() {
  runApp(const GoogleBottomBarApp());
}

class GoogleBottomBarApp extends StatelessWidget {
  const GoogleBottomBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoogleBottomBar with Featured Partners',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
