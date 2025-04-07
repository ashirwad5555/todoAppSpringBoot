class Todo {
  String? id;
  String title;
  bool isDone;
  DateTime? createdAt;
  DateTime? updatedAt;
  int position; // Add this field

  Todo({
    this.id,
    required this.title,
    required this.isDone,
    this.createdAt,
    this.updatedAt,
    this.position = 0, // Default value
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isDone: json['done'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': isDone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'position': position,
    };
  }
}
