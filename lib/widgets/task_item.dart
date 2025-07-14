import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.completed;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: isCompleted ? 1 : 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (_) => onToggleComplete(),
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted 
                ? theme.colorScheme.onSurface.withOpacity(0.6)
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.reminder && !isCompleted)
              Icon(
                Icons.notifications_active,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (task.dueDate.isEmpty && task.dueTime.isEmpty) return null;

    final theme = Theme.of(context);
    String subtitle = '';

    if (task.dueDate.isNotEmpty) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(task.dueDate);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final taskDate = DateTime(date.year, date.month, date.day);

        if (taskDate == today) {
          subtitle = 'Today';
        } else if (taskDate == today.add(const Duration(days: 1))) {
          subtitle = 'Tomorrow';
        } else if (taskDate == today.subtract(const Duration(days: 1))) {
          subtitle = 'Yesterday';
        } else {
          subtitle = DateFormat('MMM dd, yyyy').format(date);
        }
      } catch (e) {
        subtitle = task.dueDate;
      }
    }

    if (task.dueTime.isNotEmpty) {
      try {
        final time = DateFormat('HH:mm').parse(task.dueTime);
        final timeStr = DateFormat('h:mm a').format(time);
        subtitle = subtitle.isEmpty ? timeStr : '$subtitle at $timeStr';
      } catch (e) {
        final timeStr = task.dueTime;
        subtitle = subtitle.isEmpty ? timeStr : '$subtitle at $timeStr';
      }
    }

    // Check if task is overdue
    bool isOverdue = false;
    if (task.dueDate.isNotEmpty && task.dueTime.isNotEmpty && !task.completed) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(task.dueDate);
        final time = DateFormat('HH:mm').parse(task.dueTime);
        final dueDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        isOverdue = dueDateTime.isBefore(DateTime.now());
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return Text(
      subtitle,
      style: theme.textTheme.bodySmall?.copyWith(
        color: isOverdue 
            ? theme.colorScheme.error 
            : theme.colorScheme.onSurface.withOpacity(0.7),
        decoration: task.completed ? TextDecoration.lineThrough : null,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}