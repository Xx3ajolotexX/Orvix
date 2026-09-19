class Task {
  int? id;
  String title;
  String subject; // Materia (ej. "Matemáticas", "Historia")
  DateTime dueDate;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Convierte la tarea a un mapa para guardarla en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Crea una tarea a partir de un registro de la base de datos
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}