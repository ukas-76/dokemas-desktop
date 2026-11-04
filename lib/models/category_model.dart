class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final int destinationsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.destinationsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
      destinationsCount: json['destinations_count'] ?? 0,
    );
  }
}
