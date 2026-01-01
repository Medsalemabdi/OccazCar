// lib/features/ia/ai_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // COLLEZ VOTRE CLÉ D'API OBTENUE À L'ÉTAPE 1 ICI
  static const String _apiKey = 'Axxx';

  /// Génère une description de vente pour une voiture.
  Future<String> generateAdDescription({
    required String brand,
    required String model,
    required int year,
  }) async {
    // Crée une instance du modèle Gemini
    final model = GenerativeModel(
        model: 'gemma-3-2b', apiKey: _apiKey);

    // Le "prompt" : l'instruction que vous donnez à l'IA.
    final prompt =
        "Rédige une description de vente courte (environ 4 phrases), attractive et professionnelle pour une voiture. "
        "Utilise un ton engageant et rassurant. N'utilise pas d'emojis. "
        "Voici les détails de la voiture : Marque: $brand, Modèle: $model, Année: $year.";

    try {
      // Envoie la requête à l'IA et attend la réponse
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Impossible de générer une description pour le moment.";
    } catch (e) {
      print("Erreur lors de l'appel à l'API Gemini: $e");
      throw Exception("La génération de la description a échoué. Veuillez réessayer.");
    }
  }

  /// Analyse un rapport de dégâts et le formate
  String formatDamageReport(String rawReport) {
    if (rawReport.trim().isEmpty) return "Aucun dégât signalé.";
    return "Rapport de dégâts : ${rawReport.trim()}";
  }

  /// Donne des conseils pour des photos professionnelles.
  List<String> getPhotoTips() {
    return [
      "Conseil 1 : Lavez la voiture avant de prendre les photos.",
      "Conseil 2 : Prenez les photos à l'extérieur, avec une bonne lumière naturelle (matin ou fin d'après-midi).",
      "Conseil 3 : Prenez une photo de chaque côté (avant, arrière, gauche, droite).",
      "Conseil 4 : Prenez aussi des photos de l'intérieur (sièges, tableau de bord, compteur).",
    ];
  }
}
