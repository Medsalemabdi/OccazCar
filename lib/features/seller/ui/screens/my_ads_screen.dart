import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/buyer/ui/ad_detail_screen.dart'; // Importez votre écran de détail
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/screens/create_ad_screen.dart'; // Importez CreateAdScreen
import 'package:occazcar/features/seller/ui/screens/edit_ad_screen.dart'; // Importez EditAdScreen

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
      return const Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mes Annonces',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      // --- BOUTON POUR CRÉER UNE ANNONCE ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAdScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Publier"),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sell_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Vous n\'avez publié aucune annonce.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final adDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 80), // Espace pour le FAB
            itemCount: adDocs.length,
            itemBuilder: (context, index) {
              final adData = adDocs[index].data();
              final adId = adDocs[index].id;

              String? firstImageUrl;
              if (adData['imageUrls'] != null && (adData['imageUrls'] as List).isNotEmpty) {
                firstImageUrl = adData['imageUrls'][0];
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // --- NAVIGATION VERS LE DÉTAIL (VERSION VENDEUR) ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdDetailScreen(adId: adId, adData: adData),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: firstImageUrl != null
                                ? Image.network(
                              firstImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) =>
                                  Icon(Icons.broken_image, color: Colors.grey[400]),
                            )
                                : Icon(Icons.directions_car, color: Colors.grey[400], size: 40),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // TEXTES
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${adData['brand']} ${adData['model']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${adData['year']} • ${adData['mileage']} km',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${adData['price']} €',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ACTIONS RAPIDES (Edit / Delete)
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () {
                                // Raccourci vers EditAdScreen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditAdScreen(adData: adData, adId: adId),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(context, adId),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fonction de suppression
  void _confirmDelete(BuildContext context, String adId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'annonce ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Ferme dialog
              try {
                await _adService.deleteAd(adId); // Assurez-vous que deleteAd existe dans AdService
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Annonce supprimée")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur: $e")),
                  );
                }
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
