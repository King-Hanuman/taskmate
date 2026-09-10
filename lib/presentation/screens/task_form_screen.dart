import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmate/core/theme/app_colors.dart';
import 'package:taskmate/core/theme/app_typography.dart';
import 'package:taskmate/core/utils/validators.dart';
import 'package:taskmate/core/widgets/category_chip.dart';
import 'package:taskmate/data/services/auth_service.dart';
import 'package:taskmate/domain/entities/task.dart';
import 'package:taskmate/domain/enums/enums.dart';
import 'package:taskmate/presentation/bloc/task/task_bloc.dart';
import 'package:taskmate/presentation/bloc/task/task_event.dart';

/// Screen for creating or editing a task.
class TaskFormScreen extends StatefulWidget {
  final Task? existingTask; // null = create, non-null = edit

  const TaskFormScreen({super.key, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;

  TaskCategory _category = TaskCategory.kuliah;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.belumDikerjakan;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  List<String> _tags = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _tagController = TextEditingController();

    if (task != null) {
      _category = task.category;
      _priority = task.priority;
      _status = task.status;
      _deadline = task.deadline;
      _tags = List.from(task.customTags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline),
      );

      if (time != null && mounted) {
        setState(() {
          _deadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authService = context.read<AuthService>();
    final now = DateTime.now();

    final task = Task(
      id: widget.existingTask?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _category,
      customTags: _tags,
      deadline: _deadline,
      priority: _priority,
      status: _status,
      isArchived: widget.existingTask?.isArchived ?? false,
      createdAt: widget.existingTask?.createdAt ?? now,
      updatedAt: now,
      userId: authService.currentUser!.uid,
    );

    if (_isEditing) {
      context.read<TaskBloc>().add(TaskUpdate(task));
    } else {
      context.read<TaskBloc>().add(TaskCreate(task));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Tugas' : 'Tugas Baru',
          style: AppTypography.h4(Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── TITLE ──
            Text('Judul Tugas *',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              validator: Validators.validateTitle,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Contoh: Laporan Praktikum Fisika',
              ),
            ),

            const SizedBox(height: 20),

            // ── DESCRIPTION ──
            Text('Deskripsi / Catatan',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Detail tugas, referensi, catatan penting...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            // ── CATEGORY ──
            Text('Kategori',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values
                  .map((cat) => CategoryChip(
                        category: cat,
                        isSelected: _category == cat,
                        onTap: () => setState(() => _category = cat),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── TAGS ──
            Text('Tag Kustom',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Tambah tag...',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_circle_rounded),
                  color: AppColors.primary,
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag,
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon:
                              const Icon(Icons.close_rounded, size: 16),
                          onDeleted: () =>
                              setState(() => _tags.remove(tag)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // ── DEADLINE ──
            Text('Tenggat Waktu *',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardAlt
                        : const Color(0xFFE0E0E8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID')
                          .format(_deadline),
                      style: AppTypography.bodyMedium(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.edit_calendar_rounded,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── PRIORITY ──
            Text('Prioritas',
                style: AppTypography.labelMedium(
                    Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 10),
            SegmentedButton<TaskPriority>(
              segments: TaskPriority.values.map((p) {
                Color c;
                switch (p) {
                  case TaskPriority.high:
                    c = AppColors.error;
                    break;
                  case TaskPriority.medium:
                    c = AppColors.warning;
                    break;
                  case TaskPriority.low:
                    c = AppColors.secondary;
                    break;
                }
                return ButtonSegment(
                  value: p,
                  label: Text(p.label, style: TextStyle(color: _priority == p ? c : null)),
                  icon: Icon(
                    p == TaskPriority.high
                        ? Icons.keyboard_double_arrow_up_rounded
                        : p == TaskPriority.medium
                            ? Icons.drag_handle_rounded
                            : Icons.keyboard_double_arrow_down_rounded,
                    size: 18,
                    color: _priority == p ? c : null,
                  ),
                );
              }).toList(),
              selected: {_priority},
              onSelectionChanged: (val) =>
                  setState(() => _priority = val.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // ── STATUS (only when editing) ──
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Text('Status',
                  style: AppTypography.labelMedium(
                      Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 10),
              SegmentedButton<TaskStatus>(
                segments: TaskStatus.values
                    .map((s) => ButtonSegment(
                          value: s,
                          label: Text(s.label,
                              style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                selected: {_status},
                onSelectionChanged: (val) =>
                    setState(() => _status = val.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 36),

            // ── SUBMIT BUTTON ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditing
                        ? Icons.save_rounded
                        : Icons.add_task_rounded),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Buat Tugas'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
