// @/OccazCar/lib/features/seller/ui/screens/my_ads_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/screens/edit_ad_screen.dart';
// 1. IMPORTER LE SERVICE D'OFFRES POUR LE PROTOTYPAGE
import 'package:occazcar/features/offers/services/offer_service.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({Key? key}) : super(key: key);

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final AdService _adService = AdService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Annonces'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _adService.getAdsForSeller(_currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Vous n\'avez aucune annonce.'));
          }

          final adDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: adDocs.length,
            itemBuilder: (context, index) {
              final adData = adDocs[index].data();
              final adId = adDocs[index].id;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: (adData['imageUrls'] != null &&
                      (adData['imageUrls'] as List).isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      adData['imageUrls'][0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.directions_car, size: 40),
                  title: Text('${adData['brand']} ${adData['model']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${adData['price']} € - ${adData['mileage']} km'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditAdScreen(
                                adData: adData,
                                adId: adId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // ... (votre code de suppression est parfait)
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text(
                                  'Êtes-vous sûr ? Cette action est irréversible.'),
                              actions: [
                                TextButton(
                                  child: const Text('Annuler'),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  child: const Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    Navigator.of(dialogContext).pop();
                                    try {
                                      await _adService.deleteAd(adId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                            Text('Annonce supprimée.'),
                                            backgroundColor: Colors.green),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Erreur: $e'),
                                            backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // 2. BOUTON DE TEST POUR SIMULER UNE OFFRE D'ACHETEUR
                      IconButton(
                        icon: const Icon(Icons.send_and_archive, color: Colors.purple),
                        tooltip: 'Simuler une offre d\'un autre utilisateur',
                        onPressed: () async {
                          final offerService = OfferService();
                          final currentUser = FirebaseAuth.instance.currentUser!;
                          try {
                            // On simule qu'un acheteur fictif ("buyer_test_id")
                            // envoie un message sur votre propre annonce.
                            final conversationId = await offerService.startOrSendMessage(
                              adId: adId,
                              sellerId: currentUser.uid,
                              buyerId: 'buyer_test_id',
                              initialMessage: "Bonjour, je suis un acheteur de test et votre ${adData['brand']} m'intéresse !",
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Simulation réussie ! Conversation créée.'),
                                  backgroundColor: Colors.purple),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erreur de simulation: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
