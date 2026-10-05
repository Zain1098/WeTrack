import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_pill.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';

class LearnArticle {
  final String id;
  final String titleUrdu;
  final String titleEnglish;
  final String categoryKey; // 'all', 'myths', 'fertility', 'cycle', 'pregnancy', 'safety'
  final String summaryUrdu;
  final String summaryEnglish;
  final String contentUrdu;
  final String contentEnglish;
  final String source;
  final String reviewDate;

  const LearnArticle({
    required this.id,
    required this.titleUrdu,
    required this.titleEnglish,
    required this.categoryKey,
    required this.summaryUrdu,
    required this.summaryEnglish,
    required this.contentUrdu,
    required this.contentEnglish,
    required this.source,
    required this.reviewDate,
  });

  String title(bool isRomanUrdu) => isRomanUrdu ? titleUrdu : titleEnglish;
  String summary(bool isRomanUrdu) => isRomanUrdu ? summaryUrdu : summaryEnglish;
  String content(bool isRomanUrdu) => isRomanUrdu ? contentUrdu : contentEnglish;
}

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String _selectedCategoryKey = 'all';

  static const List<LearnArticle> _articles = [
    // 1. Desi Myths vs Facts (Top Priority)
    LearnArticle(
      id: 'myth_legs_up',
      categoryKey: 'myths',
      titleUrdu: 'Myth: Intercourse Ke Baad Taangein Upar Rakhna Zaroori Hai?',
      titleEnglish: 'Myth: Must Keep Legs Elevated After Intercourse?',
      summaryUrdu: 'Khandani mashwaray ke mutabiq ghanto taangein upar rakhna zaroori samjha jata hai. Haqeeqat kya hai?',
      summaryEnglish: 'Is elevating legs against a wall necessary for sperm to reach the egg?',
      contentUrdu:
          'Haqeeqat (ASRM Medical Facts):\n• Medical science aur ASRM guidelines ke mutabiq kisi aisi position ya taangein ghanto deewar ke sath lagane ka conception chance par koi asar sabit nahi hua.\n• Ejaculation ke chand seconds mein million sperm cervix ke raste uterus mein daakhil ho chuke hotay hain.\n• Intercourse ke baad sirf 5 se 10 minute aaram se seedha laitna kaafi hota hai. Extra fluid ka bahar nikalna bilkul normal hai, sperm andar ja chuka hota hai.',
      contentEnglish:
          'Clinical Reality (ASRM Standards):\n• Millions of motile sperm enter the cervical mucus within seconds of ejaculation.\n• No randomized study has shown higher pregnancy rates from prolonged leg elevation or acrobatics.\n• Resting comfortably on your back for 5-10 minutes is more than sufficient. Excess semen fluid escaping is completely normal.',
      source: 'American Society for Reproductive Medicine (ASRM) Practice Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'myth_hot_foods',
      categoryKey: 'myths',
      titleUrdu: 'Myth: Garam Cheezein (Anday, Machli) Khane Se Hamal Rukta Hai?',
      titleEnglish: 'Myth: Do "Hot" Foods Like Eggs & Fish Cause Miscarriage?',
      summaryUrdu: 'Kya baby planning ya early pregnancy mein garam taseer wali ghizayein khatarnak hain?',
      summaryEnglish: 'Are culturally considered "heaty" foods harmful when trying to conceive?',
      contentUrdu:
          'Haqeeqat (Clinical Nutritional Facts):\n• Medical science mein "garam" ya "thandi" taseer ka koi scientific tasawwur nahi hai.\n• Anday aur machli (fish) high-quality protein, choline aur Omega-3 fatty acids provide karte hain jo egg quality aur baby ke brain development ke liye behtareen hain.\n• Sirf kachi (uncooked) machli ya raw eggs se perhez karein taake infection na ho. Paka kar khana bilkul mehfooz aur mufeed hai.',
      contentEnglish:
          'Clinical Reality (ACOG & NHS Guidelines):\n• Modern nutritional biology has no concept of "heaty" or "cold" food temperaments.\n• Eggs and well-cooked fish supply high-grade choline, iron, and DHA omega-3 essential for neurogenesis and healthy ovulatory function.\n• Avoid only raw or undercooked seafood/poultry to prevent salmonella/listeria infections. Well-cooked portions are thoroughly safe.',
      source: 'NHS UK & ACOG Maternal Nutrition Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'myth_period_conception',
      categoryKey: 'myths',
      titleUrdu: 'Myth: Period Khatam Hote Hi Conceive Nahi Ho Sakta?',
      titleEnglish: 'Myth: Can Conception Happen Immediately After Period Ends?',
      summaryUrdu: 'Kya period ke foran agle din milap se pregnancy ho sakti hai?',
      summaryEnglish: 'Can unprotected intercourse right after bleeding ceases result in pregnancy?',
      contentUrdu:
          'Haqeeqat (Ovulation & Sperm Lifespan):\n• Agar kisi aurat ka cycle short ho (e.g. 21–24 din), to ovulation period khatam hone ke foran baad Day 8 ya 9 par ho sakti hai.\n• Sperm female body ke andar 3 se 5 din tak zinda reh sakta hai.\n• Is liye agar period ke aakhri din ya foran baad unprotected intercourse ho, to conception ke genuine chances hotay hain.',
      contentEnglish:
          'Clinical Reality (Follicular Timeline & Sperm Viability):\n• In women with shorter menstrual cycles (21-24 days), ovulation can occur as early as Cycle Day 8 or 9.\n• Because healthy sperm can survive up to 5 days inside alkaline cervical crypts, intercourse at the end of menses can indeed yield conception.',
      source: 'Human Reproduction & Fertility Science Standards',
      reviewDate: 'Updated 2026',
    ),

    // 2. Fertility & Milap
    LearnArticle(
      id: 'asrm_fertility',
      categoryKey: 'fertility',
      titleUrdu: 'Fertile Window Aur Milap Ka Sahi Waqt (ASRM Guidelines)',
      titleEnglish: 'Fertile Window & Optimal Intercourse Timing (ASRM)',
      summaryUrdu: 'Cycle ke 6 sab se ahem din aur intercourse ka sahi schedule samajhein.',
      summaryEnglish: 'Clinical timing for the 6 critical fertile days to maximize conception.',
      contentUrdu:
          'ASRM (American Society for Reproductive Medicine) ke mutabiq:\n\n• Fertile Window: Ovulation ke din se pehle ke 5 din aur ovulation ka din mil kar 6 din bante hain.\n• Intercourse Schedule: Fertile window ke dauran har 1–2 din intercourse karna conception ke chances ko maximum karta hai.\n• Stress Se Bachein: Rozana strict timing ka zehni dabao na lein, pur-sukoon mahol aur mutual comfort sab se ahem hai.',
      contentEnglish:
          'ASRM Clinical Practice Guidelines:\n\n• The Fertile Window consists of the 5 days prior to ovulation plus the day of ovulation.\n• Intercourse frequency: Having intercourse every 1 to 2 days during this interval yields the highest clinical fecundability.\n• Minimizing stress and maintaining comfort are key for physiological well-being.',
      source: 'ASRM Practice Committee Guidance',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'folic_acid_guide',
      categoryKey: 'fertility',
      titleUrdu: 'Folic Acid (400 mcg) Kyun Zaroori Hai?',
      titleEnglish: 'Why Daily Folic Acid (400 mcg) Is Essential',
      summaryUrdu: 'Baby planning ke dauran rozana 400 mcg Folic Acid lene ki wajohaat.',
      summaryEnglish: 'Preconception supplementation guidelines from WHO, CDC & NHS.',
      contentUrdu:
          'Har aurat jo pregnancy plan kar rahi ho, usay conceiving se kam az kam 1 maah pehle rozana 400 mcg Folic Acid shuru karni chahiye.\n\nFaide:\n• Baby ke dimaagh (brain) aur reedh ki haddi (spine) ke congenital defects (Spina Bifida) se 70% tak hifazat.\n• Early cellular division mein madadgar.\n• Pehle 12 hafton tak rozana continue rakhna lazmi hai.',
      contentEnglish:
          'Preconception Clinical Evidence (WHO & CDC):\n\n• Taking 400 mcg of synthetic folic acid daily at least 1 month before conception reduces neural tube defects (like spina bifida and anencephaly) by up to 70%.\n• Critical for early embryonic DNA synthesis and rapid cellular division.\n• Must be maintained through the entire first trimester (12 weeks).',
      source: 'WHO, CDC & NHS Preconception Protocol',
      reviewDate: 'Updated 2026',
    ),

    // 3. Cycle & Hormones
    LearnArticle(
      id: 'cycle_phases_roman',
      categoryKey: 'cycle',
      titleUrdu: 'Mahwari (Cycle) Ke 4 Ahem Marahil',
      titleEnglish: 'The 4 Distinct Menstrual Cycle Phases',
      summaryUrdu: 'Menstrual, Follicular, Ovulation aur Luteal phases mein jism mein kya hota hai?',
      summaryEnglish: 'What happens hormonally across Menstrual, Follicular, Ovulatory, and Luteal phases.',
      contentUrdu:
          '1. Menstrual Phase (Day 1–5): Bleeding hoti hai, body cleanse hoti hai. Aaram aur hydration zaroori hai.\n2. Follicular Phase (Day 6–13): Estrogen hormone barhta hai, anday banna shuru hotay hain. Freshness mehsoos hoti hai.\n3. Ovulation Day (~Day 14): Egg release hota hai. Yeh pregnancy ke high chances ka din hai.\n4. Luteal Phase (Day 15–28): Progesterone barhta hai. Agar conceive na ho to PMS symptoms (mood swings, mild cramps) aam hain.',
      contentEnglish:
          '1. Menstrual Phase (Days 1–5): Progesterone drops, shedding endometrium. Gentle rest and hydration are recommended.\n2. Follicular Phase (Days 6–13): Rising estradiol recruits dominant follicles and rebuilds the uterine lining.\n3. Ovulatory Phase (~Day 14): LH surge triggers release of mature oocyte. Peak conception window.\n4. Luteal Phase (Days 15–28): Corpus luteum secretes progesterone. If fertilization does not occur, PMS cramps and mood shifts can occur.',
      source: 'ACOG Clinical Gynecological Endocrinology',
      reviewDate: 'Updated 2026',
    ),

    // 4. Hamal (Pregnancy)
    LearnArticle(
      id: 'pregnancy_trimesters',
      categoryKey: 'pregnancy',
      titleUrdu: 'Hamal Ke 3 Trimesters Ki Tafseel',
      titleEnglish: 'Understanding The 3 Pregnancy Trimesters',
      summaryUrdu: 'Hafte 1 se 40 tak baby aur maa ke jism mein hone wali tabdeeliyan.',
      summaryEnglish: 'Maternal physiology and fetal developmental milestones from week 1 to 40.',
      contentUrdu:
          '• Trimester 1 (Week 1–12): Baby ke ahem organs bante hain. Nausea, thakawat aur breast tenderness aam hai. Folic acid zaroori hai.\n• Trimester 2 (Week 13–27): "Golden Period" — energy wapis aati hai. 18–20 hafton par baby ki movement (kicks) shuru hoti hai aur anomaly scan hota hai.\n• Trimester 3 (Week 28–40): Baby rapidly weight gain karta hai. 10 kicks in 2 hours track karein aur delivery bag tayyar rakhein.',
      contentEnglish:
          '• First Trimester (Weeks 1–12): Organogenesis phase. Morning sickness, fatigue, and breast tenderness are prevalent. Continue prenatal vitamins.\n• Second Trimester (Weeks 13–27): "Golden trimester". Energy rebounds, quickening (fetal kicks) starts around weeks 18–20, and comprehensive anomaly ultrasound is performed.\n• Third Trimester (Weeks 28–40): Exponential fetal growth. Monitor 10 kicks in 2 hours and prepare hospital bag.',
      source: 'RCOG & NHS Maternity Care Standards',
      reviewDate: 'Updated 2026',
    ),

    // 5. Safety & Emergency
    LearnArticle(
      id: 'emergency_red_flags_article',
      categoryKey: 'safety',
      titleUrdu: '🚨 Emergency Red Flags: Kab Foran Doctor Ke Paas Jana Hai?',
      titleEnglish: '🚨 Emergency Red Flags: When To Seek Immediate Medical Care',
      summaryUrdu: 'Aisi alamat jinhein kabhi nazar-andaz nahi karna chahiye.',
      summaryEnglish: 'Critical maternal warning signs requiring immediate emergency evaluation.',
      contentUrdu:
          'Agar niche di gayi alamat mein se koi bhi ho to bina der kiye hospital jayein:\n\n1. 1 ghante mein sanitary pad khoon se bhar jana (Heavy Bleeding).\n2. Pait ke kisi aik taraf shadeed tez chubhny wala dard (Ectopic pregnancy risk).\n3. Aankhon ke aage dhundla-pan aur sar mein shadeed dard (High BP / Preeclampsia).\n4. 28 hafton ke baad baby ki movement / kicks bilkul na mehsoos hona.\n5. Tez bukhar (100.4°F+) aur kapkapi.\n\nGhar par gharelu totkay na aazmayein, foran doctor se checkup karwayein.',
      contentEnglish:
          'Seek emergency obstetric attention immediately if encountering any of the following:\n\n1. Heavy vaginal bleeding soaking a pad in under an hour.\n2. Severe unilateral lower abdominal pain (ectopic risk).\n3. Visual disturbances (flashing lights, blurriness) with severe headache (preeclampsia warning).\n4. Noticeable decrease or cessation of fetal movement past 28 weeks.\n5. High fever (>100.4°F / 38°C) with persistent chills.\n\nDo not rely on home remedies for acute symptoms.',
      source: 'ACOG Urgent Obstetric Assessment Standards',
      reviewDate: 'Updated 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isRomanUrdu = ref.watch(languageProvider) == AppLanguage.romanUrdu;
    final s = ref.watch(appStringsProvider);

    final categories = [
      {'key': 'all', 'label': s.categoryAll},
      {'key': 'myths', 'label': s.categoryMyths},
      {'key': 'fertility', 'label': s.categoryFertility},
      {'key': 'cycle', 'label': s.categoryCycle},
      {'key': 'pregnancy', 'label': s.categoryPregnancy},
      {'key': 'safety', 'label': s.categorySafety},
    ];

    final filtered = _selectedCategoryKey == 'all'
        ? _articles
        : _articles.where((a) => a.categoryKey == _selectedCategoryKey).toList();

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      appBar: AppBar(
        title: Text(
          s.learnTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, color: ClayColors.textPrimary, fontSize: 17),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: ClayLanguageToggle(isCompact: true),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Pills with 3D Depth
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: categories.map((cat) {
                  final key = cat['key']!;
                  final label = cat['label']!;
                  final isSelected = _selectedCategoryKey == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClayPill(
                      label: label,
                      isSelected: isSelected,
                      activeColor: key == 'myths'
                          ? const Color(0xFFD97706)
                          : (key == 'safety'
                              ? const Color(0xFFE53935)
                              : ClayColors.primary),
                      onTap: () => setState(() => _selectedCategoryKey = key),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Articles List with 3D Tactile Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final article = filtered[index];
                  final isMyth = article.categoryKey == 'myths';
                  final isDanger = article.categoryKey == 'safety';

                  String categoryName;
                  switch (article.categoryKey) {
                    case 'myths':
                      categoryName = s.categoryMyths;
                      break;
                    case 'fertility':
                      categoryName = s.categoryFertility;
                      break;
                    case 'cycle':
                      categoryName = s.categoryCycle;
                      break;
                    case 'pregnancy':
                      categoryName = s.categoryPregnancy;
                      break;
                    case 'safety':
                      categoryName = s.categorySafety;
                      break;
                    default:
                      categoryName = s.categoryAll;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ClayCard(
                      borderRadius: 24,
                      backgroundColor: isMyth
                          ? const Color(0xFFFFFBEB)
                          : (isDanger ? const Color(0xFFFFF5F5) : Colors.white),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isMyth
                                      ? const Color(0xFFF59E0B)
                                      : (isDanger
                                          ? const Color(0xFFE53935)
                                          : ClayColors.primary),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isMyth
                                              ? const Color(0xFFF59E0B)
                                              : (isDanger
                                                  ? const Color(0xFFE53935)
                                                  : ClayColors.primary))
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  categoryName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              Text(
                                article.reviewDate,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: ClayColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article.title(isRomanUrdu),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDanger ? const Color(0xFFB71C1C) : ClayColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.summary(isRomanUrdu),
                            style: const TextStyle(
                              fontSize: 12,
                              color: ClayColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF0EBF5)),
                          const SizedBox(height: 12),
                          Text(
                            article.content(isRomanUrdu),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Source: ${article.source}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
