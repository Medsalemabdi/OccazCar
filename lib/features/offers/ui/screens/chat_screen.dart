import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/buyer/ui/ad_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final conversationRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId);

    conversationRef.collection('messages').add({
      'senderId': _currentUser!.uid,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    conversationRef.update({
      'lastMessage': _messageController.text.trim(),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });

    _messageController.clear();
  }

  // ---  Fonction pour naviguer vers l'annonce ---
  Future<void> _navigateToAd(String adId) async {
    try {
      // On montre un chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      // On récupère les données fraîches de l'annonce
      final adDoc = await FirebaseFirestore.instance.collection('ads').doc(adId).get();

      // On ferme le chargement
      if (context.mounted) Navigator.pop(context);

      if (adDoc.exists && context.mounted) {
        // On navigue vers les détails
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdDetailScreen(
              adId: adId,
              adData: adDoc.data()!,
            ),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cette annonce n'existe plus.")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Fermer loader cas erreur
      print("Erreur nav: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Discussion',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // ===================== LIEN "PIÈCE JOINTE" (MODIFIÉ) =====================
          _buildAttachmentLink(),

          // ===================== LISTE DES MESSAGES =====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyChatState();
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message['senderId'] == _currentUser!.uid;
                    return _buildMessageBubble(message['text'], isMe);
                  },
                );
              },
            ),
          ),

          // ===================== BARRE DE SAISIE =====================
          _buildInputArea(),
        ],
      ),
    );
  }


  Widget _buildAttachmentLink() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final String adTitle = data['adTitle'] ?? 'Voir l\'annonce';
        final String adId = data['adId'] ?? '';
        final String? adImage = data['adImage'];

        return InkWell(
          onTap: () => _navigateToAd(adId),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50], // Fond très léger pour signifier un lien
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: Row(
              children: [
                // Icône trombone ou petite image
                if (adImage != null && adImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(adImage, width: 30, height: 30, fit: BoxFit.cover),
                  )
                else
                  const Icon(Icons.attach_file, color: Colors.blue, size: 20),

                const SizedBox(width: 12),


                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Concerne : ",
                        style: TextStyle(color: Colors.blue[800], fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          adTitle,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),


                Icon(Icons.open_in_new, size: 16, color: Colors.blue[700]),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [if (!isMe) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Écrivez votre message...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Démarrez la discussion !', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}
