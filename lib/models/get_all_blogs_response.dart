class GetAllBlogsResponse {
  bool? success;
  List<Blogs>? blogs;

  GetAllBlogsResponse({this.success, this.blogs});

  GetAllBlogsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['blogs'] != null) {
      blogs = <Blogs>[];
      json['blogs'].forEach((v) {
        if (v != null) {
          blogs!.add(Blogs.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (blogs != null) {
      data['blogs'] = blogs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_blogs = GetAllBlogsResponse;

class Blogs {
  String? sId;
  String? title;
  String? shortDescription;
  String? content;
  String? image;
  String? author;
  String? createdAt;
  int? iV;

  Blogs({
    this.sId,
    this.title,
    this.shortDescription,
    this.content,
    this.image,
    this.author,
    this.createdAt,
    this.iV,
  });

  Blogs.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    title = json['title'] as String?;
    shortDescription = json['shortDescription'] as String?;
    content = json['content'] as String?;
    image = json['image'] as String?;
    author = json['author'] as String?;
    createdAt = json['createdAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['shortDescription'] = shortDescription;
    data['content'] = content;
    data['image'] = image;
    data['author'] = author;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
