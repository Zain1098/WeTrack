import 'ai_service.dart';

/// Local offline-first knowledge engine
/// Provides medically sourced, structured responses when offline or when no remote API key is active.
class LocalFallbackAIService implements AIService {
  @override
  Future<AIResponse> askQuestion({
    required AIRequestContext context,
    required String question,
  }) async {
    // Artificial slight delay for realistic conversational feel
    await Future.delayed(const Duration(milliseconds: 400));

    final q = question.toLowerCase();

    // 1. Refusal to diagnose PCOS / Endometriosis / Infertility
    if (q.contains('pcos') ||
        q.contains('polycystic') ||
        q.contains('endometriosis') ||
        q.contains('do i have')) {
      return const AIResponse(
        text:
            'I cannot provide a medical diagnosis for PCOS, endometriosis, or any clinical condition. Diagnosis requires professional clinical evaluation, specific blood hormone panels (such as LH, FSH, and androgens), and pelvic ultrasound imaging.\n\n'
            'Here are constructive questions you can take to your gynecologist:\n'
            '1. "Given my cycle lengths and symptoms, would you recommend hormone testing?"\n'
            '2. "Could a pelvic ultrasound help clarify my ovarian follicle count?"\n'
            '3. "What lifestyle or cycle monitoring steps are most appropriate for me?"',
        sourceCitation:
            'Rotterdam PCOS Diagnostic Criteria & ASRM Practice Guidelines',
        containsDoctorQuestions: true,
        isOfflineFallback: true,
      );
    }

    // 2. Explaining Cycle Days
    if (q.contains('cycle day') || q.contains('day mean') || q.contains('what phase')) {
      return AIResponse(
        text:
            'You are currently on Day ${context.currentCycleDay} of your cycle, which is estimated to be in your ${context.cyclePhaseName}.\n\n'
            '• Cycle Day 1 is the first day of full menstrual bleeding.\n'
            '• In a typical ${context.cycleLength}-day cycle, ovulation is estimated to occur around Day ${context.cycleLength - 14}.\n'
            '• Please note that calendar timing is an estimate and can vary by several days even among regular cycles.',
        sourceCitation: 'ASRM Optimizing Natural Fertility (2022)',
        isOfflineFallback: true,
      );
    }

    // 3. Fertile Window & Conception
    if (q.contains('fertile') || q.contains('conception') || q.contains('conceive') || q.contains('ovulation')) {
      return const AIResponse(
        text:
            'The American Society for Reproductive Medicine (ASRM) defines the fertile window as the 6-day interval ending on the day of ovulation.\n\n'
            'Clinical Observations:\n'
            '• Intercourse every 1 to 2 days during these 6 days maximizes conception likelihood.\n'
            '• Sperm can survive up to 5 days in fertile cervical mucus (egg-white or watery consistency).\n'
            '• Calendar predictions are approximations. Ovulation predictor kits (LH tests) and basal body temperature provide closer tracking.',
        sourceCitation: 'ASRM Committee Opinion on Natural Fertility',
        isOfflineFallback: true,
      );
    }

    // 4. Folic Acid Guidance
    if (q.contains('folic') || q.contains('vitamin') || q.contains('supplement')) {
      return const AIResponse(
        text:
            'Medical authorities, including ASRM and the CDC, recommend daily supplementation with 400 mcg of folic acid for all women of reproductive age who may become pregnant.\n\n'
            '• It helps significantly reduce the risk of major neural tube birth defects.\n'
            '• Ideally, it is started at least 1 month before conception and continued through the first trimester.\n'
            '• Check with your doctor if you have a family history or condition that may warrant a personalized dose.',
        sourceCitation: 'CDC & ASRM Nutritional Guidance',
        isOfflineFallback: true,
      );
    }

    // 5. Red Flag / Emergency Symptoms
    if (q.contains('pain') ||
        q.contains('bleed') ||
        q.contains('cramp') ||
        q.contains('emergency') ||
        q.contains('danger') ||
        q.contains('urgent')) {
      return const AIResponse(
        text:
            'URGENT SAFETY NOTICE:\n'
            'If you are experiencing severe, sudden pelvic pain, heavy bleeding (soaking a sanitary pad in an hour), fainting, high fever, or fluid leakage during pregnancy, please do not wait for app answers.\n\n'
            'Seek immediate medical evaluation from your healthcare clinician or visit the nearest emergency department.',
        sourceCitation: 'ACOG Emergency Obstetric Guidance',
        isOfflineFallback: true,
      );
    }

    // 6. Pregnancy Gestational Age & Milestones
    if (context.pregnancyGestationalAge != null &&
        (q.contains('pregnancy') || q.contains('week') || q.contains('baby') || q.contains('trimester'))) {
      return AIResponse(
        text:
            'You are currently tracking at ${context.pregnancyGestationalAge} (Trimester ${context.pregnancyTrimester ?? 1}).\n\n'
            '• Gestational age is counted from the first day of your last menstrual period (LMP) across a standard 40-week model.\n'
            '• Every baby develops at their own rate. Ultrasound scans by your clinician provide the most accurate anatomical dating.\n'
            '• Stay well hydrated and maintain regular prenatal checkups.',
        sourceCitation: 'ACOG Gestational Dating Standards',
        isOfflineFallback: true,
      );
    }

    // 7. General Educational Response
    return AIResponse(
      text:
          'WeTrack provides deterministic cycle calculations and ASRM-grounded guidance to support your reproductive journey.\n\n'
          'Key Things to Remember:\n'
          '• Your current phase estimate: ${context.cyclePhaseName} (Cycle Day ${context.currentCycleDay}).\n'
          '• Predictions adjust dynamically as you log more periods in the Calendar.\n'
          '• To discuss symptoms or irregularities with your doctor, bring your WeTrack cycle history summary to your appointment.',
      sourceCitation: 'WeTrack Clinical Education Knowledgebase',
      isOfflineFallback: true,
    );
  }
}
