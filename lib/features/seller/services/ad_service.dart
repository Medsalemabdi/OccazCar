// @/OccazCar/lib/features/seller/services/ad_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AdService {
  final CollectionReference<Map<String, dynamic>> _adsCollection =
  FirebaseFirestore.instance.collection('ads');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ====================================================================
  //               CODE MANQUANT RESTAURÉ ICI
  // ====================================================================

  Future<void> publishAd(Map<String, dynamic> adData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Aucun utilisateur n'est connecté.");
    }
    adData['sellerId'] = currentUser.uid;
    adData['createdAt'] = Timestamp.now();
    await _adsCollection.add(adData);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAdsForSeller(String sellerId) {
    // Le code qui manquait est maintenant ici
    return _adsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateAd(String adId, Map<String, dynamic> updatedData) async {
    // Le code qui manquait est maintenant ici
    await _adsCollection.doc(adId).update(updatedData);
  }

  // ====================================================================

  /// Prend un fichier image et le téléverse sur Firebase Storage.
  Future<String> uploadImage(File imageFile) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference storageRef = _storage.ref().child('ad_images').child(fileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors de l'upload de l'image: $e");
      throw Exception("L'upload de l'image a échoué.");
    }
  }

  /// Supprime une image de Firebase Storage à partir de son URL.
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.contains('firebasestorage')) return;
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Erreur non bloquante lors de la suppression de l'image: $e");
    }
  }

  /// Supprime une annonce de Firestore ET ses images de Storage.
  Future<void> deleteAd(String adId) async {
    try {
      final adDoc = await _adsCollection.doc(adId).get();
      if (adDoc.exists && adDoc.data()?['sellerId'] == _auth.currentUser?.uid) {
        final List<String> imageUrls = List<String>.from(adDoc.data()?['imageUrls'] ?? []);
        await _adsCollection.doc(adId).delete();
        await Future.wait(imageUrls.map((url) => deleteImage(url)));
      } else {
        throw Exception("Vous n'avez pas la permission de supprimer cette annonce.");
      }
    } catch (e) {
      print("Erreur lors de la suppression de l'annonce: $e");
      throw Exception("La suppression de l'annonce a échoué.");
    }
  }
}
