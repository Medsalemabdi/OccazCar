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
    required String buyerId, // On précise l'ID de l'acheteur
    required String initialMessage,
  }) async {
    // ID unique pour la conversation, toujours le même pour une paire annonce/acheteur
    final conversationId = '${adId}_${buyerId}';
    final conversationRef = _firestore.collection('conversations').doc(conversationId);
    final messageRef = conversationRef.collection('messages');

    // Crée ou met à jour la conversation avec le dernier message
    await conversationRef.set({
      'adId': adId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'participants': [sellerId, buyerId], // Pour les règles de sécurité
      'lastMessage': initialMessage,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Ajoute le premier message à la sous-collection
    await messageRef.add({
      'senderId': buyerId,
      'text': initialMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return conversationId;
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
