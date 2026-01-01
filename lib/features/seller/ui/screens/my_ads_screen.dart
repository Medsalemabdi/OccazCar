// lib/features/seller/ui/screens/my_ads_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/screens/edit_ad_screen.dart'; // <-- IMPORTER L'ÉCRAN DE MODIFICATION

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
      // ... (code si l'utilisateur n'est pas connecté)
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
                  title: Text('${adData['brand']} ${adData['model']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${adData['price']} € - ${adData['mileage']} km'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BOUTON MODIFIER ACTIF
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
                      // BOUTON SUPPRIMER ACTIF
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text('Êtes-vous sûr ? Cette action est irréversible.'),
                              actions: [
                                TextButton(
                                  child: const Text('Annuler'),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    Navigator.of(dialogContext).pop();
                                    try {
                                      await _adService.deleteAd(adId);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Annonce supprimée.'), backgroundColor: Colors.green),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
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
