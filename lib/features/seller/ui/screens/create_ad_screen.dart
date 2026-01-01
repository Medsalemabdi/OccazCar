// @/OccazCar/lib/features/seller/ui/screens/create_ad_screen.dart

import 'dart:io'; // NÉCESSAIRE POUR LIST<FILE>
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/screens/my_ads_screen.dart';
import '../widgets/ad_form_widget.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({Key? key}) : super(key: key);

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final AdService _adService = AdService();
  bool _isLoading = false;
  String _loadingMessage = 'Publication en cours...';

  // La fonction accepte maintenant les données et les images
  Future<void> _handleFormSubmit(Map<String, dynamic> data, List<File> images) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Téléversement des images...';
    });

    try {
      // 1. Uploader chaque image et récupérer leurs URLs
      final List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        setState(() {
          _loadingMessage = 'Téléversement de l\'image ${i + 1}/${images.length}...';
        });
        final imageUrl = await _adService.uploadImage(images[i]);
        imageUrls.add(imageUrl);
      }

      // 2. Ajouter la liste des URLs aux données de l'annonce
      data['imageUrls'] = imageUrls;

      // 3. Publier l'annonce complète
      setState(() { _loadingMessage = 'Finalisation...'; });
      await _adService.publishAd(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Annonce publiée avec succès !'),
        backgroundColor: Colors.green,
      ));

      // Redirige vers la liste des annonces pour voir le résultat
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyAdsScreen()),
            (Route<dynamic> route) => route.isFirst,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une annonce')),
      body: Center(
        child: _isLoading
            ? Column( // Pour un affichage de chargement plus informatif
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_loadingMessage),
          ],
        )
            : AdFormWidget(onSubmit: _handleFormSubmit),
      ),
    );
  }
}
