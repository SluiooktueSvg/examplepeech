import 'package:firebase_ai/firebase_ai.dart';

class GenerativeAiService {
  final _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-pro');

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No se pudo obtener una respuesta.';
    } catch (e) {
      return 'Error al generar contenido: $e';
    }
  }
}
