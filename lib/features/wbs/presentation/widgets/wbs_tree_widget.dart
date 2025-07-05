import 'package:flutter/material.dart';
import '../../domain/entities/wbs_structure.dart';
import '../../domain/entities/wbs_task.dart';

class WbsTreeWidget extends StatelessWidget {
  const WbsTreeWidget({
    super.key,
    required this.wbsStructure,
    this.selectedTask,
    this.onTaskSelected,
    this.onTaskStatusChanged,
  });

  final WbsStructure wbsStructure;
  final WbsTask? selectedTask;
  final Function(WbsTask task)? onTaskSelected;
  final Function(String taskId, WbsTaskStatus status)? onTaskStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (wbsStructure.rootTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No WBS tasks found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: wbsStructure.rootTasks.length,
      itemBuilder: (context, index) {
        return WbsTaskNode(
          task: wbsStructure.rootTasks[index],
          isSelected: selectedTask?.id == wbsStructure.rootTasks[index].id,
          onTaskSelected: onTaskSelected,
          onTaskStatusChanged: onTaskStatusChanged,
          level: 0,
        );
      },
    );
  }
}

class WbsTaskNode extends StatefulWidget {
  const WbsTaskNode({
    super.key,
    required this.task,
    required this.level,
    this.isSelected = false,
    this.onTaskSelected,
    this.onTaskStatusChanged,
  });

  final WbsTask task;
  final int level;
  final bool isSelected;
  final Function(WbsTask task)? onTaskSelected;
  final Function(String taskId, WbsTaskStatus status)? onTaskStatusChanged;

  @override
  State<WbsTaskNode> createState() => _WbsTaskNodeState();
}

class _WbsTaskNodeState extends State<WbsTaskNode> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChildren = widget.task.children.isNotEmpty;
    final indentWidth = widget.level * 24.0;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: indentWidth, bottom: 4),
          child: Material(
            color: widget.isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.onTaskSelected?.call(widget.task),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    // Expand/collapse button
                    if (hasChildren)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Icon(
                          _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      )
                    else
                      const SizedBox(width: 20),

                    const SizedBox(width: 8),

                    // Status indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.task.status, theme),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Task info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // WBS code
                              if (widget.task.wbsCode.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.task.wbsCode,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              if (widget.task.wbsCode.isNotEmpty) const SizedBox(width: 8),

                              // Task name
                              Expanded(
                                child: Text(
                                  widget.task.taskName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: widget.isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Task metadata
                          if (widget.task.assignedTo != null) const SizedBox(height: 4),

                          Row(
                            children: [
                              // Assigned user
                              if (widget.task.assignedTo != null) ...[
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.task.assignedTo!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // Due date
                              Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: widget.task.isOverdue
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(widget.task.endDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.task.isOverdue
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Progress indicator
                    if (widget.task.progressPercentage > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: widget.task.progressPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.task.status, theme),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Status change button
                    const SizedBox(width: 8),
                    PopupMenuButton<WbsTaskStatus>(
                      icon: Icon(Icons.more_vert, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      itemBuilder: (context) => WbsTaskStatus.values
                          .map(
                            (status) => PopupMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status, theme),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getStatusDisplayName(status)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onSelected: (status) {
                        widget.onTaskStatusChanged?.call(widget.task.id, status);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Children
        if (hasChildren && _isExpanded)
          ...widget.task.children.map(
            (child) => WbsTaskNode(
              task: child,
              level: widget.level + 1,
              isSelected: widget.isSelected && widget.task.id == child.id,
              onTaskSelected: widget.onTaskSelected,
              onTaskStatusChanged: widget.onTaskStatusChanged,
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(WbsTaskStatus status, ThemeData theme) {
    switch (status) {
      case WbsTaskStatus.notStarted:
        return theme.colorScheme.outline;
      case WbsTaskStatus.inProgress:
        return Colors.orange;
      case WbsTaskStatus.completed:
        return Colors.green;
      case WbsTaskStatus.blocked:
        return theme.colorScheme.error;
      case WbsTaskStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(WbsTaskStatus status) {
    switch (status) {
      case WbsTaskStatus.notStarted:
        return 'Not Started';
      case WbsTaskStatus.inProgress:
        return 'In Progress';
      case WbsTaskStatus.completed:
        return 'Completed';
      case WbsTaskStatus.blocked:
        return 'Blocked';
      case WbsTaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return '${difference}d';
    } else {
      return '${difference.abs()}d ago';
    }
  }
}
