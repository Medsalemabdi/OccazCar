import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:occazcar/features/offers/services/offer_service.dart';
import 'package:occazcar/features/offers/ui/screens/chat_screen.dart';

class AdDetailScreen extends StatefulWidget {
  final String adId;
  final Map<String, dynamic> adData;

  const AdDetailScreen({
    super.key,
    required this.adId,
    required this.adData,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final OfferService offerService = OfferService();

    // Récupération sécurisée des images
    final List<dynamic> images = (widget.adData['imageUrls'] is List)
        ? widget.adData['imageUrls']
        : [];

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond légèrement grisé moderne
      extendBodyBehindAppBar: true, // L'image passe sous la barre de statut
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),

      body: Column(
        children: [
          // ===================== 1. IMAGE SLIDER (HAUT) =====================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CARROUSEL D'IMAGES ---
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: images.isNotEmpty
                            ? PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey[300],
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_car,
                              size: 80, color: Colors.white),
                        ),
                      ),
                      // Indicateur de page (ex: 1/3)
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ===================== 2. CONTENU PRINCIPAL =====================
                  Container(
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- EN-TÊTE : MARQUE & PRIX ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.adData['brand'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.adData['model'] ?? 'Modèle inconnu',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${widget.adData['price']} €',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- SPÉCIFICATIONS (GRID) ---
                        Row(
                          children: [
                            _buildSpecCard(
                              icon: Icons.calendar_today_outlined,
                              label: 'Année',
                              value: widget.adData['year'].toString(),
                            ),
                            const SizedBox(width: 12),
                            _buildSpecCard(
                              icon: Icons.speed,
                              label: 'Kilométrage',
                              value: '${widget.adData['mileage']} km',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- DESCRIPTION ---
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.adData['description'] ??
                              'Aucune description fournie par le vendeur.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.grey[800],
                          ),
                        ),

                        // --- RAPPORT DE DÉGÂTS (Optionnel) ---
                        if (widget.adData['damage_report'] != null &&
                            widget.adData['damage_report']
                                .toString()
                                .isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.red[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dommages signalés',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.adData['damage_report'],
                                  style: TextStyle(color: Colors.red[800]),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Espace pour que le bouton ne cache pas le texte
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ===================== CTA CONTACT (BAS) =====================
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Contacter le vendeur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Couleur moderne
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                try {
                  final conversationId = await offerService.startOrSendMessage(
                    adId: widget.adId,
                    sellerId: widget.adData['sellerId'],
                    buyerId: user.uid,
                    initialMessage:
                    'Bonjour, je suis intéressé par votre ${widget.adData['brand']} ${widget.adData['model']}.',
                  );

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(conversationId: conversationId),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur: $e")),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER pour les cartes de spécifications
  Widget _buildSpecCard(
      {required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
