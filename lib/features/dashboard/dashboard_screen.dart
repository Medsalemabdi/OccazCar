// @/OccazCar/lib/features/dashboard/dashboard_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/ui/screens/create_ad_screen.dart';
import 'package:occazcar/features/seller/ui/screens/my_ads_screen.dart';
import 'package:occazcar/features/offers/ui/screens/conversations_screen.dart';
import 'package:occazcar/features/users/ui/user_profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Fond cohérent
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'OccazCar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView( // Utiliser ListView pour une meilleure flexibilité
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- CARTE DE BIENVENUE ---
          Card(
            elevation: 0,
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bienvenue,', style: TextStyle(fontSize: 18)),
                  Text(
                    user?.email ?? 'Utilisateur',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'MES OUTILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),


          // --- CARTES D'ACTION ---
          // Utiliser des cartes stylées au lieu de simples boutons
          _buildActionCard(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'Publier une annonce',
            subtitle: 'Mettez en vente un nouveau véhicule',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateAdScreen()),
              );
            },
          ),

          _buildActionCard(
            context: context,
            icon: Icons.list_alt_rounded,
            title: 'Gérer mes annonces',
            subtitle: 'Modifiez ou supprimez vos annonces en cours',
            color: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyAdsScreen()),
              );
            },
          ),

          _buildActionCard(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Consulter mes messages',
            subtitle: 'Répondez aux offres des acheteurs potentiels',
            color: Colors.teal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ConversationsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget pour construire les cartes d'action de manière cohérente
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

