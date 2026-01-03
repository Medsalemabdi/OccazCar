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

  // ===================== FILTRAGE CÔTÉ FLUTTER (CORRIGÉ) =====================
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> ads,
      ) {
    return ads.where((doc) {
      final ad = doc.data();

      // --- 1. NETTOYAGE DES DONNÉES ---

      // Conversion sécurisée du PRIX (gère String et Number)
      final dynamic rawPrice = ad['price'];
      double price = 0.0;
      if (rawPrice is num) {
        price = rawPrice.toDouble();
      } else if (rawPrice is String) {
        price = double.tryParse(rawPrice) ?? 0.0;
      }

      // Conversion sécurisée de l'ANNÉE (gère String et Number)
      final dynamic rawYear = ad['year'];
      int year = 0;
      if (rawYear is int) {
        year = rawYear;
      } else if (rawYear is String) {
        year = int.tryParse(rawYear) ?? 0;
      }

      // --- 2. LOGIQUE DE FILTRAGE ---

      // MARQUE (BRAND)
      if (_currentFilters['brand'] != null &&
          _currentFilters['brand'].toString().isNotEmpty) {
        final String adBrand = (ad['brand'] ?? '').toString().toLowerCase().trim();
        final String filterBrand = _currentFilters['brand'].toString().toLowerCase().trim();

        if (adBrand != filterBrand) {
          return false;
        }
      }

      // MODÈLE (MODEL)
      if (_currentFilters['model'] != null &&
          _currentFilters['model'].toString().isNotEmpty) {
        final String adModel = (ad['model'] ?? '').toString().toLowerCase().trim();
        final String filterModel = _currentFilters['model'].toString().toLowerCase().trim();

        if (adModel != filterModel) {
          return false;
        }
      }

      // PRIX (PRICE)
      // Vérifie si le prix est dans la fourchette
      if (price < (_currentFilters['minPrice'] ?? 0.0) ||
          price > (_currentFilters['maxPrice'] ?? 999999.0)) {
        return false;
      }

      // ANNÉE (YEAR)
      // Vérifie si l'année est dans la fourchette
      if (year < (_currentFilters['minYear'] ?? 1900) ||
          year > (_currentFilters['maxYear'] ?? DateTime.now().year)) {
        return false;
      }

      return true;
    }).toList();
  }


  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OccazCar'),
        actions: [
          const AppLogoutButton(),

          // Messages
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.pushNamed(context, '/conversations');
            },
          ),

          // Filtres
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            },
          ),
        ],
      ),

      // ===================== ANNONCES =====================
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune annonce disponible'),
            );
          }

          final filteredAds = _applyFilters(snapshot.data!.docs);

          if (filteredAds.isEmpty) {
            return const Center(
              child: Text(
                'Aucune annonce ne correspond à vos critères',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
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
    );
  }
}
