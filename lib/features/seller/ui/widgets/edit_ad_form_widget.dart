// lib/features/seller/ui/widgets/edit_ad_form_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditAdFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic> data) onSubmit;
  final Map<String, dynamic> initialData; // Données pour pré-remplir

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

  // Contrôleurs pour pouvoir modifier le texte
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);

    // Initialiser les contrôleurs avec les données existantes
    _brandController = TextEditingController(text: _formData['brand']);
    _modelController = TextEditingController(text: _formData['model']);
    _yearController = TextEditingController(text: _formData['year']?.toString());
    _mileageController = TextEditingController(text: _formData['mileage']?.toString());
    _priceController = TextEditingController(text: _formData['price']?.toString());
    _descriptionController = TextEditingController(text: _formData['description']);
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_formData);
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
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Marque'),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
              onSaved: (v) => _formData['brand'] = v!,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
