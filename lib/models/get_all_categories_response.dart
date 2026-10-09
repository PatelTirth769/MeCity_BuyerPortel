class GetAllCategoriesResponse {
  bool? success;
  List<Categories>? categories;

  GetAllCategoriesResponse({this.success, this.categories});

  GetAllCategoriesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_categories = GetAllCategoriesResponse;

class Categories {
  String? sId;
  String? name;
  String? image;
  String? createdAt;
  int? iV;

  Categories({this.sId, this.name, this.image, this.createdAt, this.iV});

  Categories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    image = json['image'] as String?;
    createdAt = json['createdAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
