class ToDo {
  final String id;
  final String todoText;
  final bool isDone;

  ToDo({
    required this.id,
    this.todoText = '',
    this.isDone = false,
  });

  @override
  bool operator ==(covariant ToDo other) {
    if (identical(this, other)) return true;

    return other.id == id && other.todoText == todoText && other.isDone == isDone;
  }

  @override
  int get hashCode => id.hashCode ^ todoText.hashCode ^ isDone.hashCode;

  ToDo copyWith({
    String? id,
    String? todoText,
    bool? isDone,
  }) {
    return ToDo(
      id: id ?? this.id,
      todoText: todoText ?? this.todoText,
      isDone: isDone ?? this.isDone,
    );
  }
}
