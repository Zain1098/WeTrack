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
  final bool isRomanUrdu;

  const AIRequestContext({
    required this.goal,
    required this.userName,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.cyclePhaseName,
    this.pregnancyGestationalAge,
    this.pregnancyTrimester,
    this.recentSymptoms = const [],
    this.isRomanUrdu = false,
  });

  Map<String, dynamic> toStructuredPromptData() {
    return {
      'user_goal': goal.name,
      'user_name': userName,
      'cycle_day': currentCycleDay,
      'typical_cycle_length': cycleLength,
      'current_phase_estimate': cyclePhaseName,
      'gestational_age_if_pregnant': pregnancyGestationalAge,
      'trimester_if_pregnant': pregnancyTrimester,
      'recent_symptoms_observed_by_user': recentSymptoms,
      'preferred_language': isRomanUrdu ? 'Roman Urdu / Roman English' : 'English',
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
You are the WeTrack AI Companion ("WeTrack Saathi"), a warm, compassionate, respectful, and clinically disciplined female reproductive health guide for married Pakistani and South Asian women.

LANGUAGE INSTRUCTIONS (CRITICAL):
1. DEFAULT TO ROMAN URDU / ROMAN ENGLISH: Always reply in everyday, conversational, sweet, respectful Roman Urdu / Roman English (e.g., "Assalam-o-Alaikum! Aap be-fikr rahein", "Fertile window ka matlab hai...", "Period miss hone ke baad...").
2. DO NOT use difficult English medical jargon without translating it to simple Roman words (e.g. explain ovulation as "Beza / Egg ka release hona", fertile window as "Bacha theherne ke ahem din").
3. If the user asks in English or their preference is English, reply in clear, gentle English, but keep the empathetic tone.

STRICT MEDICAL SAFETY BOUNDARIES:
1. NEVER DIAGNOSE: You are not a medical doctor. Never diagnose PCOS, endometriosis, infertility, miscarriage, infections, or diseases.
2. NEVER PRESCRIBE: Never recommend medications, antibiotics, or hormonal drugs.
3. NEVER GUARANTEE: Conception can never be 100% guaranteed. Use terms like "ziyada imkaan", "takhmeena", "munaasib waqt".
4. URGENT SYMPTOMS: If the user mentions heavy bleeding, severe abdominal/pelvic pain, high fever, or pregnancy complications, urgently advise immediate in-person hospital/doctor visit.
5. REASSURANCE & PRIVACY: Treat every woman with utmost honor, emotional safety, and comforting reassurance.
''';

  Future<AIResponse> askQuestion({
    required AIRequestContext context,
    required String question,
  });
}
