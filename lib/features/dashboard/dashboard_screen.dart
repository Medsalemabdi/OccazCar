// @/OccazCar/lib/features/dashboard/dashboard_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 1. IMPORTATION DES ÉCRANS VENDEUR
// On importe les "pièces" que vous avez déjà construites.
import 'package:occazcar/features/seller/ui/screens/create_ad_screen.dart';
import 'package:occazcar/features/seller/ui/screens/my_ads_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      // 2. LE "COULOIR" EST MAINTENANT UN VRAI MENU
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue,',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              user?.email ?? 'Utilisateur',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),

            // 3. LA "PORTE" VERS L'ÉCRAN DE PUBLICATION
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Publier une nouvelle annonce'),
              onPressed: () {
                // Quand on clique, on navigue vers l'écran que vous avez déjà créé.
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateAdScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // 4. LA "PORTE" VERS L'ÉCRAN "MES ANNONCES"
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Voir mes annonces'),
              onPressed: () {
                // Navigue vers l'autre écran que vous avez créé.
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyAdsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
