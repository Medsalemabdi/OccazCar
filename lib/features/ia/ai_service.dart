import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // ⚠️ Hugging Face Read Token
  static const String _apiKey = '**********************';

  static const String _endpoint =
      'https://router.huggingface.co/v1/chat/completions';

  static const String _model =
      'dphn/Dolphin-Mistral-24B-Venice-Edition:featherless-ai';

  /// Génère une description de vente pour une voiture.
  Future<String> generateAdDescription({
    required String brand,
    required String model,
    required int year,
  }) async {
    final prompt =
        "Rédige une description de vente courte (environ 4 phrases), "
        "attractive et professionnelle pour une voiture. "
        "Utilise un ton engageant et rassurant. "
        "N'utilise pas d'emojis.\n\n"
        "Détails :\n"
        "- Marque : $brand\n"
        "- Modèle : $model\n"
        "- Année : $year";

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
              'Tu es un assistant spécialisé dans la rédaction d’annonces automobiles.'
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'HuggingFace error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } catch (e) {
      print('Erreur API Hugging Face: $e');
      return "Erreur de génération. Veuillez réessayer.";
    }
  }

  /// Analyse un rapport de dégâts et le formate
  String formatDamageReport(String rawReport) {
    if (rawReport.trim().isEmpty) return "Aucun dégât signalé.";
    return "Rapport de dégâts : ${rawReport.trim()}";
  }

  /// Donne des conseils pour des photos professionnelles.
  List<String> getPhotoTips() {
    return const [
      "Conseil 1 : Lavez la voiture avant de prendre les photos.",
      "Conseil 2 : Prenez les photos à l'extérieur, avec une bonne lumière naturelle.",
      "Conseil 3 : Photographiez chaque côté du véhicule.",
      "Conseil 4 : Incluez l’intérieur (sièges, tableau de bord, compteur).",
    ];
  }
}
