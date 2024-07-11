class TodoItem {
  final int id;
  bool checked;
  String description;

  TodoItem({
    required this.id,
    required this.checked,
    required this.description,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      checked: json['checked'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checked': checked,
      'description': description,
    };
  }

  TodoItem copyWith({int? id, bool? checked, String? description}) {
    return TodoItem(
      id: id ?? this.id,
      checked: checked ?? this.checked,
      description: description ?? this.description,
    );
  }
}
