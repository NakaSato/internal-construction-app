import 'package:flutter/material.dart';

/// A reusable empty state widget for work request lists
class WorkRequestEmptyState extends StatelessWidget {
  const WorkRequestEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.action,
    this.illustration,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? action;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 24),
            ] else ...[
              Icon(
                icon,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// A reusable error state widget for work request lists
class WorkRequestErrorState extends StatelessWidget {
  const WorkRequestErrorState({
    super.key,
    required this.title,
    required this.description,
    this.onRetry,
    this.retryButtonLabel = 'Retry',
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String retryButtonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable loading state widget for work request lists
class WorkRequestLoadingState extends StatelessWidget {
  const WorkRequestLoadingState({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable shimmer loading effect for work request cards
class WorkRequestCardShimmer extends StatefulWidget {
  const WorkRequestCardShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  State<WorkRequestCardShimmer> createState() => _WorkRequestCardShimmerState();
}

class _WorkRequestCardShimmerState extends State<WorkRequestCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface.withOpacity(
                                      _animation.value * 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 12,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface.withOpacity(
                                      _animation.value * 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withOpacity(
                                _animation.value * 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacity(
                            _animation.value * 0.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacity(
                            _animation.value * 0.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
