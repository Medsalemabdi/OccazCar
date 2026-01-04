import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'avoir intl dans pubspec.yaml
import 'package:occazcar/features/offers/services/offer_service.dart';
import 'package:occazcar/features/offers/ui/screens/chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OfferService offerService = OfferService();
    // On récupère l'ID de l'utilisateur connecté pour savoir qui est "l'autre"
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mes Messages',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: offerService.getUserConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final conversations = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 10),
            itemCount: conversations.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final convData = conversations[index].data() as Map<String, dynamic>;
              final conversationId = conversations[index].id;

              // --- 1. DÉTERMINER QUI EST L'AUTRE ---
              final bool isMeBuyer = convData['buyerId'] == currentUserId;
              final String otherUserId = isMeBuyer ? convData['sellerId'] : convData['buyerId'];

              // Nom potentiellement stocké (peut être null ou "Vendeur"/"Acheteur" pour les vieilles conv)
              String storedName = isMeBuyer
                  ? (convData['sellerName'] ?? 'Vendeur')
                  : (convData['buyerName'] ?? 'Acheteur');

              // Autres données
              final String lastMsg = convData['lastMessage'] ?? '...';
              final Timestamp? time = convData['lastMessageTimestamp'];

              // Prix (optionnel, pour rappel contextuel)
              final String priceTag = convData['adPrice'] != null
                  ? '${convData['adPrice']} €'
                  : '';

              // --- 2. FUTURE BUILDER POUR RECUPERER LE NOM MANQUANT ---
              // Si le nom est générique, on va chercher le vrai nom dans la collection 'users'
              return FutureBuilder<DocumentSnapshot>(
                future: (storedName == 'Vendeur' || storedName == 'Acheteur')
                    ? FirebaseFirestore.instance.collection('users').doc(otherUserId).get()
                    : null, // Pas besoin de requête si on a déjà un vrai nom
                builder: (context, userSnapshot) {

                  String displayName = storedName;

                  // Si on a récupéré des données fraîches de l'utilisateur
                  if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    if (userData['firstName'] != null) {
                      displayName = "${userData['firstName']} ${userData['lastName']}";
                    }
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(conversationId: conversationId),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // --- 3. AVATAR (INITIALES) ---
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // --- 4. CONTENU TEXTE ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ligne du haut : Nom Interlocuteur + Date
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName, // <--- NOM CORRIGÉ
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (time != null)
                                      Text(
                                        _formatTimestamp(time),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Ligne du bas : Dernier message + Badge Prix
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMsg,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    // Petit badge prix pour rappeler de quelle voiture on parle
                                    if (priceTag.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.grey.shade300)
                                        ),
                                        child: Text(
                                          priceTag,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700]
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- Widget Etat Vide ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune conversation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos échanges avec les vendeurs\napparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Helper Format Date ---
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Aujourd'hui -> Heure (ex: 14:30)
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays < 7) {
      // Cette semaine -> Jour (ex: Mar)
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[date.weekday - 1];
    } else {
      // Plus vieux -> Date courte (ex: 12/04)
      return "${date.day}/${date.month}";
    }
  }
}
