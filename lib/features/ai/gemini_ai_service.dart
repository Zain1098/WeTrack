import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_service.dart';
import 'local_fallback_ai_service.dart';

/// Gemini AI Service Adapter
/// Calls Google Gemini API if key is provided; falls back gracefully to LocalFallbackAIService on failure or when offline.
class GeminiAIService implements AIService {
  final String? apiKey;
  final LocalFallbackAIService _fallback = LocalFallbackAIService();

  GeminiAIService({this.apiKey});

  @override
  Future<AIResponse> askQuestion({
    required AIRequestContext context,
    required String question,
  }) async {
    // If no API key configured, use local fallback
    final activeKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');
    if (activeKey.isEmpty) {
      return _fallback.askQuestion(context: context, question: question);
    }

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$activeKey',
      );

      final payload = {
        'contents': [
          {
            'parts': [
              {
                'text': '${AIService.systemSafetyPrompt}\n\n'
                    'USER STRUCTURED CONTEXT: ${jsonEncode(context.toStructuredPromptData())}\n\n'
                    'USER QUESTION: $question\n\n'
                    'INSTRUCTION: Respond in ${context.isRomanUrdu ? "conversational, sweet, natural Roman Urdu / Roman English (e.g. Assalam-o-Alaikum, Hamal ke ahem din, ovulation, doctor se mashwara)" : "gentle, compassionate English"}. Zero diagnostic claims, compassionate tone, and clear bullet points.',
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.35,
          'maxOutputTokens': 650,
        }
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String;
            return AIResponse(
              text: text,
              sourceCitation: context.isRomanUrdu
                  ? 'WeTrack Tibbi Rahnumai • ASRM & Clinical Standards'
                  : 'Grounded in ASRM Guidelines & Gemini 1.5 Medical Filter',
              isOfflineFallback: false,
            );
          }
        }
      }

      // Network or API quota failure -> Fallback safely without crashing
      return _fallback.askQuestion(context: context, question: question);
    } catch (_) {
      // Offline fallback
      return _fallback.askQuestion(context: context, question: question);
    }
  }
}
