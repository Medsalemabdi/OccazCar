// @/OccazCar/lib/features/seller/ui/screens/my_ads_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/screens/edit_ad_screen.dart';
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
      backgroundColor: Colors.grey[50], // Applique le fond gris clair de l'UI Acheteur
      appBar: AppBar(
        title: const Text(
          'Mes Annonces',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
            return const Center(child: Text('Vous n\'avez publié aucune annonce.'));
          }

          final adDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0), // Ajoute un peu d'espace en haut
            itemCount: adDocs.length,
            itemBuilder: (context, index) {
              final adData = adDocs[index].data();
              final adId = adDocs[index].id;

              // ===================================================================
              //               APPLICATION DU STYLE DE L'ACHETEUR ICI
              // ===================================================================
              String? firstImageUrl;
              if (adData['imageUrls'] != null && (adData['imageUrls'] as List).isNotEmpty) {
                firstImageUrl = adData['imageUrls'][0];
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3, // Ombre subtile et moderne
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias, // Assure que l'image respecte les coins arrondis
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- IMAGE ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[200],
                            child: firstImageUrl != null
                                ? Image.network(
                              firstImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Icon(Icons.broken_image, color: Colors.grey[400]),
                            )
                                : Icon(Icons.directions_car, color: Colors.grey[400], size: 40),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // --- INFORMATIONS TEXTE ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${adData['brand']} ${adData['model']}',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${adData['year']} • ${adData['mileage']} km',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${adData['price']} €',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- BOUTONS D'ACTION DU VENDEUR ---
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit,
                              color: Colors.blueAccent,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditAdScreen(adData: adData, adId: adId),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              color: Colors.redAccent,
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog( /* ... */ )
                                );
                              },
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

  // Helper widget pour créer des boutons d'action stylés et plus petits
  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
