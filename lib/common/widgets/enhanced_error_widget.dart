import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Enhanced error widget with retry functionality and better UX
class EnhancedErrorWidget extends StatelessWidget {
  const EnhancedErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showDetails = false,
    this.errorDetails,
    this.icon = Icons.error_outline,
    this.retryButtonText = 'Try Again',
  });

  final String message;
  final VoidCallback? onRetry;
  final bool showDetails;
  final String? errorDetails;
  final IconData icon;
  final String retryButtonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Error icon with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.error, size: 40),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Error message
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Detailed error message
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),

          // Debug details (only in debug mode)
          if (kDebugMode && showDetails && errorDetails != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Debug Details',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    errorDetails!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Retry button
          if (onRetry != null) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Network error widget with specific network troubleshooting
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({super.key, required this.message, this.onRetry, this.onCheckConnection});

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onCheckConnection;

  @override
  Widget build(BuildContext context) {
    return EnhancedErrorWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.wifi_off_rounded,
      retryButtonText: 'Retry Connection',
    );
  }
}

/// Project not found error widget with navigation options
class ProjectNotFoundWidget extends StatelessWidget {
  const ProjectNotFoundWidget({super.key, required this.projectId, this.onGoBack, this.onGoHome});

  final String projectId;
  final VoidCallback? onGoBack;
  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Project not found icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.folder_off_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 40),
          ),

          const SizedBox(height: 24),

          Text(
            'Project Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              'The project you\'re looking for doesn\'t exist or has been removed.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),

          if (kDebugMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Project ID: $projectId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onGoBack != null) ...[
                OutlinedButton.icon(
                  onPressed: onGoBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (onGoHome != null) const SizedBox(width: 16),
              ],
              if (onGoHome != null)
                ElevatedButton.icon(
                  onPressed: onGoHome,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
