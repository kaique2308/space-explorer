import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // MyMemory API — gratuita, sem necessidade de chave
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  // Cache para não traduzir o mesmo texto duas vezes
  static final Map<String, String> _cache = {};

  /// Traduz um texto do inglês para português
  static Future<String> translateToPtBr(String text) async {
    if (text.isEmpty) return text;

    // Retorna do cache se já foi traduzido antes
    if (_cache.containsKey(text)) return _cache[text]!;

    try {
      // MyMemory tem limite de 500 chars por requisição
      // Para textos grandes, dividimos em partes
      if (text.length > 450) {
        return await _translateLongText(text);
      }

      final translated = await _translateChunk(text);
      _cache[text] = translated;
      return translated;
    } catch (e) {
      // Se falhar, retorna o texto original em inglês
      return text;
    }
  }

  /// Traduz um chunk de até 450 caracteres
  static Future<String> _translateChunk(String text) async {
    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=en|pt-br',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final translated = json['responseData']['translatedText'] as String?;
      if (translated != null && translated.isNotEmpty) {
        return translated;
      }
    }
    return text; // fallback
  }

  /// Divide textos longos em sentenças e traduz cada uma
  static Future<String> _translateLongText(String text) async {
    // Divide por frases (ponto final)
    final sentences = text.split('. ');
    final buffer = StringBuffer();
    String currentChunk = '';

    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      final toAdd = i < sentences.length - 1 ? '$sentence. ' : sentence;

      if ((currentChunk + toAdd).length > 450) {
        // Traduz o chunk atual
        if (currentChunk.isNotEmpty) {
          final translated = await _translateChunk(currentChunk.trim());
          buffer.write('$translated ');
          currentChunk = toAdd;
        } else {
          // Sentença muito longa, traduz direto mesmo assim
          final translated = await _translateChunk(toAdd.trim());
          buffer.write('$translated ');
        }
      } else {
        currentChunk += toAdd;
      }
    }

    // Traduz o último chunk restante
    if (currentChunk.isNotEmpty) {
      final translated = await _translateChunk(currentChunk.trim());
      buffer.write(translated);
    }

    return buffer.toString().trim();
  }
}
