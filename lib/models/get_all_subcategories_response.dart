class GetAllSubCategoriesResponse {
  bool? success;
  List<SubCategories>? subCategories;

  GetAllSubCategoriesResponse({this.success, this.subCategories});

  GetAllSubCategoriesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (subCategories != null) {
      data['subCategories'] = subCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_subcategories = GetAllSubCategoriesResponse;

class SubCategories {
  String? sId;
  String? name;
  String? image;
  String? categoryId;
  String? createdAt;
  int? iV;

  SubCategories({
    this.sId,
    this.name,
    this.image,
    this.categoryId,
    this.createdAt,
    this.iV,
  });

  SubCategories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    image = json['image'] as String?;
    categoryId = json['categoryId'] as String?;
    createdAt = json['createdAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    data['categoryId'] = categoryId;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
