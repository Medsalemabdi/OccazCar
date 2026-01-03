import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:occazcar/features/buyer/ui/ad_detail_screen.dart';
import 'package:occazcar/features/buyer/ui/widgets/ad_card.dart';
import 'package:occazcar/features/buyer/ui/widgets/filter_bottom_sheet.dart';
import 'package:occazcar/shared/widgets/app_logout_button.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  // ===================== FILTRES ACTUELS =====================
  Map<String, dynamic> _currentFilters = {
    'brand': null,
    'model': null,
    'minPrice': 0.0,
    'maxPrice': 500000.0,
    'minYear': 1990,
    'maxYear': DateTime.now().year,
  };

  // ===================== LOGIQUE DE FILTRAGE =====================
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> ads,
      ) {
    return ads.where((doc) {
      final ad = doc.data();

      // --- 1. NETTOYAGE DES DONNÉES ---
      final dynamic rawPrice = ad['price'];
      double price = 0.0;
      if (rawPrice is num) {
        price = rawPrice.toDouble();
      } else if (rawPrice is String) {
        price = double.tryParse(rawPrice) ?? 0.0;
      }

      final dynamic rawYear = ad['year'];
      int year = 0;
      if (rawYear is int) {
        year = rawYear;
      } else if (rawYear is String) {
        year = int.tryParse(rawYear) ?? 0;
      }

      // --- 2. LOGIQUE ---
      // MARQUE
      if (_currentFilters['brand'] != null &&
          _currentFilters['brand'].toString().isNotEmpty) {
        final String adBrand =
        (ad['brand'] ?? '').toString().toLowerCase().trim();
        final String filterBrand =
        _currentFilters['brand'].toString().toLowerCase().trim();

        if (adBrand != filterBrand) return false;
      }

      // PRIX
      if (price < (_currentFilters['minPrice'] ?? 0.0) ||
          price > (_currentFilters['maxPrice'] ?? 999999.0)) {
        return false;
      }

      // ANNÉE
      if (year < (_currentFilters['minYear'] ?? 1900) ||
          year > (_currentFilters['maxYear'] ?? DateTime.now().year)) {
        return false;
      }

      return true;
    }).toList();
  }

  // Fonction pour ouvrir les filtres
  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterBottomSheet(
        initialFilters: _currentFilters,
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond moderne gris clair
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'OccazCar',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/conversations');
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: AppLogoutButton(), // Assurez-vous que ce bouton a une icône noire
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BARRE DE RECHERCHE / FILTRE ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _openFilters,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rechercher un véhicule",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _getFilterSummary(), // Petit texte résumé
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune,
                          size: 20, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- TITRE LISTE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Dernières annonces",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // Petit indicateur de nombre de résultats pourrait aller ici
              ],
            ),
          ),

          // --- LISTE DES ANNONCES ---
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('ads')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.car_rental,
                    title: 'Aucune annonce disponible',
                    subtitle: 'Revenez plus tard pour voir les nouveautés.',
                  );
                }

                final filteredAds = _applyFilters(snapshot.data!.docs);

                if (filteredAds.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun résultat',
                    subtitle: 'Essayez de modifier vos filtres.',
                    action: TextButton.icon(
                      onPressed: () {
                        // Reset simple
                        setState(() {
                          _currentFilters = {};
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réinitialiser"),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredAds.length,
                  itemBuilder: (context, index) {
                    final ad = filteredAds[index].data();

                    return AdCard(
                      ad: ad,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdDetailScreen(
                              adId: filteredAds[index].id,
                              adData: ad,
                            ),
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

  // Widget helper pour les états vides
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ]
        ],
      ),
    );
  }

  // Helper pour afficher un résumé des filtres dans la barre de recherche
  String _getFilterSummary() {
    List<String> parts = [];
    if (_currentFilters['brand'] != null) parts.add(_currentFilters['brand']);
    if (_currentFilters['minPrice'] != null &&
        (_currentFilters['minPrice'] as num) > 0) {
      parts.add('> ${_currentFilters['minPrice']}€');
    }

    if (parts.isEmpty) return "Marque, modèle, prix...";
    return parts.join(", ");
  }
}
