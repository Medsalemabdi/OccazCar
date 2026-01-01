// @/OccazCar/lib/features/seller/ui/widgets/ad_form_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AdFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic> data, List<File> images) onSubmit;

  const AdFormWidget({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AdFormWidget> createState() => _AdFormWidgetState();
}

class _AdFormWidgetState extends State<AdFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'brand': '',
    'model': '',
    'year': null,
    'mileage': null,
    'price': null,
    'description': '',
  };

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _submitForm() {
    // ====================================================================
    //               MODIFICATION CLÉ : ON SUPPRIME CE BLOC
    // ====================================================================
    /*
    // Ancien code qui rendait les photos obligatoires :
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez ajouter au moins une photo.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    */
    // ====================================================================

    // On continue la soumission même si la liste d'images est vide.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_formData, _selectedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tous les champs de texte restent ici...
            TextFormField(
              decoration: const InputDecoration(labelText: 'Marque'),
              validator: (value) => value!.trim().isEmpty ? 'La marque est requise' : null,
              onSaved: (value) => _formData['brand'] = value!.trim(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Modèle'),
              validator: (value) => value!.trim().isEmpty ? 'Le modèle est requis' : null,
              onSaved: (value) => _formData['model'] = value!.trim(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Année'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value!.isEmpty ? 'L\'année est requise' : null,
              onSaved: (value) => _formData['year'] = int.tryParse(value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Kilométrage'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value!.isEmpty ? 'Le kilométrage est requis' : null,
              onSaved: (value) => _formData['mileage'] = int.tryParse(value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Prix (€)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) => value!.isEmpty ? 'Le prix est requis' : null,
              onSaved: (value) => _formData['price'] = double.tryParse(value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              maxLines: 5,
              validator: (value) => value!.trim().isEmpty ? 'Une description est requise' : null,
              onSaved: (value) => _formData['description'] = value!.trim(),
            ),
            const SizedBox(height: 32),

            // La section photos...
            const Text('Photos de l\'annonce (Optionnel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Grille pour afficher les miniatures des images sélectionnées
            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Bouton pour ajouter des photos
            OutlinedButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Ajouter des photos'),
              onPressed: _pickImages,
            ),

            const SizedBox(height: 32),

            // Bouton de soumission
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Publier l\'annonce'),
            ),
          ],
        ),
      ),
    );
  }
}
