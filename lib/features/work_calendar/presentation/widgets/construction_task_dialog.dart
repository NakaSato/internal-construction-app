import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/construction_task.dart';

/// Dialog for viewing and editing construction task details
class ConstructionTaskDialog extends StatefulWidget {
  const ConstructionTaskDialog({
    super.key,
    this.task,
    required this.projectId,
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onTaskDeleted,
  });

  final ConstructionTask? task;
  final String projectId;
  final Function(ConstructionTask)? onTaskCreated;
  final Function(ConstructionTask)? onTaskUpdated;
  final Function(String)? onTaskDeleted;

  @override
  State<ConstructionTaskDialog> createState() => _ConstructionTaskDialogState();
}

class _ConstructionTaskDialogState extends State<ConstructionTaskDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assignedTeamController;
  late final TextEditingController _estimatedHoursController;
  late final TextEditingController _actualHoursController;
  late final TextEditingController _notesController;
  late final TextEditingController _materialController;

  late DateTime _startDate;
  late DateTime _endDate;
  late TaskStatus _status;
  late TaskPriority _priority;
  late double _progress;
  List<String> _materials = [];
  List<String> _dependencies = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadTaskData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _assignedTeamController = TextEditingController();
    _estimatedHoursController = TextEditingController();
    _actualHoursController = TextEditingController();
    _notesController = TextEditingController();
    _materialController = TextEditingController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _loadTaskData() {
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _assignedTeamController.text = task.assignedTeam ?? '';
      _estimatedHoursController.text = task.estimatedHours?.toString() ?? '';
      _actualHoursController.text = task.actualHours?.toString() ?? '';
      _notesController.text = task.notes ?? '';
      _startDate = task.startDate;
      _endDate = task.endDate;
      _status = task.status;
      _priority = task.priority;
      _progress = task.progress;
      _materials = List.from(task.materials);
      _dependencies = List.from(task.dependencies);
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 1));
      _status = TaskStatus.notStarted;
      _priority = TaskPriority.medium;
      _progress = 0.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedTeamController.dispose();
    _estimatedHoursController.dispose();
    _actualHoursController.dispose();
    _notesController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(child: _buildBody()),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEditing ? Icons.edit_calendar : Icons.add_task,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Edit Construction Task'
                      : 'New Construction Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Project: ${widget.projectId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildDatesAndProgress(),
          const SizedBox(height: 24),
          _buildStatusAndPriority(),
          const SizedBox(height: 24),
          _buildTeamAndHours(),
          const SizedBox(height: 24),
          _buildMaterialsSection(),
          const SizedBox(height: 24),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _titleController,
          label: 'Task Title',
          hint: 'Enter task title',
          icon: Icons.title,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter detailed description',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDatesAndProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Timeline & Progress'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                date: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date',
                date: _endDate,
                onDateSelected: (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressSlider(),
      ],
    );
  }

  Widget _buildStatusAndPriority() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status & Priority'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField<TaskStatus>(
                label: 'Status',
                value: _status,
                items: TaskStatus.values,
                itemBuilder: (status) => status.displayName,
                onChanged: (status) => setState(() => _status = status!),
                icon: Icons.flag,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField<TaskPriority>(
                label: 'Priority',
                value: _priority,
                items: TaskPriority.values,
                itemBuilder: (priority) => priority.displayName,
                onChanged: (priority) => setState(() => _priority = priority!),
                icon: Icons.priority_high,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamAndHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Team & Hours'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _assignedTeamController,
          label: 'Assigned Team',
          hint: 'Enter team or individual name',
          icon: Icons.group,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _estimatedHoursController,
                label: 'Estimated Hours',
                hint: '0.0',
                icon: Icons.schedule,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _actualHoursController,
                label: 'Actual Hours',
                hint: '0.0',
                icon: Icons.access_time,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Materials & Equipment'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _materialController,
                label: 'Add Material',
                hint: 'Enter material name',
                icon: Icons.construction,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add_circle),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        if (_materials.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Materials:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _materials.map((material) {
                    return Chip(
                      label: Text(material),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeMaterial(material),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Additional Notes'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _notesController,
          label: 'Notes',
          hint: 'Add any additional notes or comments',
          icon: Icons.notes,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: required
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(date, onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _progress,
            onChanged: (value) => setState(() => _progress = value),
            divisions: 20,
            label: '${(_progress * 100).toInt()}%',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required Function(T?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemBuilder(item)));
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (_isEditing) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleteTask,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _saveTask,
              icon: Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? 'Update Task' : 'Create Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    DateTime currentDate,
    Function(DateTime) onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  void _addMaterial() {
    final material = _materialController.text.trim();
    if (material.isNotEmpty && !_materials.contains(material)) {
      setState(() {
        _materials.add(material);
        _materialController.clear();
      });
    }
  }

  void _removeMaterial(String material) {
    setState(() {
      _materials.remove(material);
    });
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final task = ConstructionTask(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      projectId: widget.projectId,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      status: _status,
      progress: _progress,
      priority: _priority,
      assignedTeam: _assignedTeamController.text.trim().isNotEmpty
          ? _assignedTeamController.text.trim()
          : null,
      estimatedHours: double.tryParse(_estimatedHoursController.text),
      actualHours: double.tryParse(_actualHoursController.text),
      materials: _materials,
      dependencies: _dependencies,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      completedBy: _status == TaskStatus.completed ? 'System User' : null,
      completedAt: _status == TaskStatus.completed ? DateTime.now() : null,
    );

    if (_isEditing) {
      widget.onTaskUpdated?.call(task);
    } else {
      widget.onTaskCreated?.call(task);
    }

    Navigator.of(context).pop();
  }

  void _deleteTask() {
    if (widget.task?.id != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onTaskDeleted?.call(widget.task!.id);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close task dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
