import 'package:firebase_ai/firebase_ai.dart';

class GenerativeAiService {
  final _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No se pudo obtener una respuesta.';
    } catch (e) {
      return 'Error al generar contenido: $e';
    }
  }
}
