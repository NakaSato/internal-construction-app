import 'package:flutter/material.dart';
import 'core/widgets/enhanced_bottom_bar_demo.dart';

void main() {
  runApp(const EnhancedBottomBarApp());
}

class EnhancedBottomBarApp extends StatelessWidget {
  const EnhancedBottomBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced GoogleBottomBar with Featured Partners',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const EnhancedBottomBarDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
