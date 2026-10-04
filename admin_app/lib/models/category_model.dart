class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'category',
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'icon': icon};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'category',
    );
  }
}
