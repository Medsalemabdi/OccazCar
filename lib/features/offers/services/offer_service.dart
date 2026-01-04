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
    String? adImage,
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
      String buyerName = "Acheteur inconnu";
      final buyerDoc = await usersRef.doc(buyerId).get();
      if (buyerDoc.exists && buyerDoc.data() != null) {
        final d = buyerDoc.data()!;
        if (d['firstName'] != null) {
          buyerName = "${d['firstName']} ${d['lastName']}";
        }
      }

      String sellerName = "Vendeur inconnu";
      final sellerDoc = await usersRef.doc(sellerId).get();
      if (sellerDoc.exists && sellerDoc.data() != null) {
        final d = sellerDoc.data()!;
        if (d['firstName'] != null) {
          sellerName = "${d['firstName']} ${d['lastName']}";
        }
      }

      // 3. CRÉER LA CONVERSATION AVEC LES NOMS ET PARTICIPANTS
      final docRef = await conversationsRef.add({
        'adId': adId,
        'sellerId': sellerId,
        'buyerId': buyerId,


        'participants': [buyerId, sellerId],


        'lastMessage': initialMessage,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': 1,
        'adImage': adImage ?? '',
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
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

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
