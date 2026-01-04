import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/search_alert.dart';

class AlertService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Créer une alerte basée sur les filtres actuels
  Future<void> createAlert({
    required String brand,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final alert = SearchAlert(
      id: '',
      userId: user.uid,
      brand: brand,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minYear: minYear,
      maxYear: maxYear,
      createdAt: DateTime.now(),
    );

    await _db.collection('alerts').add(alert.toMap());
  }

  // Récupérer les alertes de l'utilisateur
  Stream<List<SearchAlert>> getUserAlerts() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('alerts')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SearchAlert.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Supprimer une alerte
  Future<void> deleteAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).delete();
  }
}
