import 'package:cloud_firestore/cloud_firestore.dart';

class SearchAlert {
  final String id;
  final String userId;
  final String brand;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final DateTime createdAt;

  SearchAlert({
    required this.id,
    required this.userId,
    required this.brand,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'brand': brand,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minYear': minYear,
      'maxYear': maxYear,
      'createdAt': createdAt,
    };
  }

  factory SearchAlert.fromMap(String id, Map<String, dynamic> map) {
    return SearchAlert(
      id: id,
      userId: map['userId'] ?? '',
      brand: map['brand'] ?? '',
      minPrice: (map['minPrice'] as num?)?.toDouble(),
      maxPrice: (map['maxPrice'] as num?)?.toDouble(),
      minYear: map['minYear'] as int?,
      maxYear: map['maxYear'] as int?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
