import '../../data/models/user_profile.dart';
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
    await Future.delayed(const Duration(milliseconds: 300));

    final q = question.toLowerCase();
    final isRoman = context.isRomanUrdu;

    // 0. Red Flag / Urgent Medical Safety Notice (Highest Priority)
    if (q.contains('severe sudden pain') ||
        (q.contains('heavy') && q.contains('bleed')) ||
        q.contains('behoshi') ||
        q.contains('pani choot') ||
        q.contains('fluid leak') ||
        (q.contains('shadeed') && (q.contains('dard') || q.contains('khoon')))) {
      if (isRoman) {
        return const AIResponse(
          text:
              '🚨 **AHEM TIBBI HIDAYAT (URGENT SAFETY):**\n\n'
              'Agar aapko darj-zel mein se koi bhi takleef mehsoos ho to foran kisi qareebi hospital ya emergency clinic se rujoo karein:\n\n'
              '• Bohot shadeed pait ya pelvic dard jo bardasht na ho\n'
              '• Bohat zyada khoon aana (1 ghante mein poora sanitary pad geela ho jana)\n'
              '• Chakkar aana ya behoshi mehsoos hona\n'
              '• Hamal ke doran tez bukhar ya achanak pani choot jana\n\n'
              'Aisi soorat mein mobile app par waqt zaya na karein aur foran emergency medical care lein.',
          sourceCitation: 'ACOG Emergency Obstetric Guidance',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openEmergencyModal,
              label: 'Emergency Khatray Ki Alamaat Dekhein 🚨',
              icon: '⚠️',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'URGENT SAFETY NOTICE:\n'
              'If you experience sudden severe pelvic pain, heavy bleeding soaking a pad in an hour, fainting, high fever, or fluid leakage during pregnancy, Seek immediate medical evaluation at an emergency clinic.',
          sourceCitation: 'ACOG Emergency Obstetric Guidance',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openEmergencyModal,
              label: 'View Emergency Red Flags 🚨',
              icon: '⚠️',
            ),
          ],
        );
      }
    }

    // 1. Pregnancy Confirmation / Positive Test Detection (Top Priority)
    if (q.contains('pregnant') ||
        q.contains('pregnancy confirm') ||
        q.contains('pregnancy ho gai') ||
        q.contains('pregnancy ho gayi') ||
        q.contains('pregnancy ho gyi') ||
        q.contains('test positive') ||
        q.contains('positive test') ||
        q.contains('positive aya') ||
        q.contains('positive aaya') ||
        q.contains('hamal theher gaya') ||
        q.contains('hamal thehr gya') ||
        q.contains('hamal ho gaya') ||
        q.contains('hamal ho gya') ||
        q.contains('im pregnant') ||
        q.contains('i am pregnant') ||
        (q.contains('good news') && q.contains('hamal'))) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Mubarak ho! 🌸💖 Bohat bohat mubarak! Allah taala aapko aur bachay ko kamil sehat, aafiyat aur lambi umar ata farmaye.\n\n'
              '✨ **Ab Agla Marhala Kya Hai?**\n'
              '• Mahwari ka countdown ab rukh chuka hai kyun ke hamal mein periods nahi aate.\n'
              '• Rozana 400 mcg Folic Acid zaroor lein taake baby ka dimagh aur reerh ki haddi mehfooz rahay.\n'
              '• Khoob paani piyein aur bhari wazan uthane se perhez karein.\n'
              '• Gynecologist se pehla ultrasound (Dating Scan) taqreeban Hafta 6 se 8 ke darmiyan schedule karein.\n\n'
              'Main ne aapke liye app ka **Hamal (Pregnancy) Mode** tayyar kar diya hai. Neechay diye gaye button se foran apna naya safar active karein:',
          sourceCitation: 'ACOG & NICE Prenatal Guidelines',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.switchToPregnancy,
              label: 'Hamal Mode Activate Karein 🍼',
              icon: '🤰',
            ),
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'LMP / Ultrasound Date Confirm Karein 📅',
              icon: '✨',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Congratulations! 🌸 Wishing you and your baby good health and happiness.\n\n'
              'Key Early Steps:\n'
              '• Start daily 400 mcg Folic Acid immediately to prevent neural tube defects.\n'
              '• Schedule a dating ultrasound between 6 to 8 weeks with your clinician.\n'
              '• Menstruation is now suspended. Your tracker is ready to switch to Pregnancy Mode.\n\n'
              'Tap below to activate Pregnancy Mode:',
          sourceCitation: 'ACOG Prenatal Care Standards',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.switchToPregnancy,
              label: 'Activate Pregnancy Mode 🍼',
              icon: '🤰',
            ),
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'Confirm Due Date / Dating Method 📅',
              icon: '✨',
            ),
          ],
        );
      }
    }

    // 2. Postpartum Delivery / Period Resumed (Switch back to cycle)
    if (q.contains('baby deliver') ||
        q.contains('bacha paida') ||
        q.contains('delivery ho gayi') ||
        q.contains('delivery ho gai') ||
        q.contains('period wapas') ||
        q.contains('period wapis') ||
        q.contains('period aa gaya') ||
        q.contains('period shuru')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Delivery ke baad ka marhala bohot ahem hota hai! 🌸\n\n'
              '• Delivery ke baad 4 se 6 haftay tak khoon aana (Lochia) aam hota hai, ye aam mahwari nahi hoti.\n'
              '• Agar aap breastfeeding karwa rahi hain to periods 6 maah ya saal baad bhi shuru ho sakte hain.\n'
              '• Jab periods dobara shuru ho jayein to aap dobara Cycle Tracking Mode mein wapas aa sakti hain.\n\n'
              'Agar aap delivery ke baad cycle tracking dobara active karna chahti hain to tap karein:',
          sourceCitation: 'ACOG Postpartum Care Standards',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.switchToCycle,
              label: 'Cycle Tracking Mode Me Wapas Aayein 🌸',
              icon: '🔄',
            ),
            AIAction(
              type: AIActionType.openLogPeriod,
              label: 'Period Entry Log Karein 🩸',
              icon: '📝',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Postpartum recovery guidance:\n\n'
              '• Bleeding for 4-6 weeks after birth is lochia, not true menses.\n'
              '• If breastfeeding, true periods may resume later.\n'
              '• You can transition back to cycle tracking whenever ready:',
          sourceCitation: 'ACOG Postpartum Guidance',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.switchToCycle,
              label: 'Switch Back to Cycle Mode 🌸',
              icon: '🔄',
            ),
          ],
        );
      }
    }

    // 3. Late Period / Missed Period Analysis
    if (q.contains('late') ||
        q.contains('chadh gaya') ||
        q.contains('charh gaya') ||
        q.contains('missed period') ||
        q.contains('period nahi aaya') ||
        q.contains('period nahi aya') ||
        q.contains('upar ho gaye') ||
        q.contains('din charh')) {
      if (isRoman) {
        return AIResponse(
          text:
              'Period late hone ki sab se aam wajuhaat yeh ho sakti hain:\n\n'
              '1. **Hamal (Pregnancy):** Agar aap married hain aur fertile window mein contact hua tha, to ye sab se pehla imkaan hai.\n'
              '2. **Tanao (Stress) ya Safar:** Hormone imbalance se ovulation 3–7 din delay ho sakti hai.\n'
              '3. **Hormonal Fluctuation / PCOS:** Be-qaidagi ki wajah se period late ho sakta hai.\n\n'
              '🧪 **Aapko Kya Karna Chahiye?**\n'
              'Subah ke pehle peshab se Urine Pregnancy Test (strip) karein. Agar result positive aaye to foran Hamal Mode mein switch karein:',
          sourceCitation: 'ASRM & NHS Clinical Guidelines',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'Pregnancy Test Confirm / Log Karein 🧪',
              icon: '✨',
            ),
            AIAction(
              type: AIActionType.openLogSymptoms,
              label: 'Aaj Ke Symptoms Log Karein 📝',
              icon: '🩹',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Common reasons for a delayed or missed period:\n\n'
              '• Pregnancy: Test with first-morning urine if you had intercourse in your fertile window.\n'
              '• Stress, travel, or illness: Can delay ovulation and prolong cycle length.\n'
              '• Hormonal changes: Natural cycle variability.',
          sourceCitation: 'ASRM Guidance',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'Confirm / Log Pregnancy Test 🧪',
              icon: '✨',
            ),
          ],
        );
      }
    }

    // 4. Baby Kicks & Movement (Cardiff Count to 10)
    if (q.contains('kick') ||
        q.contains('harkat') ||
        q.contains('movement') ||
        q.contains('bacha hil') ||
        q.contains('halchal')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Baby ki harkat (kicks) bache ki sehat aur vitality ka sab se behtareen saboot hai! 👣\n\n'
              '🍼 **Harkat Kab Mehsoos Hoti Hai?**\n'
              'Aam tor par Hafta 18 se 24 ke darmiyan pehli halchal (quickening) mehsoos hoti hai.\n\n'
              '⏱️ **Cardiff Count-to-10 Rule (NHS & ACOG):**\n'
              '• Khana khane ke baad baanyi karwat (left side) par aaram se lait jayein.\n'
              '• 2 ghante ke andar baby ki kam az kam 10 harkatain (kicks, rolls ya flutter) ginni chahiyein.\n'
              '• Agar baby sota mehsoos ho to thanda paani piyein ya halka meetha snack lein.',
          sourceCitation: 'NHS & ACOG Fetal Movement Monitoring',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openKickCounter,
              label: '3D Baby Kicks Counter Kholein 👣',
              icon: '👶',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Fetal kick counts assess your baby\'s well-being:\n\n'
              '• Noticeable movement typically begins between 18–24 weeks.\n'
              '• Count to 10: Lie on your left side after a meal; expect 10 movements within 2 hours.\n'
              '• If movement is reduced, drink cold water and contact your clinician.',
          sourceCitation: 'ACOG Fetal Well-being Standards',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openKickCounter,
              label: 'Open Kick Counter 👣',
              icon: '👶',
            ),
          ],
        );
      }
    }

    // 5. Ultrasound, Sonogram, Scans & Doctor Checkups
    if (q.contains('ultrasound') ||
        q.contains('scan') ||
        q.contains('afi') ||
        q.contains('fhr') ||
        q.contains('placenta') ||
        q.contains('heart rate') ||
        q.contains('sonogram') ||
        q.contains('doctor visit') ||
        q.contains('checkup')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Ultrasound reports baby ki nashonuma samajhne ke liye bohot zaroori hain 🩺\n\n'
              '📋 **Ahem Ultrasound Marhale:**\n'
              '1. **Dating Scan (6–8 Weeks):** Dil ki dharkan (FHR 120–160 bpm) aur bache ka theek judna confirm karta hai.\n'
              '2. **Anomaly Scan (18–22 Weeks):** Poore jism ke aaza (brain, heart, limbs, kidneys) ka mukammal scan.\n'
              '3. **Growth & Fluid Scan (28–36 Weeks):** Bache ka wazan, placenta position, aur amniotic fluid (AFI paani 8–18 cm normal).\n\n'
              'Aap WeTrack app mein apna agla checkup schedule kar sakti hain:',
          sourceCitation: 'ISUOG Practice Guidelines for Obstetric Ultrasound',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openAppointmentModal,
              label: 'Doctor Appointment Note Karein 🩺',
              icon: '🏥',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Obstetric Ultrasound Milestones:\n\n'
              '• Dating Scan (6–8 Wks): Confirms cardiac activity (120–160 bpm) and gestational sac.\n'
              '• Anomaly Scan (18–22 Wks): Detailed anatomy survey.\n'
              '• Growth Scan (28–36 Wks): Evaluates AFI fluid (8–18 cm normal), fetal growth, and placenta.',
          sourceCitation: 'ISUOG Guidelines',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openAppointmentModal,
              label: 'Add Doctor Appointment 🩺',
              icon: '🏥',
            ),
          ],
        );
      }
    }

    // 6. Morning Sickness / Ulti & Nausea / Pregnancy Symptoms
    if (q.contains('ulti') ||
        q.contains('vomit') ||
        q.contains('nausea') ||
        q.contains('matli') ||
        q.contains('ghabrahat') ||
        q.contains('chakkar') ||
        q.contains('thakan') ||
        q.contains('cramp') ||
        q.contains('dard') ||
        q.contains('pain') ||
        q.contains('bleed') ||
        q.contains('khoon') ||
        q.contains('emergency') ||
        q.contains('khatra')) {
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
          actions: [
            AIAction(
              type: AIActionType.openLogSymptoms,
              label: 'Aaj Ke Symptoms Log Karein 📝',
              icon: '🩹',
            ),
          ],
        );
      } else {
        return const AIResponse(
          text:
              'Morning sickness affects many individuals in early pregnancy:\n\n'
              '• Keep bland crackers at your bedside and eat before getting up.\n'
              '• Eat small, frequent meals throughout the day.\n'
              '• Ginger, lemon water, and adequate hydration help relieve nausea.\n'
              '• Contact your doctor if you cannot retain fluids.',
          sourceCitation: 'ACOG Clinical Guidance',
          isOfflineFallback: true,
          actions: [
            AIAction(
              type: AIActionType.openLogSymptoms,
              label: 'Log Today\'s Symptoms 📝',
              icon: '🩹',
            ),
          ],
        );
      }
    }

    // 7. Refusal to diagnose PCOS / Endometriosis / Infertility
    if (q.contains('pcos') ||
        q.contains('polycystic') ||
        q.contains('endometriosis') ||
        q.contains('irregular') ||
        q.contains('be-qaida') ||
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

    // 8. Explaining Cycle Days & Current Phase
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

    // 9. Fertile Window & Conception / Milap
    if (q.contains('fertile') ||
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

    // 10. Pregnancy Test Timing & Strip
    if (q.contains('test') ||
        q.contains('strip') ||
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
          actions: [
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'Pregnancy Test Confirm / Log Karein 🧪',
              icon: '✨',
            ),
          ],
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
          actions: [
            AIAction(
              type: AIActionType.openPositiveTestModal,
              label: 'Confirm Pregnancy Test 🧪',
              icon: '✨',
            ),
          ],
        );
      }
    }

    // 11. Folic Acid & Vitamins
    if (q.contains('folic') ||
        q.contains('vitamin') ||
        q.contains('supplement') ||
        q.contains('iron') ||
        q.contains('goli')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Hamal ki planning aur early pregnancy mein Folic Acid sab se ahem vitamin hai.\n\n'
              '💊 **Folic Acid Kyun Zaroori Hai?**\n'
              '• Rozana **400 mcg** Folic Acid lene se bache ke dimagh aur reerh ki haddi ke nuqs (Neural Tube Defects) se 70% hifazat hoti hai.\n'
              '• Ise conceive karne se kam az kam 1 maah pehle shuru karna chahiye aur hamal ke pehle 12 hafte lazmi jari rakhna chahiye.\n\n'
              '🥦 **Qudrati Ghizayein:**\n'
              'Palak, daalein, malte (oranges), aur andon mein bhi qudrati folate paya jata hai.',
          sourceCitation: 'CDC & WHO Guideline on Daily Iron and Folic Acid Supplementation',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'Folic acid supplementation guidelines:\n\n'
              '• Take 400 mcg daily before conception through the first 12 weeks of pregnancy.\n'
              '• Reduces neural tube defect risks by up to 70%.\n'
              '• Dietary sources: spinach, lentils, fortified cereals, and citrus.',
          sourceCitation: 'CDC Guidelines',
          isOfflineFallback: true,
        );
      }
    }

    // 12. Cervical Mucus / Safed Pani
    if (q.contains('discharge') ||
        q.contains('safed pani') ||
        q.contains('mucus') ||
        q.contains('pani')) {
      if (isRoman) {
        return const AIResponse(
          text:
              'Harmones ki tabdeeli se mahwari ke mukhtalif dino mein discharge ki noiyat badalti rehti hai.\n\n'
              '💧 **Ovulation Ke Din (Egg White):**\n'
              'Jab safed pani anday ki safedi ki tarah shafaf aur kheenchne wala (stretchy) ho jaye to ye sab se ziyada fertile din hotay hain.\n\n'
              '⚠️ **Infection Ki Alamat:**\n'
              'Agar discharge mein shadeed badboo ho, rang peela ya sabz ho, ya khujli aur jalan mehsoos ho to ye infection (jaise yeast ya BV) ho sakta hai. Is soorat mein gynecologist ko zaroor check karwayein.',
          sourceCitation: 'Clinical Cervical Mucus Monitoring Standards',
          isOfflineFallback: true,
        );
      } else {
        return const AIResponse(
          text:
              'Cervical fluid changes across the cycle:\n\n'
              '• Fertile window: Clear, slippery, stretchy (raw egg-white consistency).\n'
              '• Non-fertile: Dry or sticky/creamy.\n'
              '• Consult a doctor if you notice malodor, itching, or green/yellow discoloration.',
          sourceCitation: 'Cervical Fluid Clinical Standards',
          isOfflineFallback: true,
        );
      }
    }

    // 13. Shohar / Husband Guidance
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
      } else {
        return const AIResponse(
          text:
              'Partner support guidance:\n\n'
              '• Conception is a shared journey; minimize pressure and stress.\n'
              '• Share the Husband Care guide from the app to keep your partner informed.',
          sourceCitation: 'WeTrack Partner Health Protocol',
          isOfflineFallback: true,
        );
      }
    }

    // 14. Pregnancy Gestational Age & Milestones
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

    // Default Fallback
    if (isRoman) {
      final nameStr = context.userName.isNotEmpty ? context.userName : 'Piyari Behan';
      return AIResponse(
        text:
            'Assalam-o-Alaikum $nameStr! 🌸\n\n'
            'Main aapki WeTrack Saathi hoon. Aap mujh se mahwari ke marhalon, ovulation, pregnancy confirmation, baby growth, ya doctor ke mashwaron ke baray mein be-jhijhak pooch sakti hain.\n\n'
            '💡 **Aapka Aaj Ka Status:**\n'
            '• Status: ${context.goal == AppGoal.alreadyPregnant ? "Hamal (Pregnancy) Active" : "Cycle Day ${context.currentCycleDay} (${context.cyclePhaseName})"}\n'
            '• Aam Cycle Length: **${context.cycleLength} din**\n\n'
            'Aap kis mozu par janna chahti hain? Apna sawaal likhein ya neechay topic choose karein.',
        sourceCitation: 'WeTrack Tibbi Rahnumai Knowledgebase',
        isOfflineFallback: true,
      );
    } else {
      return AIResponse(
        text:
            'Hello! I am your WeTrack AI Assistant.\n\n'
            '• Current Status: ${context.goal == AppGoal.alreadyPregnant ? "Pregnancy Mode Active" : "Day ${context.currentCycleDay} (${context.cyclePhaseName})"}\n'
            '• Estimated Cycle Length: ${context.cycleLength} days\n\n'
            'Ask me anything about your cycle, pregnancy milestones, or preparing questions for your doctor.',
        sourceCitation: 'WeTrack Clinical Education Knowledgebase',
        isOfflineFallback: true,
      );
    }
  }
}
