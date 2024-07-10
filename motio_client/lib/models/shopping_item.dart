class ShoppingItem {
  final int id;
  bool checked;
  String description;

  ShoppingItem({
    required this.id,
    required this.checked,
    required this.description,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
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

  ShoppingItem copyWith({int? id, bool? checked, String? description}) {
    return ShoppingItem(
      id: id ?? this.id,
      checked: checked ?? this.checked,
      description: description ?? this.description,
    );
  }
}
