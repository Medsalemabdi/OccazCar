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
    // ATTENTION : Firestore ne permet pas de filtrer sur deux champs différents
    // avec des inégalités (ex: price > 1000 ET year > 2010) sans index complexe.
    // Il vaut mieux faire le filtrage "lourd" côté Flutter (comme dans votre précédent message)
    // ou s'assurer que les index existent.

    // Si vous gardez ceci, vérifiez votre console DEBUG, Firestore vous donnera un lien
    // pour créer l'index manquant. Cliquez dessus !

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

    // PROBLEME ICI : Si on filtre par Prix/Année, on ne peut pas trier par Date
    // sans index. Pour l'instant, enlevons le tri si des filtres sont actifs,
    // ou trions par le champ filtré.

    // Si aucun filtre d'inégalité n'est appliqué, on trie par date.
    if (minYear == null && maxYear == null && minPrice == null && maxPrice == null) {
      return query.orderBy('createdAt', descending: true);
    }

    return query;
  }
}
