// lib/features/seller/ui/widgets/edit_ad_form_widget.dart

import 'dart:io'; // Pour File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Pour choisir les photos

class EditAdFormWidget extends StatefulWidget {
  // On modifie la signature pour renvoyer aussi les images
  final Function(Map<String, dynamic> data, List<File> newImages, List<String> keptUrls) onSubmit;
  final Map<String, dynamic> initialData;

  const EditAdFormWidget({
    Key? key,
    required this.onSubmit,
    required this.initialData,
  }) : super(key: key);

  @override
  State<EditAdFormWidget> createState() => _EditAdFormWidgetState();
}

class _EditAdFormWidgetState extends State<EditAdFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  // --- LISTE DES MARQUES ---
  final List<String> _knownBrands = [
    'Peugeot', 'Renault', 'Citroën', 'Volkswagen', 'Dacia',
    'Toyota', 'Ford', 'BMW', 'Mercedes', 'Audi',
    'Fiat', 'Hyundai', 'Kia', 'Nissan', 'Opel',
    'Seat', 'Skoda', 'Suzuki', 'Mini', 'Volvo',
    'Land Rover', 'Jeep', 'Tesla', 'Autre'
  ];

  // Contrôleurs (Marque est gérée directement dans _formData)
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  // Gestion des images
  List<String> _existingUrls = []; // Les liens Cloudinary existants
  final List<File> _newImages = []; // Les nouvelles photos du téléphone
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);

    // Initialisation des contrôleurs
    // Note: _brandController supprimé car remplacé par Dropdown
    _modelController = TextEditingController(text: _formData['model']);
    _yearController = TextEditingController(text: _formData['year']?.toString());
    _mileageController = TextEditingController(text: _formData['mileage']?.toString());
    _priceController = TextEditingController(text: _formData['price']?.toString());
    _descriptionController = TextEditingController(text: _formData['description']);

    // Récupération des images existantes (si y'en a)
    if (_formData['imageUrls'] != null) {
      // On convertit bien en List<String> pour éviter les bugs
      _existingUrls = List<String>.from(_formData['imageUrls']);
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fonction pour choisir de nouvelles images
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedFiles.map((f) => File(f.path)));
        });
      }
    } catch (e) {
      print("Erreur sélection image: $e");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // On envoie : 1. Les données texte, 2. Les nouveaux fichiers, 3. Les URLs gardées
      widget.onSubmit(_formData, _newImages, _existingUrls);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. CHAMP MARQUE (DROPDOWN) ---
            DropdownButtonFormField<String>(
              value: _knownBrands.contains(_formData['brand']) ? _formData['brand'] : null, // Sécurité si la marque n'est pas dans la liste
              decoration: const InputDecoration(
                labelText: 'Marque',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.car_rental),
              ),
              items: _knownBrands.map((brand) {
                return DropdownMenuItem(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _formData['brand'] = value;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Veuillez sélectionner une marque'
                  : null,
              onSaved: (value) => _formData['brand'] = value,
            ),

            const SizedBox(height: 16),

            // --- AUTRES CHAMPS ---
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Modèle'),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['model'] = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Année'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['year'] = int.parse(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(labelText: 'Kilométrage'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['mileage'] = int.parse(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['price'] = double.parse(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['description'] = v!,
            ),

            const SizedBox(height: 24),
            const Text("Photos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // --- ZONE PHOTOS (Mélange URLs et Fichiers) ---
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // 1. Afficher les ANCIENNES images (celles qui sont déjà en ligne)
                  ..._existingUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _existingUrls.remove(url); // On retire l'URL de la liste
                              });
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 12,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),

                  // 2. Afficher les NOUVELLES images (celles depuis le téléphone)
                  ..._newImages.map((file) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _newImages.remove(file); // On retire le fichier
                              });
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.blue, // Bleu pour distinguer les nouvelles
                              radius: 12,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),

                  // 3. Bouton Ajouter
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey),
                          Text("Ajouter", style: TextStyle(color: Colors.grey, fontSize: 12))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
