import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mecity_marketplace/models/product.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final double maxDiscountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<Product> eventProducts;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.maxDiscountPercent,
    required this.startDate,
    required this.endDate,
    required this.eventProducts,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'maxDiscountPercent': maxDiscountPercent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'eventProducts': eventProducts.map((p) => p.toMap()).toList(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return EventModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      maxDiscountPercent: (map['maxDiscountPercent'] ?? 0.0).toDouble(),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : DateTime.now().add(const Duration(days: 2)),
      eventProducts: map['eventProducts'] != null
          ? (map['eventProducts'] as List).map((p) => Product.fromMap(Map<String, dynamic>.from(p))).toList()
          : [],
    );
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EventModel.fromMap(data, doc.id);
  }

  factory EventModel.fromApiJson(Map<String, dynamic> json) {
    String rawBanner = '';
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      rawBanner = (json['images'][0]).toString();
    }
    if (rawBanner.isNotEmpty && !rawBanner.startsWith('http')) {
      rawBanner = 'https://marketplace.mecity.in/$rawBanner';
    }

    return EventModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      bannerUrl: rawBanner,
      maxDiscountPercent: 0.0, // Event schema doesn't seem to have discount direct field unless custom
      startDate: json['start_Date'] != null ? DateTime.parse(json['start_Date']) : DateTime.now(),
      endDate: json['Finish_Date'] != null ? DateTime.parse(json['Finish_Date']) : DateTime.now().add(const Duration(days: 2)),
      eventProducts: [], // For API, we might not get full products array in list, just product ID or similar. Empty for now to be safe.
    );
  }
}
