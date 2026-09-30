import '../../data/models/user_profile.dart';

/// Minimal structured context passed to the AI assistant
/// Protects privacy by avoiding sending entire raw databases
class AIRequestContext {
  final AppGoal goal;
  final String userName;
  final int currentCycleDay;
  final int cycleLength;
  final String cyclePhaseName;
  final String? pregnancyGestationalAge;
  final int? pregnancyTrimester;
  final List<String> recentSymptoms;

  const AIRequestContext({
    required this.goal,
    required this.userName,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.cyclePhaseName,
    this.pregnancyGestationalAge,
    this.pregnancyTrimester,
    this.recentSymptoms = const [],
  });

  Map<String, dynamic> toStructuredPromptData() {
    return {
      'user_goal': goal.name,
      'cycle_day': currentCycleDay,
      'typical_cycle_length': cycleLength,
      'current_phase_estimate': cyclePhaseName,
      'gestational_age_if_pregnant': pregnancyGestationalAge,
      'trimester_if_pregnant': pregnancyTrimester,
      'recent_symptoms_observed_by_user': recentSymptoms,
    };
  }
}

class AIResponse {
  final String text;
  final String? sourceCitation;
  final bool containsDoctorQuestions;
  final bool isOfflineFallback;

  const AIResponse({
    required this.text,
    this.sourceCitation,
    this.containsDoctorQuestions = false,
    this.isOfflineFallback = false,
  });
}

/// Abstract AI Service Interface
/// Implementations can be Local Fallback, Gemini API, or OpenAI API
abstract class AIService {
  static const String systemSafetyPrompt = '''
You are the WeTrack Educational Assistant, a calm, compassionate, and clinically disciplined reproductive health companion.
STRICT MEDICAL SAFETY BOUNDARIES:
1. NEVER DIAGNOSE: You are not a doctor. Never diagnose PCOS, endometriosis, infertility, miscarriage, infection, or any disease.
2. NEVER PRESCRIBE: Never recommend medications, herbs, or dosage alterations.
3. NEVER GUARANTEE: Never state that conception or contraception is guaranteed on any day. Always use probabilistic language: "estimated", "likely", "may vary".
4. SEPARATE FACTS FROM ESTIMATES: The user's logged bleeding is confirmed; calendar ovulation and fertile windows are statistical estimates.
5. URGENT SYMPTOMS: If the user mentions heavy bleeding, severe acute pelvic pain, high fever, fluid leak in pregnancy, or sudden vision loss, instruct them calmly but urgently to seek in-person medical care immediately.
6. SOURCE GROUNDING: Ground answers in American Society for Reproductive Medicine (ASRM) guidelines and standard clinical reproductive endocrinology.
''';

  Future<AIResponse> askQuestion({
    required AIRequestContext context,
    required String question,
  });
}
