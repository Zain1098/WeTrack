import 'ai_service.dart';

/// Local offline-first knowledge engine
/// Provides medically sourced, structured responses in Roman Urdu & English
/// when offline or when no remote API key is active.
class LocalFallbackAIService implements AIService {
  @override
  Future<AIResponse> askQuestion({
    required AIRequestContext context,
    required String question,
  }) async {
    // Artificial slight delay for realistic conversational feel
    await Future.delayed(const Duration(milliseconds: 350));

    final q = question.toLowerCase();
    final isRoman = context.isRomanUrdu;

    // 1. Refusal to diagnose PCOS / Endometriosis / Infertility
    if (q.contains('pcos') ||
        q.contains('polycystic') ||
        q.contains('endometriosis') ||
        q.contains('irregular') ||
        q.contains('be-qaida') ||
        q.contains('late period') ||
        q.contains('do i have')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Main ek educational saathi hoon aur kisi bimari ki clinical tashkhees (diagnosis) nahi kar sakti, lekin main aapko iski ahem baatein asaan alfaz mein samjha sakti hoon.\n\n'
              '🌸 **PCOS Kya Hota Hai?**\n'
              'PCOS mein harmones ke adam-tawazun (imbalance) ki wajah se periods der se aate hain ya skip ho jate hain. Chehre par an-chahay baal ya wazan barhna iski aam alamat hain.\n\n'
              '🩺 **Doctor se Poochne Ke Ahem Sawalaat:**\n'
              '1. "Doctor sahiba, meri cycle be-qaida rehti hai, kya mujhe hormone tests (LH, FSH, Androgens) karwane chahiye?"\n'
              '2. "Kya pelvic ultrasound se ovaries mein cysts ya follicles ka pata chal sakta hai?"\n'
              '3. "Diet aur lifestyle mein aisi kaun si tabdeeli karoon jo meri cycle regular kare?"\n\n'
              '💡 **Pur-sakoon Rahein:**\n'
              'PCOS ka ilaaj aur lifestyle changes se cycle theek ho sakti hai aur pregnancy bilkul mumkin hoti hai.',
          sourceCitation: 'ASRM Guidelines & Rotterdam PCOS Criteria',
          containsDoctorQuestions: true,
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'I cannot provide a medical diagnosis for PCOS, endometriosis, or any clinical condition. Diagnosis requires clinical evaluation, hormone panels, and ultrasound imaging.\n\n'
              'Questions for your doctor:\n'
              '1. "Given my cycle lengths, would you recommend hormone testing?"\n'
              '2. "Could an ultrasound clarify my ovarian follicle count?"\n'
              '3. "What lifestyle or cycle monitoring steps are appropriate for me?"',
          sourceCitation: 'Rotterdam PCOS Diagnostic Criteria & ASRM Guidelines',
          containsDoctorQuestions: true,
          isOfflineFallback: true,
        );
      }
    }

    // 2. Explaining Cycle Days & Current Phase
    if (q.contains('cycle day') ||
        q.contains('aaj ka din') ||
        q.contains('marhala') ||
        q.contains('phase') ||
        q.contains('day mean') ||
        q.contains('what phase')) {
      if (isRoman) {
        return AIResponse(
          text:
              'Aap aaj apni cycle ke **Day ${context.currentCycleDay}** par hain (${context.cyclePhaseName} phase).\n\n'
              '🌸 **Cycle Day 1 Kya Hota Hai?**\n'
              'Jis din proper khul kar mahwari (bleeding) shuru hoti hai, usay Cycle Day 1 kehte hain. Sirf halki spotting ko Day 1 shumar nahi kiya jata.\n\n'
              '📅 **Ovulation Aur Aglay Period Ka Hisaab:**\n'
              'Aapki aam cycle taqreeban ${context.cycleLength} dinon ki hoti hai. Ovulation aam tor par aglay expected period se 14 din pehle hoti hai.\n\n'
              '💡 **Ahem Mashwara:**\n'
              'Rozana apne symptoms aur dates log karti rahein taake calendar ka takhmeena har maah mazeed accurate hota jaye.',
          sourceCitation: 'ASRM Optimizing Natural Fertility (2022)',
          isOfflineFallback: true,
        );
      } else {
        return AIResponse(
          text:
              'You are currently on Day ${context.currentCycleDay} of your cycle (${context.cyclePhaseName}).\n\n'
              '• Cycle Day 1 is the first day of full menstrual flow.\n'
              '• In a ${context.cycleLength}-day cycle, ovulation typically occurs around Day ${context.cycleLength - 14}.\n'
              '• Calendar dates are statistical estimates and may naturally fluctuate.',
          sourceCitation: 'ASRM Optimizing Natural Fertility',
          isOfflineFallback: true,
        );
      }
    }

    // 3. Fertile Window & Conception / Milap
    if (q.contains('fertile') ||
        q.contains('hamal') ||
        q.contains('conceive') ||
        q.contains('bacha') ||
        q.contains('milap') ||
        q.contains('ovulation') ||
        q.contains('sex') ||
        q.contains('sperm')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Hamal theherne ke liye **Fertile Window** sab se ahem din hote hain.\n\n'
              '✨ **Sab Se Ziyada Pregnancy Chance Wale Din:**\n'
              '• Ovulation se 3 se 4 din pehle aur ovulation ke din pregnancy ke chances sab se zyada hote hain.\n'
              '• Shohar ka sperm aurat ke jism mein 3 se 5 din tak zinda reh sakta hai, jabke beza (egg) release hone ke baad sirf 12 se 24 ghante rehta hai.\n\n'
              '💑 **Intercourse / Taluq Ka Behtareen Schedule:**\n'
              'Fertile window ke doran har 1 ya 2 din baad intercourse karna sab se munasib rehta hai. Stress bilkul na lein aur pursakoon rahein.\n\n'
              '💧 **Jism Ka Ishara:**\n'
              'Jab safed pani anday ki safedi ki tarah lacheela (stretchy) aur shafaf ho jaye, to ye ovulation ka sab se behtareen waqt hota hai.',
          sourceCitation: 'ASRM Practice Committee on Natural Fertility',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'The fertile window is the 6-day interval ending on ovulation day.\n\n'
              '• Intercourse every 1–2 days during this window optimizes conception probability.\n'
              '• Sperm survives up to 5 days in fertile cervical mucus.\n'
              '• Ovulation predictor kits (LH tests) provide confirmation alongside cycle tracking.',
          sourceCitation: 'ASRM Practice Committee on Natural Fertility',
          isOfflineFallback: true,
        );
      }
    }

    // 4. Pregnancy Test Timing
    if (q.contains('test') ||
        q.contains('strip') ||
        q.contains('positive') ||
        q.contains('negative') ||
        q.contains('faint line') ||
        q.contains('kab karoon')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Pregnancy test sahi waqt par karna bohot zaroori hai taake result wazeh aur yaqeeni ho.\n\n'
              '🧪 **Test Kab Karna Chahiye?**\n'
              '• Sab se behtareen waqt period ki expected date guzarne (miss hone) ke **1 se 2 din baad** hai.\n'
              '• Subah ka pehla peshab (first morning urine) use karein kyun ke usme hCG hormone ki concentration sab se zyada hoti hai.\n\n'
              '🔍 **Halki (Faint) Line Ka Matlab:**\n'
              'Agar test strip par doosri line halki si bhi nazar aaye to ye aksar positive shumar hoti hai, bas hCG hormone abhi kam hota hai. 2 din baad dobara test karein ya clinic se Serum Beta hCG blood test karwayein.',
          sourceCitation: 'ACOG Clinical Laboratory Standards',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'For accurate pregnancy testing:\n\n'
              '• Test 1–2 days after a missed period for highest sensitivity.\n'
              '• Use first-morning urine which contains concentrated hCG.\n'
              '• A faint second line generally indicates early pregnancy; repeat in 48 hours to confirm progression.',
          sourceCitation: 'ACOG Laboratory Guidance',
          isOfflineFallback: true,
        );
      }
    }

    // 5. Folic Acid & Vitamins
    if (q.contains('folic') ||
        q.contains('vitamin') ||
        q.contains('supplement') ||
        q.contains('dawai') ||
        q.contains('iron')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Folic Acid har us larki ke liye nihayat zaroori hai jo pregnancy plan kar rahi ho ya pregnant ho.\n\n'
              '💊 **Folic Acid Kyun Zaroori Hai?**\n'
              '• Ye baby ke dimagh aur reedh ki haddi ke ahem naqs (Neural Tube Defects) se hifazat karti hai.\n'
              '• Hamal theherne se kam az kam **1 maah pehle** rozana 400 mcg lena standard recommendation hai.\n'
              '• Pehle teen mahine (First Trimester) iska rozana istemal jari rakhna chahiye.\n\n'
              '🥗 **Ghiza:** Palak, daalein, anday aur sabziyan bhi khorak mein shamil karein aur doctor se regular prenatal multi-vitamin likhwayein.',
          sourceCitation: 'CDC & ASRM Nutritional Guidelines',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'Daily supplementation with 400 mcg of folic acid is strongly recommended prior to conception and through the first trimester to prevent neural tube defects.\n\n'
              'Consult your physician for personalized prenatal multi-vitamin requirements.',
          sourceCitation: 'CDC & ASRM Nutritional Guidance',
          isOfflineFallback: true,
        );
      }
    }

    // 6. Cervical Mucus / Safed Pani
    if (q.contains('pani') ||
        q.contains('discharge') ||
        q.contains('white') ||
        q.contains('safed') ||
        q.contains('mucus') ||
        q.contains('khujli')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Aurat ke jism mein discharge aana ek qudrati aur sehatmand amal hai jo cycle ke sath tabdeel hota hai.\n\n'
              '💧 **Ovulation Ka Pani (Fertile Window):**\n'
              'Ovulation ke qareeb pani anday ki safedi ki tarah shafaf, phisalne wala aur kheenchnay wala (stretchy) ho jata hai. Ye sperm ko tezi se beza tak pohnchanay mein madad deta hai.\n\n'
              '⚠️ **Infection Ki Alamat:**\n'
              'Agar discharge mein shadeed badboo ho, rang peela ya sabz ho, ya khujli aur jalan mehsoos ho to ye infection (jaise yeast ya BV) ho sakta hai. Is soorat mein gynecologist ko zaroor check karwayein.',
          sourceCitation: 'Clinical Cervical Mucus Monitoring Standards',
          isOfflineFallback: true,
        );
      }
    }

    // 7. Red Flag / Emergency Symptoms
    if (q.contains('pain') ||
        q.contains('bleed') ||
        q.contains('cramp') ||
        q.contains('dard') ||
        q.contains('khoon') ||
        q.contains('emergency') ||
        q.contains('danger') ||
        q.contains('khatra') ||
        q.contains('urgent')) {
      if (isRoman) {
        return const AIResponse(
          text:
              '🚨 **AHEM TIBBI HIDAYAT (URGENT SAFETY):**\n\n'
              'Agar aapko darj-zel mein se koi bhi takleef mehsoos ho to foran kisi qareebi hospital ya gynecologist se rujoo karein:\n\n'
              '• Bohot shadeed pait ya pelvic dard jo bardasht na ho\n'
              '• Bohat zyada khoon aana (1 ghante mein poora sanitary pad geela ho jana)\n'
              '• Chakkar aana ya behoshi mehsoos hona\n'
              '• Hamal ke doran tez bukhar ya achanak pani choot jana\n\n'
              'Aisi soorat mein mobile app par waqt zaya na karein aur foran emergency medical care lein.',
          sourceCitation: 'ACOG Emergency Obstetric Guidance',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'URGENT SAFETY NOTICE:\n'
              'If you experience sudden severe pelvic pain, heavy bleeding soaking a pad in an hour, fainting, high fever, or fluid leakage during pregnancy, Seek immediate medical evaluation at an emergency clinic.',
          sourceCitation: 'ACOG Emergency Obstetric Guidance',
          isOfflineFallback: true,
        );
      }
    }

    // 8. Morning Sickness / Ulti & Nausea
    if (q.contains('ulti') ||
        q.contains('vomit') ||
        q.contains('nausea') ||
        q.contains('matli') ||
        q.contains('ghabrahat') ||
        q.contains('chakkar')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Hamal ke shuruati 12 hafton mein ulti aur matli (Morning Sickness) aam hoti hai jo pregnancy hormones (hCG aur estrogen) ki wajah se hoti hai.\n\n'
              '🍋 **Aasan Rahat Ke Tareeqay:**\n'
              '• Subah bistar se uthne se pehle halka sookha rusk ya biscuit khayein.\n'
              '• Din bhar thora thora khana khayein, pait ko bilkul khali na hone dein.\n'
              '• Lemon water (neemboo paani) ya adrak (ginger) ka halka qehwa matli ko kam karta hai.\n'
              '• Tali hui aur bohot masalay-daar cheezon se parhez karein.\n\n'
              'Agar paani bhi pait mein na rukay aur wazan kam hone lage to doctor se safe anti-nausea dawai likhwayein.',
          sourceCitation: 'ACOG Clinical Guidance on Nausea and Vomiting in Pregnancy',
          isOfflineFallback: true,
        );
      }
    }

    // 9. Questions for Doctor
    if (q.contains('doctor') ||
        q.contains('sawal') ||
        q.contains('checkup') ||
        q.contains('gynecologist') ||
        q.contains('hospital')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Doctor ke paas jaane se pehle tayyari karna bohot faidamand rehta hai.\n\n'
              '📋 **Doctor se Poochne Ke Ahem Sawalaat:**\n'
              '1. "Meri pichli cycles ka record ye hai, kya meri ovulation regular chal rahi hai?"\n'
              '2. "Hamal plan karne ke liye kaun se khoon ke test (Hb, Thyroid, Blood Group, Rubella) karwana zaroori hain?"\n'
              '3. "Kya mujhe Folic Acid ke sath koi iron ya multi-vitamin shuru karni chahiye?"\n'
              '4. "Agar cycle mein spotting ya dard ho to kis waqt doctor ko dikhana zaroori hai?"\n\n'
              'Aap WeTrack app ka **Cycle Hisaab** page doctor ko dikha sakti hain taake unhein aapki cycle history asaani se samajh aa sakay.',
          sourceCitation: 'WeTrack Clinical Preparation Checklist',
          containsDoctorQuestions: true,
          isOfflineFallback: true,
        );
      }
    }

    // 10. Shohar / Husband Guidance
    if (q.contains('shohar') ||
        q.contains('husband') ||
        q.contains('partner') ||
        q.contains('madad')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Hamal ki planning aur pregnancy mein shohar ka sath aur jazbaati sahara (emotional support) 50% hissa rakhta hai.\n\n'
              '🧔 **Shohar Ke Liye Ahem Baatein:**\n'
              '• Hamal theherna dono ka mushtarka safar hai, kisi ek par bojh ya tanao (stress) na banayein.\n'
              '• Mahwari se pehle biwi ke mood mein tabdeeli harmones ki wajah se hoti hai, is doran pyar aur sabr ka muzahira karein.\n'
              '• Fertile window ke dino mein stress-free mahol rakhein.\n\n'
              'Aap WeTrack app mein **Shohar Card** share karke unhein ba-asaani educate kar sakti hain!',
          sourceCitation: 'WeTrack Couple Reproductive Health Protocol',
          isOfflineFallback: true,
        );
      }
    }

    // 11. Pregnancy Gestational Age & Milestones
    if (context.pregnancyGestationalAge != null &&
        (q.contains('pregnancy') ||
            q.contains('week') ||
            q.contains('baby') ||
            q.contains('hafte') ||
            q.contains('trimester'))) {
      if (isRoman) {
        return AIResponse(
          text:
              'Mubarak ho! Aap is waqt **${context.pregnancyGestationalAge}** par hain (Trimester ${context.pregnancyTrimester ?? 1}).\n\n'
              '👶 **Baby Ki Development:**\n'
              '• Gestational age aapke aakhri period (LMP) ke pehle din se count hoti hai (Standard 40-week model).\n'
              '• Har baby apni raftaar se barhta hai. Ultrasound scan se exact size aur delivery date (EDD) confirm hoti hai.\n'
              '• Paani ka zyada istemal karein, wazan uthane se gurez karein aur regular doctor visits miss na karein.',
          sourceCitation: 'ACOG Gestational Dating Standards',
          isOfflineFallback: true,
        );
      } else {
        return AIResponse(
          text:
              'You are tracking at ${context.pregnancyGestationalAge} (Trimester ${context.pregnancyTrimester ?? 1}).\n\n'
              '• Gestational age is measured from your last menstrual period.\n'
              '• Maintain hydration, rest, and regular prenatal checkups.',
          sourceCitation: 'ACOG Gestational Dating Standards',
          isOfflineFallback: true,
        );
      }
    }

    // 12. General Educational Response in Roman Urdu
    if (isRoman) {
      final nameStr = context.userName.isNotEmpty ? context.userName : 'Piyari Behan';
      return AIResponse(
        text:
            'Assalam-o-Alaikum $nameStr! 🌸\n\n'
            'Main aapki WeTrack Saathi hoon. Aap mujh se mahwari ke marhalon, ovulation, bacha theherne ke ahem dinon, ya pregnancy ke baray mein be-jhijhak pooch sakti hain.\n\n'
            '💡 **Aapka Aaj Ka Status:**\n'
            '• Cycle Day: **Day ${context.currentCycleDay}** (${context.cyclePhaseName})\n'
            '• Aam Cycle Length: **${context.cycleLength} din**\n\n'
            'Aap kis mozu par janna chahti hain? Neechay diye gaye topics par tap karein ya apna sawaal likhein.',
        sourceCitation: 'WeTrack Tibbi Rahnumai Knowledgebase',
        isOfflineFallback: true,
      );
    } else {
      return AIResponse(
        text:
            'Hello! I am your WeTrack AI Assistant.\n\n'
            '• Current Status: Day ${context.currentCycleDay} (${context.cyclePhaseName})\n'
            '• Estimated Cycle Length: ${context.cycleLength} days\n\n'
            'Ask me anything about your cycle, fertile window, or doctor preparations.',
        sourceCitation: 'WeTrack Clinical Education Knowledgebase',
        isOfflineFallback: true,
      );
    }
  }
}
