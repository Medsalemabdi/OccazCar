// lib/features/seller/ui/screens/edit_ad_screen.dart

import 'package:flutter/material.dart';
import 'package:occazcar/features/seller/services/ad_service.dart';
import 'package:occazcar/features/seller/ui/widgets/edit_ad_form_widget.dart'; // Nous allons créer ce widget

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

  Future<void> _handleUpdateSubmit(Map<String, dynamic> data) async {
    setState(() { _isLoading = true; });

    try {
      await _adService.updateAd(widget.adId, data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce modifiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      // Revenir à l'écran précédent (la liste des annonces)
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
        // On passe les données initiales au formulaire
            : EditAdFormWidget(
          initialData: widget.adData,
          onSubmit: _handleUpdateSubmit,
        ),
      ),
    );
  }
}
