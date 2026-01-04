import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/buyer/ui/ad_detail_screen.dart';
import '../services/alert_service.dart';
import '../models/search_alert.dart';

class MyAlertsScreen extends StatelessWidget {
  const MyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AlertService alertService = AlertService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Mes Alertes"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<SearchAlert>>(
        stream: alertService.getUserAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Aucune alerte active.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              // Widget personnalisé qui gère l'affichage de l'alerte + ses résultats
              return _AlertResultTile(
                alert: alert,
                onDelete: () => alertService.deleteAlert(alert.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _AlertResultTile extends StatelessWidget {
  final SearchAlert alert;
  final VoidCallback onDelete;

  const _AlertResultTile({required this.alert, required this.onDelete});

  // Cette méthode construit la requête pour trouver les annonces qui matchent l'alerte
  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('ads');

    // Filtre Marque (Sensible à la casse dans Firestore, on espère que c'est stocké standardisé)
    if (alert.brand.isNotEmpty) {
      query = query.where('brand', isEqualTo: alert.brand);
    }

    // Filtres Prix (Firestore limite les inégalités sur un seul champ parfois, attention aux indexes)
    // Ici on filtre le prix. Pour l'année, on le fera côté Flutter si besoin pour éviter l'erreur d'index composite.
    if (alert.minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: alert.minPrice);
    }
    if (alert.maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: alert.maxPrice);
    }


    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          alert.brand,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Prix: ${alert.minPrice?.toInt() ?? 0} - ${alert.maxPrice?.toInt() ?? '∞'} €",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Divider(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Annonces correspondantes :",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),

          // --- Liste des résultats ---
          SizedBox(
            height: 200, // Hauteur fixe pour la liste interne
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _buildQuery().get(), // On exécute la recherche
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucune annonce trouvée pour le moment."));
                }

                // Filtrage supplémentaire côté client (ex: année) pour éviter les problèmes d'index Firestore
                final ads = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final year = data['year'] as int? ?? 0;
                  if (alert.minYear != null && year < alert.minYear!) return false;
                  if (alert.maxYear != null && year > alert.maxYear!) return false;
                  return true;
                }).toList();

                if (ads.isEmpty) {
                  return const Center(child: Text("Aucune annonce ne correspond aux années demandées."));
                }

                return ListView.builder(
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index].data();
                    final adId = ads[index].id;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: (ad['imageUrls'] != null && (ad['imageUrls'] as List).isNotEmpty)
                              ? Image.network(ad['imageUrls'][0], fit: BoxFit.cover)
                              : const Icon(Icons.directions_car, color: Colors.grey),
                        ),
                      ),
                      title: Text("${ad['brand']} ${ad['model']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text("${ad['price']} € • ${ad['year']}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // Navigation vers le détail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdDetailScreen(adId: adId, adData: ad),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
