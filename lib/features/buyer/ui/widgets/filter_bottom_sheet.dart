import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterBottomSheet({
    super.key,
    this.initialFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Valeurs par défaut
  static const double _defaultMinPrice = 0;
  static const double _defaultMaxPrice = 500000; // 500k max c'est plus réaliste que 100M
  static const double _defaultMinYear = 1990;

  String? _selectedBrand;
  late RangeValues _priceRange;
  late RangeValues _yearRange;
  late double _currentMaxYear;

  final List<String> _brands = [
    'Toyota',
    'Peugeot',
    'Renault',
    'Volkswagen',
    'BMW',
    'Mercedes',
    'Hyundai',
    'Kia',
  ];

  @override
  void initState() {
    super.initState();
    _currentMaxYear = DateTime.now().year.toDouble();

    // Initialisation sécurisée
    _priceRange = const RangeValues(_defaultMinPrice, _defaultMaxPrice);
    _yearRange = RangeValues(_defaultMinYear, _currentMaxYear);

    // Si on a des filtres existants, on les applique
    if (widget.initialFilters != null) {
      if (widget.initialFilters!['brand'] != null) {
        _selectedBrand = widget.initialFilters!['brand'];
      }

      if (widget.initialFilters!['minPrice'] != null &&
          widget.initialFilters!['maxPrice'] != null) {
        _priceRange = RangeValues(
          (widget.initialFilters!['minPrice'] as num).toDouble(),
          (widget.initialFilters!['maxPrice'] as num).toDouble(),
        );
      }

      if (widget.initialFilters!['minYear'] != null &&
          widget.initialFilters!['maxYear'] != null) {
        _yearRange = RangeValues(
          (widget.initialFilters!['minYear'] as num).toDouble(),
          (widget.initialFilters!['maxYear'] as num).toDouble(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView( // Ajout du scroll au cas où l'écran est petit
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrer les annonces',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== BRAND =====
                const Text('Marque', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  hint: const Text('Toutes les marques'),
                  items: _brands.map((brand) => DropdownMenuItem(
                    value: brand,
                    child: Text(brand),
                  ),
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedBrand = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== PRICE =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Prix (€)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${_priceRange.start.round()} - ${_priceRange.end.round()} €',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: _defaultMinPrice,
                  max: _defaultMaxPrice,
                  divisions: 100, // Plus fluide
                  labels: RangeLabels(
                    '${_priceRange.start.round()} €',
                    '${_priceRange.end.round()} €',
                  ),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),

                const SizedBox(height: 20),

                // ===== YEAR =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Année', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${_yearRange.start.round()} - ${_yearRange.end.round()}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _yearRange,
                  min: _defaultMinYear,
                  max: _currentMaxYear,
                  // Calcul dynamique des divisions pour éviter les crashs
                  divisions: (_currentMaxYear - _defaultMinYear).toInt() > 0
                      ? (_currentMaxYear - _defaultMinYear).toInt()
                      : 1,
                  labels: RangeLabels(
                    _yearRange.start.round().toString(),
                    _yearRange.end.round().toString(),
                  ),
                  onChanged: (values) => setState(() => _yearRange = values),
                ),

                const SizedBox(height: 24),

                // ===== ACTIONS =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // ACTION REINITIALISER CORRIGÉE
                          // On renvoie un Map vide signifiant "aucun filtre"
                          Navigator.pop(context, <String, dynamic>{});
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'brand': _selectedBrand,
                            'minPrice': _priceRange.start.round(),
                            'maxPrice': _priceRange.end.round(),
                            'minYear': _yearRange.start.round(),
                            'maxYear': _yearRange.end.round(),
                          });
                        },
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
