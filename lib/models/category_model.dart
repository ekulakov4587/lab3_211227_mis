class Category {
  final String id;
  final String name;
  final String thumb;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.thumb,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'],
      name: json['strCategory'],
      thumb: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }
}
