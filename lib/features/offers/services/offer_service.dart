// lib/features/offers/services/offer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Démarre une conversation ou envoie un message.
  Future<String> startOrSendMessage({
    required String adId,
    required String sellerId,
    required String buyerId,
    required String initialMessage,
    // On garde l'image de l'annonce pour le petit lien, mais on enlève adTitle si vous voulez
    String? adImage,
    // Plus besoin de adTitle ici, on va chercher les noms
  }) async {
    final conversationsRef = FirebaseFirestore.instance.collection('conversations');
    final usersRef = FirebaseFirestore.instance.collection('users');

    // 1. Vérifier si conversation existe
    final querySnapshot = await conversationsRef
        .where('adId', isEqualTo: adId)
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      // 2. RÉCUPÉRER LES NOMS
      // Nom de l'acheteur (Current User)
      String buyerName = "Acheteur inconnu";
      final buyerDoc = await usersRef.doc(buyerId).get();
      if (buyerDoc.exists) {
        final d = buyerDoc.data()!;
        buyerName = "${d['firstName']} ${d['lastName']}";
      }

      // Nom du vendeur
      String sellerName = "Vendeur inconnu";
      final sellerDoc = await usersRef.doc(sellerId).get();
      if (sellerDoc.exists) {
        final d = sellerDoc.data()!;
        sellerName = "${d['firstName']} ${d['lastName']}";
      }

      // 3. CRÉER LA CONVERSATION AVEC LES NOMS
      final docRef = await conversationsRef.add({
        'adId': adId,
        'sellerId': sellerId,
        'buyerId': buyerId,
        'lastMessage': initialMessage,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': 1,
        'adImage': adImage ?? '',

        // --- NOUVEAU : ON STOCKE LES NOMS ICI ---
        'buyerName': buyerName,
        'sellerName': sellerName,
      });

      await docRef.collection('messages').add({
        'senderId': buyerId,
        'text': initialMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    }
  }

  /// Récupère toutes les conversations d'un utilisateur (acheteur ou vendeur).
  Stream<QuerySnapshot> getUserConversations() {
    final currentUser = _auth.currentUser!;
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  /// Récupère tous les messages d'une conversation spécifique.
  Stream<QuerySnapshot> getMessagesForConversation(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
