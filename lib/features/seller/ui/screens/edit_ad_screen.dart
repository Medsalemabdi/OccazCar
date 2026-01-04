// @/OccazCar/lib/features/seller/ui/screens/edit_ad_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/widgets/edit_ad_form_widget.dart';

class EditAdScreen extends StatefulWidget {
  final Map<String, dynamic> adData;
  final String adId;

  const EditAdScreen({
    Key? key,
    required this.adData,
    required this.adId,
  }) : super(key: key);

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final AdService _adService = AdService();
  bool _isLoading = false;
  String _loadingMessage = 'Sauvegarde des modifications...';

  // C'EST CETTE FONCTION QUI FAIT TOUT LE TRAVAIL
  Future<void> _handleUpdateSubmit(
      Map<String, dynamic> formData, // Données texte
      List<File> newImages,          // Nouveaux fichiers à uploader
      List<String> keptImageUrls,    // Anciennes URLs à conserver
      ) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Mise à jour des informations...';
    });

    try {
      // On commence la liste finale avec les URLs qu'on a décidé de garder.
      List<String> finalImageUrls = List.from(keptImageUrls);

      // 1. On envoie uniquement les NOUVELLES images sur Cloudinary.
      if (newImages.isNotEmpty) {
        setState(() {
          _loadingMessage = 'Envoi des nouvelles photos...';
        });
        List<String> newUploadedUrls = await _adService.uploadMultipleImages(newImages);
        // On ajoute les nouvelles URLs à notre liste finale.
        finalImageUrls.addAll(newUploadedUrls);
      }

      // 2. On met la liste d'images finale (anciennes gardées + nouvelles) dans les données.
      formData['imageUrls'] = finalImageUrls;

      // 3. On met à jour l'annonce dans Firestore avec toutes les données.
      setState(() {
        _loadingMessage = 'Finalisation...';
      });
      await _adService.updateAd(widget.adId, formData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce modifiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. On ferme l'écran de modification, ce qui nous ramène à la liste.
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la modification : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier : ${widget.adData['brand'] ?? ''}"),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_loadingMessage),
          ],
        ),
      )
          : EditAdFormWidget(
        initialData: widget.adData,
        onSubmit: _handleUpdateSubmit, // On passe notre super fonction ici
      ),
    );
  }
}
