// lib/features/offers/ui/screens/conversations_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/offers/services/offer_service.dart';
import 'package:occazcar/features/offers/ui/screens/chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OfferService offerService = OfferService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: offerService.getUserConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Vous n\'avez aucune conversation pour le moment.'));
          }
          final conversations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convData = conversations[index].data() as Map<String, dynamic>;
              final conversationId = conversations[index].id;
              // On pourrait récupérer plus d'infos (nom de l'annonce, etc.) pour un meilleur affichage
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Offre pour annonce..."),
                subtitle: Text(convData['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(conversationId: conversationId),
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
}
