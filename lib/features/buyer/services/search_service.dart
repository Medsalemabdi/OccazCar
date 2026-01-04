// Dans lib/features/buyer/services/search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final _ads = FirebaseFirestore.instance.collection('ads');

  Query<Map<String, dynamic>> buildQuery({
    String? brand,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
  }) {
    Query<Map<String, dynamic>> query = _ads;

    // 1. Filtre Marque (Égalité)
    if (brand != null && brand.isNotEmpty) {
      query = query.where('brand', isEqualTo: brand);
    }

    // 2. Filtres Inégalités (Prix/Année)

    if (minYear != null) {
      query = query.where('year', isGreaterThanOrEqualTo: minYear);
    }
    if (maxYear != null) {
      query = query.where('year', isLessThanOrEqualTo: maxYear);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }


    // Si aucun filtre d'inégalité n'est appliqué, on trie par date.
    if (minYear == null && maxYear == null && minPrice == null && maxPrice == null) {
      return query.orderBy('createdAt', descending: true);
    }

    return query;
  }
}
