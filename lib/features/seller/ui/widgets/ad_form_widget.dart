// @/OccazCar/lib/features/seller/ui/widgets/ad_form_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:occazcar/features/ia/ai_service.dart';

class AdFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic> data, List<File> images) onSubmit;
  // Ajout d'un paramètre optionnel pour pré-remplir (cas de l'édition)
  final Map<String, dynamic>? initialData;

  const AdFormWidget({
    Key? key,
    required this.onSubmit,
    this.initialData,
  }) : super(key: key);

  @override
  State<AdFormWidget> createState() => _AdFormWidgetState();
}

class _AdFormWidgetState extends State<AdFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // --- LISTE DES MARQUES ---
  final List<String> _knownBrands = [
    'Peugeot', 'Renault', 'Citroën', 'Volkswagen', 'Dacia',
    'Toyota', 'Ford', 'BMW', 'Mercedes', 'Audi',
    'Fiat', 'Hyundai', 'Kia', 'Nissan', 'Opel',
    'Seat', 'Skoda', 'Suzuki', 'Mini', 'Volvo',
    'Land Rover', 'Jeep', 'Tesla', 'Autre'
  ];

  late Map<String, dynamic> _formData;
  late TextEditingController _descriptionController;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final AIService _aiService = AIService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    // Initialisation des données (soit vides, soit celles de l'annonce à modifier)
    _formData = {
      'brand': widget.initialData?['brand'], // Sera null au départ si création
      'model': widget.initialData?['model'] ?? '',
      'year': widget.initialData?['year'],
      'mileage': widget.initialData?['mileage'],
      'price': widget.initialData?['price'],
      'description': widget.initialData?['description'] ?? '',
      'damage_report': widget.initialData?['damage_report'] ?? '',
    };

    _descriptionController = TextEditingController(text: _formData['description']);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateAIDescription() async {
    _formKey.currentState?.save();
    final brand = _formData['brand']; // Peut être null
    final model = _formData['model'] ?? '';
    final year = _formData['year'];

    if (brand == null || (brand as String).isEmpty || model.isEmpty || year == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez d\'abord remplir la marque, le modèle et l\'année.'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final generatedText = await _aiService.generateAdDescription(
        brand: brand,
        model: model,
        year: year as int,
      );
      setState(() {
        _descriptionController.text = generatedText;
        _formData['description'] = generatedText; // Mise à jour de la map aussi
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur IA : ${e.toString()}'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if(pickedFiles.isNotEmpty) {
      setState(() => _selectedImages.addAll(pickedFiles.map((f) => File(f.path))));
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Petit check pour s'assurer que la description du controller est bien dans la map
      _formData['description'] = _descriptionController.text;

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

            // --- 1. CHAMP MARQUE (DROPDOWN) ---
            DropdownButtonFormField<String>(
              value: _formData['brand'], // Utilise la valeur actuelle (null ou marque)
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

            // --- CHAMPS DÉTAILS VÉHICULE ---
            TextFormField(
              initialValue: _formData['model'],
              decoration: const InputDecoration(labelText: 'Modèle'),
              validator: (v) => v!.trim().isEmpty ? 'Le modèle est requis' : null,
              onSaved: (v) => _formData['model'] = v!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _formData['year']?.toString(),
              decoration: const InputDecoration(labelText: 'Année'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'L\'année est requise' : null,
              onSaved: (v) => _formData['year'] = int.tryParse(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _formData['mileage']?.toString(),
              decoration: const InputDecoration(labelText: 'Kilométrage'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'Le kilométrage est requis' : null,
              onSaved: (v) => _formData['mileage'] = int.tryParse(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _formData['price']?.toString(),
              decoration: const InputDecoration(labelText: 'Prix (€)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (v) => v!.isEmpty ? 'Le prix est requis' : null,
              onSaved: (v) => _formData['price'] = double.tryParse(v!),
            ),
            const SizedBox(height: 16),

            // --- SECTION DESCRIPTION AVEC IA ---
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              maxLines: 5,
              validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['description'] = v!.trim(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: _isGenerating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Générer avec l\'IA'),
                onPressed: _isGenerating ? null : _generateAIDescription,
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION RAPPORT DE DÉGÂTS ---
            TextFormField(
              initialValue: _formData['damage_report'],
              decoration: const InputDecoration(
                labelText: 'Rapport de dégâts (optionnel)',
                hintText: 'Ex: Rayure portière droite, bosse pare-chocs...',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onSaved: (value) => _formData['damage_report'] = _aiService.formatDamageReport(value ?? ''),
            ),
            const SizedBox(height: 24),

            // --- SECTION PHOTOS ---
            const Text('Photos de l\'annonce (Optionnel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._aiService.getPhotoTips().map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.grey[600])),
                  Expanded(child: Text(tip, style: TextStyle(color: Colors.grey[600]))),
                ],
              ),
            )).toList(),

            const SizedBox(height: 16),

            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Ajouter des photos'),
              onPressed: _pickImages,
            ),
            const SizedBox(height: 32),

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
