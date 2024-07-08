class MealCategory {
  final String name;
  final String imagePath;

  MealCategory({required this.name, required this.imagePath});

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      name: json['name'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! MealCategory) {
      return false;
    }
    return name == other.name && imagePath == other.imagePath;
  }

  @override
  int get hashCode => name.hashCode ^ imagePath.hashCode;
}
