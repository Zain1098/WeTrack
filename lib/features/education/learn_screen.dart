import 'package:flutter/material.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_pill.dart';
import '../../core/constants/medical_constants.dart';

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
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Fertility',
    'Cycle Health',
    'Pregnancy',
    'Safety',
  ];

  static const List<LearnArticle> _articles = [
    LearnArticle(
      id: 'asrm_fertility',
      title: 'Optimizing Natural Fertility',
      category: 'Fertility',
      summary:
          'Understanding the 6-day fertile window and evidence-based timing for intercourse.',
      content:
          'According to the American Society for Reproductive Medicine (ASRM), the fertile window is the 6-day interval ending on the day of ovulation.\n\nKey Findings:\n• Intercourse every 1–2 days during this window yields the highest fecundability rates.\n• Rigid schedules cause psychological distress; regular intimacy throughout the week is equally effective.\n• No sexual position or post-coital routine has been clinically proven to alter conception probability.',
      source:
          'American Society for Reproductive Medicine (ASRM), Practice Committee (2022)',
      reviewDate: 'Reviewed March 2026',
    ),
    LearnArticle(
      id: 'folic_acid',
      title: 'Folic Acid Supplementation Guidance',
      category: 'Fertility',
      summary:
          'Why 400 mcg daily folic acid is essential before and during early pregnancy.',
      content:
          'Medical consensus strongly recommends daily supplementation with 400 micrograms (mcg) of folic acid for all women who are planning or capable of pregnancy.\n\nClinical Purpose:\n• Significant reduction in neural tube defect (NTD) incidence (such as spina bifida and anencephaly).\n• Should ideally begin at least 1 month prior to conception and continue throughout the first trimester.\n• Discuss individual dosage needs with your healthcare clinician if you have higher risk factors.',
      source: 'ASRM & CDC Clinical Practice Guidelines',
      reviewDate: 'Reviewed February 2026',
    ),
    LearnArticle(
      id: 'infertility_timeline',
      title: 'When to Seek a Medical Fertility Evaluation',
      category: 'Fertility',
      summary:
          'Evidence-based clinical thresholds for seeking formal fertility assessment based on age.',
      content:
          'Infertility is defined clinically by ASRM as the inability to achieve pregnancy after regular unprotected intercourse over a defined time frame:\n\n• Female partner under 35 years: Evaluation is recommended after 12 months of trying.\n• Female partner 35 years or older: Evaluation is recommended after 6 months of trying.\n• Immediate evaluation: Indicated if there is a known history of irregular/absent cycles, endometriosis, or known male factor subfertility.',
      source: 'ASRM Definition of Infertility Practice Committee (2023)',
      reviewDate: 'Reviewed January 2026',
    ),
    LearnArticle(
      id: 'cycle_phases',
      title: 'The Four Phases of the Menstrual Cycle',
      category: 'Cycle Health',
      summary:
          'How hormonal shifts across Menstrual, Follicular, Ovulation, and Luteal phases impact the body.',
      content:
          'The menstrual cycle is governed by intricate hormonal feedback loops:\n\n1. Menstrual Phase (Days 1–5): Low estrogen and progesterone trigger shedding of the uterine lining.\n2. Follicular Phase (Days 6–13): FSH stimulates follicle growth while estrogen rises, rebuilding the endometrium.\n3. Ovulation (Day ~14): A surge in Luteinizing Hormone (LH) triggers the release of a mature egg.\n4. Luteal Phase (Days 15–28): The corpus luteum secretes progesterone, preparing the uterus for potential implantation.',
      source: 'ACOG & Clinical Gynecological Endocrinology',
      reviewDate: 'Reviewed January 2026',
    ),
    LearnArticle(
      id: 'pregnancy_red_flags',
      title: 'Recognizing Urgent Pregnancy Red-Flag Symptoms',
      category: 'Safety',
      summary:
          'Critical signs that require immediate in-person clinical assessment rather than home reassurance.',
      content:
          'While many bodily aches and nausea are common in pregnancy, certain symptoms demand urgent medical evaluation:\n\n• Heavy vaginal bleeding (soaking through a sanitary pad within an hour).\n• Sharp, severe unilateral pelvic pain.\n• Sudden severe swelling in the face or hands, paired with blurred vision or spots.\n• High fever with chills.\n• Fluid leakage before 37 weeks.\n• Noticeable reduction in fetal movements after 28 weeks.\n\nNever ignore these signs. Contact your maternity care provider or emergency room immediately.',
      source: 'ACOG Urgent Obstetric Assessment Standards',
      reviewDate: 'Reviewed April 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Health & Education',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: ClayColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Peer-reviewed clinical guides grounded in ASRM standards.',
                style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Categories Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClayPill(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Articles List
              ...filtered.map((article) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ClayCard(
                      onTap: () => _showArticleDetail(context, article),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ClayColors.surfaceTint,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  article.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: ClayColors.primary,
                                  ),
                                ),
                              ),
                              Text(
                                article.reviewDate,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ClayColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.summary,
                            style: const TextStyle(
                              fontSize: 13,
                              color: ClayColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 13,
                                color: ClayColors.mint,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  article.source,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ClayColors.textTertiary,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: ClayColors.textTertiary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, LearnArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ClayColors.surfaceTint,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ClayColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${article.source} • ${article.reviewDate}',
                style: const TextStyle(
                  fontSize: 11,
                  color: ClayColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(height: 28, color: ClayColors.outline),
              Text(
                article.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ClayColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  MedicalConstants.standardDisclaimer,
                  style: TextStyle(
                    fontSize: 11,
                    color: ClayColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
