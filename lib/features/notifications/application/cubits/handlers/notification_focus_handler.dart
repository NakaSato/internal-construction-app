import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/realtime_api_streams.dart';

/// Manages app focus events for notification updates
class NotificationFocusHandler {
  StreamSubscription? _appFocusSubscription;

  /// Set up app focus listener to refresh data when app comes back to foreground
  void setupAppFocusListener({required void Function() onFocusRegained}) {
    _appFocusSubscription?.cancel();

    try {
      final realtimeStreams = getIt<RealtimeApiStreams>();

      _appFocusSubscription = realtimeStreams.appFocusStream.listen((hasFocus) {
        if (hasFocus) {
          if (kDebugMode) {
            debugPrint('📱 NotificationFocusHandler: App focus returned, refreshing notifications');
          }
          onFocusRegained();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ NotificationFocusHandler: Failed to setup app focus listener: $e');
      }
    }
  }

  /// Add a focus listener for non-web platforms
  void addFocusListener({required void Function() onFocusRegained}) {
    if (kIsWeb) return;

    // This method will be called when the app regains focus
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // App has regained focus
        onFocusRegained();
      }
    });

    // Add the focus node to the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  /// Clean up resources
  void dispose() {
    _appFocusSubscription?.cancel();
  }
}
