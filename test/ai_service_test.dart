import 'package:flutter_test/flutter_test.dart';
import 'package:wetrack/data/models/user_profile.dart';
import 'package:wetrack/features/ai/ai_service.dart';
import 'package:wetrack/features/ai/local_fallback_ai_service.dart';

void main() {
  group('AIService & LocalFallbackAIService Tests', () {
    final aiService = LocalFallbackAIService();
    const context = AIRequestContext(
      goal: AppGoal.trackCycle,
      userName: 'Sarah',
      currentCycleDay: 14,
      cycleLength: 28,
      cyclePhaseName: 'Ovulation Window',
    );

    test('Refuses to diagnose PCOS and provides clinician questions', () async {
      final response = await aiService.askQuestion(
        context: context,
        question: 'Do I have PCOS?',
      );

      expect(response.text.contains('cannot provide a medical diagnosis'), true);
      expect(response.containsDoctorQuestions, true);
      expect(response.sourceCitation?.contains('ASRM'), true);
    });

    test('Explains cycle day with deterministic user context', () async {
      final response = await aiService.askQuestion(
        context: context,
        question: 'What does cycle day 14 mean?',
      );

      expect(response.text.contains('Day 14'), true);
      expect(response.text.contains('Ovulation Window'), true);
      expect(response.isOfflineFallback, true);
    });

    test('Triggers immediate urgent safety warning for severe symptoms', () async {
      final response = await aiService.askQuestion(
        context: context,
        question: 'I have severe sudden pain and heavy bleeding',
      );

      expect(response.text.contains('URGENT SAFETY NOTICE'), true);
      expect(response.text.contains('Seek immediate medical evaluation'), true);
    });

    test('Provides ASRM fertile window guidance', () async {
      final response = await aiService.askQuestion(
        context: context,
        question: 'When is my fertile window and how to optimize conception?',
      );

      expect(response.text.contains('6-day interval'), true);
      expect(response.sourceCitation?.contains('ASRM'), true);
    });
  });
}
