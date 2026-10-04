import 'package:flutter/material.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_pill.dart';

class LearnArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String source;
  final String reviewDate;

  const LearnArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.source,
    required this.reviewDate,
  });
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _selectedCategory = 'Sab (All)';

  static const List<String> _categories = [
    'Sab (All)',
    'Desi Myths vs Facts',
    'Fertility & Milap',
    'Cycle & Hormones',
    'Hamal (Pregnancy)',
    'Safety & Emergency',
  ];

  static const List<LearnArticle> _articles = [
    // 1. Desi Myths vs Facts (Top Priority)
    LearnArticle(
      id: 'myth_legs_up',
      title: 'Myth: Intercourse Ke Baad Taangein Upar Rakhna Zaroori Hai?',
      category: 'Desi Myths vs Facts',
      summary: 'Khandani mashwaray ke mutabiq ghanto taangein upar rakhna zaroori samjha jata hai. Haqeeqat kya hai?',
      content:
          'Haqeeqat (ASRM Medical Facts):\n• Medical science aur ASRM guidelines ke mutabiq kisi aisi position ya taangein ghanto deewar ke sath lagane ka conception chance par koi asar sabit nahi hua.\n• Ejaculation ke chand seconds mein million sperm cervix ke raste uterus mein daakhil ho chuke hotay hain.\n• Intercourse ke baad sirf 5 se 10 minute aaram se seedha laitna kaafi hota hai. Extra fluid ka bahar nikalna bilkul normal hai, sperm andar ja chuka hota hai.',
      source: 'American Society for Reproductive Medicine (ASRM) Practice Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'myth_hot_foods',
      title: 'Myth: Garam Cheezein (Anday, Machli) Khane Se Hamal Rukta Hai?',
      category: 'Desi Myths vs Facts',
      summary: 'Kya baby planning ya early pregnancy mein garam taseer wali ghizayein khatarnak hain?',
      content:
          'Haqeeqat (Clinical Nutritional Facts):\n• Medical science mein "garam" ya "thandi" taseer ka koi scientific tasawwur nahi hai.\n• Anday aur machli (fish) high-quality protein, choline aur Omega-3 fatty acids provide karte hain jo egg quality aur baby ke brain development ke liye behtareen hain.\n• Sirf kachi (uncooked) machli ya raw eggs se perhez karein taake infection na ho. Paka kar khana bilkul mehfooz aur mufeed hai.',
      source: 'NHS UK & ACOG Maternal Nutrition Guidelines',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'myth_period_conception',
      title: 'Myth: Period Khatam Hote Hi Conceive Nahi Ho Sakta?',
      category: 'Desi Myths vs Facts',
      summary: 'Kya period ke foran agle din milap se pregnancy ho sakti hai?',
      content:
          'Haqeeqat (Ovulation & Sperm Lifespan):\n• Agar kisi aurat ka cycle short ho (e.g. 21–24 din), to ovulation period khatam hone ke foran baad Day 8 ya 9 par ho sakti hai.\n• Sperm female body ke andar 3 se 5 din tak zinda reh sakta hai.\n• Is liye agar period ke aakhri din ya foran baad unprotected intercourse ho, to conception ke genuine chances hotay hain.',
      source: 'Human Reproduction & Fertility Science Standards',
      reviewDate: 'Updated 2026',
    ),

    // 2. Fertility & Milap
    LearnArticle(
      id: 'asrm_fertility',
      title: 'Fertile Window Aur Milap Ka Sahi Waqt (ASRM Guidelines)',
      category: 'Fertility & Milap',
      summary: 'Cycle ke 6 sab se ahem din aur intercourse ka sahi schedule samajhein.',
      content:
          'ASRM (American Society for Reproductive Medicine) ke mutabiq:\n\n• Fertile Window: Ovulation ke din se pehle ke 5 din aur ovulation ka din mil kar 6 din bante hain.\n• Intercourse Schedule: Fertile window ke dauran har 1–2 din intercourse karna conception ke chances ko maximum karta hai.\n• Stress Se Bachein: Rozana strict timing ka zehni dabao na lein, pur-sukoon mahol aur mutual comfort sab se ahem hai.',
      source: 'ASRM Practice Committee Guidance',
      reviewDate: 'Updated 2026',
    ),
    LearnArticle(
      id: 'folic_acid_guide',
      title: 'Folic Acid (400 mcg) Kyun Zaroori Hai?',
      category: 'Fertility & Milap',
      summary: 'Baby planning ke dauran rozana 400 mcg Folic Acid lene ki wajohaat.',
      content:
          'Har aurat jo pregnancy plan kar rahi ho, usay conceiving se kam az kam 1 maah pehle rozana 400 mcg Folic Acid shuru karni chahiye.\n\nFaide:\n• Baby ke dimaagh (brain) aur reedh ki haddi (spine) ke congenital defects (Spina Bifida) se 70% tak hifazat.\n• Early cellular division mein madadgar.\n• Pehle 12 hafton tak rozana continue rakhna lazmi hai.',
      source: 'WHO, CDC & NHS Preconception Protocol',
      reviewDate: 'Updated 2026',
    ),

    // 3. Cycle & Hormones
    LearnArticle(
      id: 'cycle_phases_roman',
      title: 'Mahwari (Cycle) Ke 4 Ahem Marahil',
      category: 'Cycle & Hormones',
      summary: 'Menstrual, Follicular, Ovulation aur Luteal phases mein jism mein kya hota hai?',
      content:
          '1. Menstrual Phase (Day 1–5): Bleeding hoti hai, body cleanse hoti hai. Aaram aur hydration zaroori hai.\n2. Follicular Phase (Day 6–13): Estrogen hormone barhta hai, anday banna shuru hotay hain. Freshness mehsoos hoti hai.\n3. Ovulation Day (~Day 14): Egg release hota hai. Yeh pregnancy ke high chances ka din hai.\n4. Luteal Phase (Day 15–28): Progesterone barhta hai. Agar conceive na ho to PMS symptoms (mood swings, mild cramps) aam hain.',
      source: 'ACOG Clinical Gynecological Endocrinology',
      reviewDate: 'Updated 2026',
    ),

    // 4. Hamal (Pregnancy)
    LearnArticle(
      id: 'pregnancy_trimesters',
      title: 'Hamal Ke 3 Trimesters Ki Tafseel',
      category: 'Hamal (Pregnancy)',
      summary: 'Hafte 1 se 40 tak baby aur maa ke jism mein hone wali tabdeeliyan.',
      content:
          '• Trimester 1 (Week 1–12): Baby ke ahem organs bante hain. Nausea, thakawat aur breast tenderness aam hai. Folic acid zaroori hai.\n• Trimester 2 (Week 13–27): "Golden Period" — energy wapis aati hai. 18–20 hafton par baby ki movement (kicks) shuru hoti hai aur anomaly scan hota hai.\n• Trimester 3 (Week 28–40): Baby rapidly weight gain karta hai. 10 kicks in 2 hours track karein aur delivery bag tayyar rakhein.',
      source: 'RCOG & NHS Maternity Care Standards',
      reviewDate: 'Updated 2026',
    ),

    // 5. Safety & Emergency
    LearnArticle(
      id: 'emergency_red_flags_article',
      title: '🚨 Emergency Red Flags: Kab Foran Doctor Ke Paas Jana Hai?',
      category: 'Safety & Emergency',
      summary: 'Aisi alamat jinhein kabhi nazar-andaz nahi karna chahiye.',
      content:
          'Agar niche di gayi alamat mein se koi bhi ho to bina der kiye hospital jayein:\n\n1. 1 ghante mein sanitary pad khoon se bhar jana (Heavy Bleeding).\n2. Pait ke kisi aik taraf shadeed tez chubhny wala dard (Ectopic pregnancy risk).\n3. Aankhon ke aage dhundla-pan aur sar mein shadeed dard (High BP / Preeclampsia).\n4. 28 hafton ke baad baby ki movement / kicks bilkul na mehsoos hona.\n5. Tez bukhar (100.4°F+) aur kapkapi.\n\nGhar par gharelu totkay na aazmayein, foran doctor se checkup karwayein.',
      source: 'ACOG Urgent Obstetric Assessment Standards',
      reviewDate: 'Updated 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Sab (All)'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Health Guide & Maloomat 🌸',
          style: TextStyle(fontWeight: FontWeight.w900, color: ClayColors.textPrimary, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClayPill(
                      label: cat,
                      isSelected: isSelected,
                      activeColor: cat == 'Desi Myths vs Facts'
                          ? const Color(0xFFD97706)
                          : (cat == 'Safety & Emergency'
                              ? const Color(0xFFE53935)
                              : ClayColors.primary),
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Articles List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final article = filtered[index];
                  final isMyth = article.category == 'Desi Myths vs Facts';
                  final isDanger = article.category == 'Safety & Emergency';

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
                                ),
                                child: Text(
                                  article.category.toUpperCase(),
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
                            article.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDanger ? const Color(0xFFB71C1C) : ClayColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.summary,
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
                            article.content,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF10B981)),
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
