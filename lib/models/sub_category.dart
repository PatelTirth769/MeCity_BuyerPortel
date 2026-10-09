class SubCategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String categoryId;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryId,
  });

  factory SubCategoryModel.fromApiJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final rawName = (json['name'] ?? json['title'] ?? '').toString();
    final rawCategoryId = (json['categoryId'] ?? '').toString();
    
    String rawImage = (json['image'] ?? json['imageUrl'] ?? '').toString();
    if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      rawImage = 'https://marketplace.mecity.in/$rawImage';
    }

    return SubCategoryModel(
      id: rawId.toString(),
      name: rawName,
      imageUrl: rawImage,
      categoryId: rawCategoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    };
  }
}
