import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String title;
  final String iconName;
  final IconData icon;
  final String imageUrl;
  final List<String> subcategories;
  final int itemCount;

  CategoryModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.icon,
    required this.imageUrl,
    required this.subcategories,
    this.itemCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'subcategories': subcategories,
      'itemCount': itemCount,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CategoryModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      iconName: map['iconName'] ?? 'grid_view',
      icon: _getIconFromName(map['iconName'] ?? 'grid_view'),
      imageUrl: map['imageUrl'] ?? '',
      subcategories: List<String>.from(map['subcategories'] ?? []),
      itemCount: map['itemCount'] ?? 0,
    );
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel.fromMap(data, doc.id);
  }

  static String cleanCategoryTitle(String raw) {
    var title = raw.trim();
    if (title.contains('\n')) {
      title = title.split('\n').first.trim();
    }
    if (RegExp(r'^\d+\.\s*').hasMatch(title)) {
      title = title.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
    }
    if (title.toLowerCase() == 'automobility') {
      return 'Automobility';
    }
    return title.isNotEmpty ? title : 'General';
  }

  /// Parse a category object returned by the Mecity Web API
  /// (GET /api/v2/category/get-all-categories).
  factory CategoryModel.fromApiJson(Map<String, dynamic> json) {
    // API may use '_id' or 'id'
    final rawId = json['_id'] ?? json['id'] ?? '';
    // API may use 'name' or 'title'
    final rawTitle = (json['name'] ?? json['title'] ?? '').toString();
    final cleanTitle = cleanCategoryTitle(rawTitle);

    // API may use 'image', 'imageUrl', or 'categoryImage'
    String rawImage =
        (json['image'] ?? json['imageUrl'] ?? json['categoryImage'] ?? '')
            .toString();
    if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      rawImage = 'https://marketplace.mecity.in/$rawImage';
    }
    // Sub-categories: may be list of strings or list of objects with 'name'
    final rawSubs = json['subCategories'] ?? json['subcategories'] ?? [];
    final List<String> subs = (rawSubs as List).map((s) {
      if (s is String) return s;
      if (s is Map) return (s['name'] ?? '').toString();
      return s.toString();
    }).toList();

    return CategoryModel(
      id: rawId.toString(),
      title: cleanTitle,
      iconName: 'grid_view',
      icon: _getIconFromName(cleanTitle.toLowerCase()),
      imageUrl: rawImage,
      subcategories: subs,
      itemCount: json['productCount'] ?? json['itemCount'] ?? 0,
    );
  }


  static IconData _getIconFromName(String iconName) {
    if (iconName.contains('electron') || iconName.contains('device')) {
      return Icons.devices_other_rounded;
    }
    if (iconName.contains('fashion') ||
        iconName.contains('cloth') ||
        iconName.contains('wear')) {
      return Icons.checkroom_rounded;
    }
    if (iconName.contains('kitchen') || iconName.contains('home')) {
      return Icons.soup_kitchen_rounded;
    }
    if (iconName.contains('grocery') || iconName.contains('food')) {
      return Icons.shopping_basket_rounded;
    }
    if (iconName.contains('beauty') ||
        iconName.contains('spa') ||
        iconName.contains('health')) {
      return Icons.spa_rounded;
    }
    if (iconName.contains('tool') || iconName.contains('build')) {
      return Icons.build_circle_rounded;
    }
    switch (iconName) {
      case 'devices':
        return Icons.devices_other_rounded;
      case 'checkroom':
        return Icons.checkroom_rounded;
      case 'kitchen':
        return Icons.soup_kitchen_rounded;
      case 'shopping_basket':
        return Icons.shopping_basket_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'build':
        return Icons.build_circle_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
