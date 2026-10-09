import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_pill.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';
import '../../data/models/user_profile.dart';
import '../../core/widgets/living_3d_character.dart';
import '../app_providers.dart';

class LearnArticle {
  final String id;
  final String titleUrdu;
  final String titleEnglish;
  final String categoryKey; // 'all', 'conception', 'myths', 'fertility', 'cycle', 'pregnancy', 'safety'
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPregnancy = ref.read(userProfileProvider).goal == AppGoal.alreadyPregnant;
      if (isPregnancy && mounted) {
        setState(() {
          _selectedCategoryKey = 'pregnancy';
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<LearnArticle> _articles = [
    // 1. Mubashrat & Conception (Intercourse timing & positions)
    LearnArticle(
      id: 'sex_timing_frequency',
      categoryKey: 'conception',
      titleUrdu: 'Mubashrat Ka Sahi Waqt Aur Frequency (ASRM Guideline)',
      titleEnglish: 'Optimal Intercourse Timing & Frequency (ASRM)',
      summaryUrdu: 'Hamal theherne ke liye fertile window me kitni martaba sex karna chahiye?',
      summaryEnglish: 'How often and exactly when to have intercourse to maximize conception odds.',
      contentUrdu:
          'Medical Evidence (ASRM Guidelines):\n\n• Fertile Window: Baiza kharij hone (ovulation) se pehle ke 5 din aur ovulation ka din conception ke liye ahem hotay hain.\n• Sahi Waqt: Ovulation se 2 din pehle aur ovulation ke din sex karna conception ke imkanaat ko 85% tak barha deta hai.\n• Kitni Bar (Frequency): Har 1 ya 2 din baad intercourse karna behtareen hai. Yeh khayal ghalat hai ke rozana sex karne se sperm kamzor ho jata hai; research se sabit hai ke healthy mard ka sperm rozana intercourse se fresh aur mutaharrik (motile) rehta hai.\n• Tanasub: Agar shohar ka sperm count normal hai to fertile dino me rozana ya har doosray din sex karna sab se mufeed hai.',
      contentEnglish:
          'ASRM Clinical Practice Guidelines:\n\n• Conception Window: The 5 days leading up to ovulation plus ovulation day.\n• Highest Probability: 1-2 days before ovulation has the highest pregnancy rate.\n• Frequency: Intercourse every 1-2 days yields the best fecundability. Daily intercourse does not deplete sperm count in healthy men and maintains peak motility.',
      source: 'American Society for Reproductive Medicine (ASRM)',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'sex_positions_elevation',
      categoryKey: 'conception',
      titleUrdu: 'Hamal Theherne Ke Liye Positions Aur Pelvic Elevation',
      titleEnglish: 'Conception Positions & Pelvic Elevation (Facts)',
      summaryUrdu: 'Kya koi makhsoos position ya kamar ke neechay takiya rakhna zaroori hai?',
      summaryEnglish: 'Clinical evidence behind coital positions and resting posture after sex.',
      contentUrdu:
          'Clinical Facts & Advice:\n\n• Positions: Missionary (aurat neechay) ya Rear-entry positions sperm ko reham ke munh (cervix) ke sab se qareeb deposit karti hain.\n• Pelvic Elevation: Intercourse ke baad kamar/koolhay (pelvis) ke neechay aik narm takiya rakh kar 10 se 15 minute seedha laitna gravity ki madad se semen pool ko cervix par tikaaye rakhta hai.\n• Deewar Par Taangein: Ghanto taangein deewar se lagana zaroori nahi hai. Taqatwar aur tez sperm ejaculation ke chand seconds me hi cervix ke andar swim kar chukay hotay hain.\n• Normal Discharge: 15 minute baad thora fluid bahar nikalna bilkul normal hai, sperm andar ja chuka hota hai.',
      contentEnglish:
          'Clinical Consensus:\n\n• Positions that deposit semen close to the external os (e.g., missionary or rear-entry) are biologically favorable.\n• Placing a small pillow beneath the hips for 10-15 minutes helps pooling of semen at the vaginal fornix.\n• Holding legs against the wall for hours is unnecessary; motile sperm penetrate cervical mucus within seconds.',
      source: 'ACOG & Fertility Research Consensus',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'cervical_mucus_guide',
      categoryKey: 'fertility',
      titleUrdu: 'Egg-White Cervical Mucus: Kachi Safedi Jaisa Discharge',
      titleEnglish: 'Egg-White Cervical Fluid: Prime Ovulation Indicator',
      summaryUrdu: 'Reham ki rutubat se baiza kharij hone ki pehchan kaise karein?',
      summaryEnglish: 'Identifying peak fertility through clear, stretchy cervical mucus.',
      contentUrdu:
          'Cervical Fluid Ki Pehchan:\n\n• Kachi Safedi (Raw Egg White): Jab ovulation bilkul qareeb hoti hai, estrogen barh jata hai aur vaginal discharge bilkul saaf, slippery aur kache anday ki safedi jaisa khinchne wala (stretchy) ho jata hai.\n• Sperm Ka Dost: Yeh fluid sperm ko 3 se 5 din tak zinda rakhne aur swim karne ke liye zaroori khuraak aur alkaline mahol deta hai.\n• Amal: Jis din yeh stretchy fluid nazar aaye, wo mubashrat ke liye behtareen din hai.',
      contentEnglish:
          'Biological Marker:\n\n• Peak Fertile Mucus: Estrogen surge makes cervical secretions clear, slippery, and stretchy like raw egg whites.\n• Sperm Nourishment: Alkaline pH protects sperm and facilitates rapid transit through the cervix.\n• Timing: The presence of this fluid marks the ideal time for intercourse.',
      source: 'WHO Fertility Awareness-Based Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'male_fertility_sperm',
      categoryKey: 'conception',
      titleUrdu: 'Shohar Ki Sehat & Sperm Quality (Heat, Diet & Lifestyle)',
      titleEnglish: 'Husband Fertility & Sperm Health: Heat & Lifestyle',
      summaryUrdu: 'Sperm count aur motility barhane ke liye shohar ko kin cheezon ka khayal rakhna chahiye?',
      summaryEnglish: 'Crucial steps for male fertility including temperature, diet, and lifestyle.',
      contentUrdu:
          'Shohar Ke Liye Medical Hidayat:\n\n• Garmi Se Bachao (Testicular Heat): Sperm ko thanda mahol chahiye hota hai. Garm pani ke tub me baithna, tight underwear pehanna, ya lap par garam laptop rakhna sperm count kam karta hai.\n• Khuraak (Nutrients): Zinc (nuts/beans), Vitamin C, Vitamin E, aur CoQ10 sperm DNA aur moving power ko taqatwar banatay hain.\n• Shisha / Cigarette: Smoking sperm ke DNA ko nuqsaan pohnchati hai aur conception me rukawat dalti hai.\n• Hydration: Khoob pani peena semen volume aur fluid consistency ke liye zaroori hai.',
      contentEnglish:
          'Male Fecundity Guidelines:\n\n• Temperature Control: Testes require 2-3°C cooler than core body temp. Avoid hot tubs, tight synthetic briefs, and resting laptops on lap.\n• Antioxidants: Zinc, Vitamin C, Vitamin E, and Selenium protect sperm membrane integrity.\n• Lifestyle: Avoid tobacco, vaping, and excess alcohol which fragment sperm DNA.',
      source: 'American Urological Association (AUA) Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'emergency_contraceptive_ecp',
      categoryKey: 'safety',
      titleUrdu: 'Unprotected Sex: Emergency Contraceptive Pill (ECP) Ka Sahi Istemal',
      titleEnglish: 'Unprotected Sex: Emergency Contraceptive Pill (ECP) Guide',
      summaryUrdu: 'Agar ghalti se baghair protection sex ho jaye to hamal rokne ke liye kya karein?',
      summaryEnglish: 'Guidance on post-coital emergency contraception within 72 hours.',
      contentUrdu:
          'Emergency Hidayat (Within 72 Hours):\n\n• Kab Lein: Agar fertile dino me baghair protection mubashrat ho jaye aur sperm andar chala jaye aur aap hamal nahi chahteen, to foran 72 ghanton (3 din) ke andar Levonorgestrel (jaise Postinor-2, Famila-72, ya Emkit) lein.\n• Pehle 24 Ghantay: Jitni jaldi li jaye utni zyada mufeed hoti hai (pehle 24 ghanton me 95% kamyabi).\n• Yeh Abortion Nahi Hai: ECP pehle se thehray huay hamal ko nuqsaan nahi pohnchati, yeh sirf baiza kharij hone ko rokti hai.\n• Doctor Se Mashwara: Agar 3 haftay tak mahwari na aaye to pregnancy test karein.',
      contentEnglish:
          'Emergency Contraception Protocol:\n\n• Window of Action: Levonorgestrel pills (e.g. Postinor-2) must be taken within 72 hours of unprotected intercourse.\n• Efficacy: 95% effective if taken within first 24 hours.\n• Mechanism: Prevents or delays ovulation; it does NOT disrupt established implantation.',
      source: 'WHO Family Planning & Emergency Contraceptive Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'sex_during_pregnancy',
      categoryKey: 'pregnancy',
      titleUrdu: 'Hamal Ke Dauran Mubashrat (Sex During Pregnancy)',
      titleEnglish: 'Sex During Pregnancy: Safety & Clinical Precautions',
      summaryUrdu: 'Hamal me mubashrat kab mehfooz hoti hai aur kin halaat me parhez zaroori hai?',
      summaryEnglish: 'When intercourse is completely safe during gestation and obstetric contraindications.',
      contentUrdu:
          'Medical Guidance:\n\n• Normal Hamal: Healthy pregnancy me mubashrat 100% mehfooz hoti hai. Baby amniotic thaili aur reham ki mazboot deewaron me mehfooz hota hai, sperm baby tak nahi pohnch sakta.\n• Parhez Kab Lazmi Hai:\n  1. Agar vaginal bleeding ya spotting ho rahi ho.\n  2. Placenta Previa (placenta bachedani ke munh par ho).\n  3. Premature delivery ya pehle recurrent miscarriage ka khatra ho.\n  4. Reham ka munh kamzor ho (Incompetent cervix).\n  5. Doctor ne explicitly bed rest ya pelvic rest ka hukum diya ho.\n• Positions: Pait par dabao daalne wali positions se parhez karein; side-lying (karwat) position behtareen hai.',
      contentEnglish:
          'Obstetric Practice:\n\n• Normal Gestation: Completely safe throughout healthy trimesters; the mucous plug and amniotic sac insulate the fetus.\n• Strict Contraindications: Placenta previa, unexplained antepartum bleeding, cervical insufficiency, or history of preterm labor.\n• Positions: Avoid prone positions placing direct abdominal pressure.',
      source: 'ACOG Obstetric Patient Education',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'mittelschmerz_pain',
      categoryKey: 'fertility',
      titleUrdu: 'Mittelschmerz: Ovulation Ke Waqt Pet Mein Twinge / Pain',
      titleEnglish: 'Mittelschmerz: Ovulation Pain Twinges & Signs',
      summaryUrdu: 'Cycle ke darmiyan me pet ke aik taraf hone wala dard kya hota hai?',
      summaryEnglish: 'Understanding mid-cycle one-sided ovarian twinges and conception timing.',
      contentUrdu:
          'Ovulation Pain Ki Wajah:\n\n• Mittelschmerz: German lafz hai jis ka matlab "darmiyani dard" hai. Mahwari ke 14vein din ke qareeb kisi aik ovary se anday ke phoot kar nikalnay se pait ke nichlay hissay me halki aenthan ya chubhny wala dard hota hai.\n• Alamat: Yeh 1 se 2 ghantay ya chand lamhat ke liye rehta hai.\n• Conception Signal: Yeh is baat ka saboot hai ke ovary ne anda release kiya hai, agle 24 ghanton me conception ka golden chance hota hai.',
      contentEnglish:
          'Clinical Insight:\n\n• Definition: Physiological unilateral lower abdominal twinges coinciding with follicular rupture and oocyte extrusion.\n• Duration: Typically lasts a few hours.\n• Conception Signal: Confirms active ovulation; peak coital opportunity within 24 hours.',
      source: 'Mayo Clinic & British Medical Journal (BMJ)',
      reviewDate: 'Updated 2026',
    ),

    // 2. Desi Myths vs Facts
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
      source: 'American Society for Reproductive Medicine (ASRM)',
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
      summaryUrdu: 'Kya period ke foran agle din intercourse se pregnancy ho sakti hai?',
      summaryEnglish: 'Can unprotected intercourse right after bleeding ceases result in pregnancy?',
      contentUrdu:
          'Haqeeqat (Ovulation & Sperm Lifespan):\n• Agar kisi aurat ka cycle short ho (e.g. 21–24 din), to ovulation period khatam hone ke foran baad Day 8 ya 9 par ho sakti hai.\n• Sperm female body ke andar 3 se 5 din tak zinda reh sakta hai.\n• Is liye agar period ke aakhri din ya foran baad unprotected intercourse ho, to conception ke genuine chances hotay hain.',
      contentEnglish:
          'Clinical Reality (Follicular Timeline & Sperm Viability):\n• In women with shorter menstrual cycles (21-24 days), ovulation can occur as early as Cycle Day 8 or 9.\n• Because healthy sperm can survive up to 5 days inside alkaline cervical crypts, intercourse at the end of menses can indeed yield conception.',
      source: 'Human Reproduction & Fertility Science Standards',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'myth_period_during_pregnancy',
      categoryKey: 'myths',
      titleUrdu: 'Myth: Kya Hamal (Pregnancy) Mein Period Aa Sakta Hai?',
      titleEnglish: 'Myth: Can You Have a Menstrual Period While Pregnant?',
      summaryUrdu: 'Hamal mein period aana kyu namumkin hai? Medical science ki wazahat.',
      summaryEnglish: 'Why true menstruation cannot physiologically occur during pregnancy.',
      contentUrdu:
          'Haqeeqat (ACOG & NHS Medical Biology):\n• Medical Science ke mutabiq HAMAL MEIN PERIOD AANA 100% NAMUMKIN HAI (Amenorrhea of Pregnancy).\n• Wajah (Hormones): Mahwari tab aati hai jab andey ko sperm na mile aur Progesterone hormone gir jaye, jis se bache dani ki deewar toot kar khoon ki soorat mein nikal jati hai.\n• Magar jab aap pregnant hoti hain, to Placenta aur Corpus Luteum "hCG" aur "Progesterone" ko high level par rakhte hain taake lining mazboot rahe.\n• Bleeding vs Period: Hamal ke dauran agar halki spotting ya khoon aaye, to wo PERIOD NAHI hota! Yeh implantation bleeding, cervical changes, ya complication ki alamat ho sakti hai.\n• Warning: Agar hamal mein khoon aaye to foran doctor se ruju karein.',
      contentEnglish:
          'Clinical Reality (ACOG & NHS Guidelines):\n• True menstruation is physiologically impossible during pregnancy due to elevated progesterone and hCG sustaining the uterine endometrium.\n• Any bleeding occurring in pregnancy is not a period; it may indicate implantation, cervical sensitivity, or obstetric complications requiring physician review.',
      source: 'ACOG & NHS Standards',
      reviewDate: 'Updated 2026',
    ),

    // 3. Folic Acid & Nutrition
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
          'Preconception Clinical Evidence (WHO & CDC):\n\n• Taking 400 mcg of synthetic folic acid daily reduces neural tube defects by up to 70%.\n• Critical for embryonic DNA synthesis and rapid cellular division through week 12.',
      source: 'WHO, CDC & NHS Preconception Protocol',
      reviewDate: 'Updated 2026',
    ),

    // 4. Cycle & Phases
    LearnArticle(
      id: 'cycle_phases_roman',
      categoryKey: 'cycle',
      titleUrdu: 'Mahwari (Cycle) Ke 4 Ahem Marahil',
      titleEnglish: 'The 4 Distinct Menstrual Cycle Phases',
      summaryUrdu: 'Menstrual, Follicular, Ovulation aur Luteal phases mein jism mein kya hota hai?',
      summaryEnglish: 'What happens hormonally across Menstrual, Follicular, Ovulatory, and Luteal phases.',
      contentUrdu:
          '1. Menstrual Phase (Day 1–5): Bleeding hoti hai, body cleanse hoti hai. Aaram aur hydration zaroori hai.\n2. Follicular Phase (Day 6–13): Estrogen hormone barhta hai, anday banna shuru hotay hain. Freshness mehsoos hoti hai.\n3. Ovulation Day (~Day 14): Egg release hota hai. Yeh pregnancy ke high chances ka din hai.\n4. Luteal Phase (Day 15–28): Progesterone barhta hai. Agar conceive na ho to PMS symptoms aam hain.',
      contentEnglish:
          '1. Menstrual Phase (Days 1–5): Shedding endometrium with low hormones.\n2. Follicular Phase (Days 6–13): Estrogen surge promotes follicular maturation.\n3. Ovulatory Phase (~Day 14): LH surge releases mature oocyte; peak conception.\n4. Luteal Phase (Days 15–28): Progesterone dominates; PMS symptoms if unfertilized.',
      source: 'ACOG Clinical Gynecological Endocrinology',
      reviewDate: 'Updated 2026',
    ),

    // 5. Hamal Trimesters
    LearnArticle(
      id: 'pregnancy_trimesters',
      categoryKey: 'pregnancy',
      titleUrdu: 'Hamal Ke 3 Trimesters Ki Tafseel',
      titleEnglish: 'Understanding The 3 Pregnancy Trimesters',
      summaryUrdu: 'Hafte 1 se 40 tak baby aur maa ke jism mein hone wali tabdeeliyan.',
      summaryEnglish: 'Maternal physiology and fetal developmental milestones from week 1 to 40.',
      contentUrdu:
          '• Trimester 1 (Week 1–12): Baby ke ahem organs bante hain. Nausea aur thakawat aam hai. Folic acid zaroori hai.\n• Trimester 2 (Week 13–27): Energy wapis aati hai. 18–20 hafton par baby ki kicks shuru hoti hain aur anomaly scan hota hai.\n• Trimester 3 (Week 28–40): Baby weight gain karta hai. 10 kicks in 2 hours track karein aur delivery ki tayyari karein.',
      contentEnglish:
          '• Trimester 1 (Weeks 1–12): Organogenesis, nausea, early development.\n• Trimester 2 (Weeks 13–27): Fetal kicks begin (quickening), comprehensive anomaly scan.\n• Trimester 3 (Weeks 28–40): Rapid fetal growth, monitor 10 kicks in 2 hours.',
      source: 'RCOG & NHS Maternity Care Standards',
      reviewDate: 'Updated 2026',
    ),

    // 6. Emergency Red Flags
    LearnArticle(
      id: 'emergency_red_flags_article',
      categoryKey: 'safety',
      titleUrdu: '🚨 Emergency Red Flags: Kab Foran Doctor Ke Paas Jana Hai?',
      titleEnglish: '🚨 Emergency Red Flags: When To Seek Immediate Medical Care',
      summaryUrdu: 'Aisi alamat jinhein kabhi nazar-andaz nahi karna chahiye.',
      summaryEnglish: 'Critical maternal warning signs requiring immediate emergency evaluation.',
      contentUrdu:
          'Agar niche di gayi alamat mein se koi bhi ho to bina der kiye hospital jayein:\n\n1. 1 ghante mein sanitary pad khoon se bhar jana (Heavy Bleeding).\n2. Pait ke kisi aik taraf shadeed tez chubhny wala dard (Ectopic risk).\n3. Aankhon ke aage dhundla-pan aur sar mein shadeed dard (High BP / Preeclampsia).\n4. 28 hafton ke baad baby ki kicks bilkul na mehsoos hona.\n5. Tez bukhar (100.4°F+) aur kapkapi.\n\nGhar par totkay na karein, foran doctor se checkup karwayein.',
      contentEnglish:
          'Seek emergency obstetric care immediately for:\n1. Heavy bleeding soaking a pad in under an hour.\n2. Severe unilateral lower abdominal pain.\n3. Visual disturbances with severe headache.\n4. Noticeable cessation of fetal kicks past 28 weeks.\n5. High fever (>100.4°F / 38°C).',
      source: 'ACOG Urgent Obstetric Assessment Standards',
      reviewDate: 'Updated 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isRomanUrdu = ref.watch(languageProvider) == AppLanguage.romanUrdu;
    final s = ref.watch(appStringsProvider);

    final categories = [
      {'key': 'all', 'label': isRomanUrdu ? 'Tamam Maloomat' : s.categoryAll},
      {'key': 'conception', 'label': isRomanUrdu ? 'Mubashrat & Hamal' : 'Intimacy & Sex'},
      {'key': 'myths', 'label': isRomanUrdu ? 'Haqeeqat vs Waham' : s.categoryMyths},
      {'key': 'fertility', 'label': isRomanUrdu ? 'Baiza & Fertile Days' : s.categoryFertility},
      {'key': 'cycle', 'label': isRomanUrdu ? 'Mahwari Cycle' : s.categoryCycle},
      {'key': 'pregnancy', 'label': isRomanUrdu ? 'Hamal (Pregnancy)' : s.categoryPregnancy},
      {'key': 'safety', 'label': isRomanUrdu ? 'Emergency & ECP' : s.categorySafety},
    ];

    final query = _searchQuery.trim().toLowerCase();
    final filtered = _articles.where((a) {
      final matchesCategory = _selectedCategoryKey == 'all' || a.categoryKey == _selectedCategoryKey;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return a.titleUrdu.toLowerCase().contains(query) ||
          a.titleEnglish.toLowerCase().contains(query) ||
          a.summaryUrdu.toLowerCase().contains(query) ||
          a.summaryEnglish.toLowerCase().contains(query) ||
          a.contentUrdu.toLowerCase().contains(query) ||
          a.contentEnglish.toLowerCase().contains(query);
    }).toList();

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
            // 3D Motion Health Educator Character
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: 2),
                child: Living3DCharacter(
                  persona: CharacterPersona.learn,
                  size: 95,
                  showSpeechBubble: true,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Live Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: isRomanUrdu
                        ? 'Sawal ya mozuh talash karein (e.g. sex, position, egg, ECP)...'
                        : 'Search medical guide (e.g. intercourse, positions, egg)...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: ClayColors.textTertiary),
                    prefixIcon: const Icon(Icons.search_rounded, color: ClayColors.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: ClayColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

            // Category Filter Pills with 3D Depth
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                              : (key == 'conception'
                                  ? const Color(0xFFC2185B)
                                  : ClayColors.primary)),
                      onTap: () => setState(() => _selectedCategoryKey = key),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),

            // Articles List with 3D Tactile Cards
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              isRomanUrdu
                                  ? 'Is lafz ke mutabiq koi maloomat nahi mili'
                                  : 'No articles matching your search',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: ClayColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isRomanUrdu
                                  ? 'Doosra lafz talash karein ya ooper se category tab tabdeel karein.'
                                  : 'Try different search keywords or switch category filter.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final article = filtered[index];
                        final isMyth = article.categoryKey == 'myths';
                        final isDanger = article.categoryKey == 'safety';
                        final isConception = article.categoryKey == 'conception';

                        String categoryName;
                        switch (article.categoryKey) {
                          case 'conception':
                            categoryName = isRomanUrdu ? 'MUBASHRAT & HAMAL' : 'INTIMACY & CONCEPTION';
                            break;
                          case 'myths':
                            categoryName = isRomanUrdu ? 'HAQEEQAT VS WAHAM' : s.categoryMyths.toUpperCase();
                            break;
                          case 'fertility':
                            categoryName = isRomanUrdu ? 'BAIZA & FERTILE DAYS' : s.categoryFertility.toUpperCase();
                            break;
                          case 'cycle':
                            categoryName = isRomanUrdu ? 'MAHWARI CYCLE' : s.categoryCycle.toUpperCase();
                            break;
                          case 'pregnancy':
                            categoryName = isRomanUrdu ? 'HAMAL (PREGNANCY)' : s.categoryPregnancy.toUpperCase();
                            break;
                          case 'safety':
                            categoryName = isRomanUrdu ? 'EMERGENCY & ECP' : s.categorySafety.toUpperCase();
                            break;
                          default:
                            categoryName = s.categoryAll.toUpperCase();
                        }

                        Color badgeColor = ClayColors.primary;
                        if (isMyth) {
                          badgeColor = const Color(0xFFF59E0B);
                        } else if (isDanger) {
                          badgeColor = const Color(0xFFE53935);
                        } else if (isConception) {
                          badgeColor = const Color(0xFFC2185B);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ClayCard(
                            borderRadius: 24,
                            backgroundColor: isMyth
                                ? const Color(0xFFFFFBEB)
                                : (isDanger
                                    ? const Color(0xFFFFF5F5)
                                    : (isConception ? const Color(0xFFFFF0F5) : Colors.white)),
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
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: badgeColor.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        categoryName,
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
                                    color: isDanger
                                        ? const Color(0xFFB71C1C)
                                        : (isConception ? const Color(0xFF880E4F) : ClayColors.textPrimary),
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
