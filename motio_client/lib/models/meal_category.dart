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
}
