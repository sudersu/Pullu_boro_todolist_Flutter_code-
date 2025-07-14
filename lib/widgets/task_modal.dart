import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskModal extends StatefulWidget {
  final Task? task; // null for new task, existing task for editing
  final Function(Map<String, dynamic>) onSave;

  const TaskModal({
    Key? key,
    this.task,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _reminderEnabled = widget.task!.reminder;
      
      // Parse existing date
      if (widget.task!.dueDate.isNotEmpty) {
        try {
          _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.task!.dueDate);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
      
      // Parse existing time
      if (widget.task!.dueTime.isNotEmpty) {
        try {
          final time = DateFormat('HH:mm').parse(widget.task!.dueTime);
          _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
        } catch (e) {
          print('Error parsing time: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _clearTime() {
    setState(() {
      _selectedTime = null;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final taskData = {
      'title': _titleController.text.trim(),
      'dueDate': _selectedDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!) 
          : '',
      'dueTime': _selectedTime != null 
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '',
      'reminder': _reminderEnabled,
    };

    // Add task ID if editing
    if (widget.task != null) {
      taskData['id'] = widget.task!.id;
    }

    widget.onSave(taskData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task != null ? 'Edit Task' : 'Add New Task',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                        autofocus: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Date selector
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _selectedDate != null 
                                    ? _formatDate(_selectedDate!)
                                    : 'Select Date',
                              ),
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _clearDate,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear date',
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time selector
                      Text(
                        'Due Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _selectedTime != null 
                                    ? _formatTime(_selectedTime!)
                                    : 'Select Time',
                              ),
                            ),
                          ),
                          if (_selectedTime != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _clearTime,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear time',
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Reminder toggle
                      SwitchListTile(
                        title: const Text('Set Reminder'),
                        subtitle: const Text('Get notified at the due time'),
                        value: _reminderEnabled,
                        onChanged: (value) {
                          setState(() {
                            _reminderEnabled = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _saveTask,
                    child: Text(widget.task != null ? 'Update' : 'Add Task'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}