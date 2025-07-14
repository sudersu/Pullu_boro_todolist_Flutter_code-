class Task {
  final String id;
  final String title;
  final String dueDate; // YYYY-MM-DD format
  final String dueTime; // HH:MM format
  final bool reminder;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.dueTime,
    required this.reminder,
    required this.completed,
  });

  // Convert Task to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'reminder': reminder,
      'completed': completed,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      dueDate: json['dueDate'] ?? '',
      dueTime: json['dueTime'] ?? '',
      reminder: json['reminder'] ?? false,
      completed: json['completed'] ?? false,
    );
  }

  // Create a copy of Task with modified fields
  Task copyWith({
    String? id,
    String? title,
    String? dueDate,
    String? dueTime,
    bool? reminder,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      reminder: reminder ?? this.reminder,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, dueDate: $dueDate, dueTime: $dueTime, reminder: $reminder, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}