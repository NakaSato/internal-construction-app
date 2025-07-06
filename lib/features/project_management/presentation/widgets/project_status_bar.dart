import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/project_bloc.dart';

/// Widget for displaying project status bar with live updates and sync controls
class ProjectStatusBar extends StatelessWidget {
  final bool isRealtimeConnected;
  final bool isLiveReloadEnabled;
  final bool isSilentRefreshing;
  final VoidCallback onToggleLiveReload;
  final VoidCallback onManualSync;

  const ProjectStatusBar({
    super.key,
    required this.isRealtimeConnected,
    required this.isLiveReloadEnabled,
    required this.isSilentRefreshing,
    required this.onToggleLiveReload,
    required this.onManualSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Real-time connection status
          _buildConnectionStatus(context),
          const SizedBox(height: 12),
          // Project count and controls row
          _buildControlsRow(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRealtimeConnected ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRealtimeConnected ? Colors.green : Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
            color: isRealtimeConnected ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isRealtimeConnected ? 'Live Updates Active' : 'Reconnecting...',
            style: TextStyle(
              color: isRealtimeConnected ? Colors.green.shade700 : Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isSilentRefreshing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isRealtimeConnected ? Colors.green : Colors.orange,
              ),
            ),
          ],
          if (isRealtimeConnected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.circle, color: Colors.green, size: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context) {
    return BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
      builder: (context, projectState) {
        return Row(
          children: [
            // Project Count Badge
            if (projectState is EnhancedProjectsLoaded) ...[
              _buildProjectCountBadge(context, projectState),
              const SizedBox(width: 12),
            ],
            // Live Reload Status Badge
            _buildLiveReloadBadge(context),
            const Spacer(),
            // Manual Database Sync Button
            _buildSyncButton(context),
          ],
        );
      },
    );
  }

  Widget _buildProjectCountBadge(BuildContext context, EnhancedProjectsLoaded state) {
    final count = state.projectsResponse.totalCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            count == 1 ? 'project' : 'projects',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveReloadBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLiveReloadEnabled
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiveReloadEnabled ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiveReloadEnabled ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: isLiveReloadEnabled
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            isLiveReloadEnabled ? 'Live Updates: ON' : 'Live Updates: OFF',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isLiveReloadEnabled
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSilentRefreshing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToggleLiveReload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLiveReloadEnabled
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isLiveReloadEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  color: isLiveReloadEnabled
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return GestureDetector(
      onTap: onManualSync,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Sync DB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
