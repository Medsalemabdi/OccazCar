import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/offers/services/offer_service.dart';
import 'package:occazcar/features/offers/ui/screens/chat_screen.dart';

class AdDetailScreen extends StatelessWidget {
  final String adId;
  final Map<String, dynamic> adData;

  const AdDetailScreen({
    super.key,
    required this.adId,
    required this.adData,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final OfferService offerService = OfferService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l’annonce'),
      ),

      // ===================== CONTENU =====================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------- IMAGE PRINCIPALE --------
            Container(
              height: 240,
              width: double.infinity,
              color: Colors.grey[300],
              child: adData['imageUrls'] != null &&
                  (adData['imageUrls'] as List).isNotEmpty
                  ? Image.network(
                adData['imageUrls'][0],
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.directions_car,
                size: 100,
                color: Colors.white,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // -------- TITRE --------
                  Text(
                    '${adData['brand']} ${adData['model']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -------- PRIX --------
                  Text(
                    '${adData['price']} €',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- INFOS --------
                  _infoRow('Année', adData['year'].toString()),
                  _infoRow('Kilométrage', '${adData['mileage']} km'),

                  const Divider(height: 32),

                  // -------- DESCRIPTION --------
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adData['description'] ?? 'Aucune description',
                    style: const TextStyle(fontSize: 15),
                  ),

                  if (adData['damage_report'] != null &&
                      adData['damage_report'].toString().isNotEmpty) ...[
                    const Divider(height: 32),

                    const Text(
                      'Rapport de dégâts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(adData['damage_report']),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // ===================== CTA CONTACT =====================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Contacter le vendeur'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () async {
            final conversationId =
            await offerService.startOrSendMessage(
              adId: adId,
              sellerId: adData['sellerId'],
              buyerId: user.uid,
              initialMessage:
              'Bonjour, cette voiture est-elle toujours disponible ?',
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatScreen(conversationId: conversationId),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===================== WIDGET INFO =====================
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
