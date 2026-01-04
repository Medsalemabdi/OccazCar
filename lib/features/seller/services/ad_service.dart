// @/OccazCar/lib/features/seller/services/ad_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart'; // <--- INDISPENSABLE

class AdService {
  final CollectionReference<Map<String, dynamic>> _adsCollection =
  FirebaseFirestore.instance.collection('ads');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configuration Cloudinary
  // Note : Assurez-vous que 'dmxcuddqs' et 'occazcar_preset' sont corrects
  final cloudinary = CloudinaryPublic('dmxcuddqs', 'occazcar_preset', cache: false);

  /// Publier une nouvelle annonce
  Future<void> publishAd(Map<String, dynamic> adData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Aucun utilisateur n'est connecté.");
    }
    adData['sellerId'] = currentUser.uid;
    adData['createdAt'] = Timestamp.now();
    await _adsCollection.add(adData);
  }

  /// Récupérer les annonces du vendeur connecté
  Stream<QuerySnapshot<Map<String, dynamic>>> getAdsForSeller(String sellerId) {
    return _adsCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Mettre à jour une annonce
  Future<void> updateAd(String adId, Map<String, dynamic> updatedData) async {
    await _adsCollection.doc(adId).update(updatedData);
  }

  /// Upload une image vers Cloudinary
  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'ad_images',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print("Erreur Cloudinary: $e");
      throw Exception("Impossible d'envoyer l'image. Vérifiez votre connexion.");
    }
  }
  /// Envoie une LISTE d'images et retourne une LISTE de liens
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    try {
      // On lance tous les uploads en même temps (en parallèle) pour aller plus vite
      List<Future<String>> uploadTasks = images.map((image) => uploadImage(image)).toList();

      // On attend que TOUTES les images soient finies
      List<String> urls = await Future.wait(uploadTasks);

      return urls; // Retourne ex: ["https://...img1.jpg", "https://...img2.jpg"]
    } catch (e) {
      print("Erreur lors de l'upload multiple: $e");
      throw Exception("Erreur lors de l'envoi des photos.");
    }
  }
  /// Supprime une image (Pas d'action réelle sur Cloudinary en mode public)
  Future<void> deleteImage(String imageUrl) async {
    // En mode "Unsigned", on ne peut pas supprimer l'image pour des raisons de sécurité.
    // On laisse la fonction vide pour ne pas casser le code existant.
    print("Suppression image ignorée (sécurité Cloudinary).");
    return;
  }

  /// Supprime une annonce de Firestore
  Future<void> deleteAd(String adId) async {
    try {
      final adDoc = await _adsCollection.doc(adId).get();

      // Vérification que l'annonce appartient bien à l'utilisateur
      if (adDoc.exists && adDoc.data()?['sellerId'] == _auth.currentUser?.uid) {

        // On supprime le document Firestore (l'annonce disparaît de l'appli)
        await _adsCollection.doc(adId).delete();

        // Note : Les images restent sur Cloudinary, mais le lien est coupé.
      } else {
        throw Exception("Vous n'avez pas la permission de supprimer cette annonce.");
      }
    } catch (e) {
      print("Erreur lors de la suppression de l'annonce: $e");
      throw Exception("La suppression de l'annonce a échoué.");
    }
  }
}