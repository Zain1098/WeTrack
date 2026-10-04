import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/cycle_calculation_service.dart';
import '../../data/services/pregnancy_calculation_service.dart';

class HusbandCareCardModal extends StatelessWidget {
  final UserProfile profile;
  final CycleCalculationResult? cycleCalc;
  final PregnancyCalculationResult? pregCalc;

  const HusbandCareCardModal({
    super.key,
    required this.profile,
    this.cycleCalc,
    this.pregCalc,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile profile,
    CycleCalculationResult? cycleCalc,
    PregnancyCalculationResult? pregCalc,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HusbandCareCardModal(
        profile: profile,
        cycleCalc: cycleCalc,
        pregCalc: pregCalc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPregnancy = profile.goal == AppGoal.alreadyPregnant;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2D9EC),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE7F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🧔', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Husband Practical Care Guide',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                        Text(
                          'Shohar Ke Liye Practical Khayal Rakhne Ke Tips',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF7A6A8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF7A6A8D)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Privacy Note
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, size: 16, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Privacy Shield: Biwi ki permission ke baghair unke private symptoms ya intimacy details share nahi hotay. Yeh sirf practical care tips hain.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF0EBF5)),

          // Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPregnancy) ...[
                    // TTC & Cycle Tips
                    const Text(
                      '🌸 Cycle & Baby Planning Ke Dauran Shohar Ka Kirdar:',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E1A47),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTipCard(
                      icon: '💊',
                      title: 'Daily Folic Acid Reminder',
                      desc: 'Biwi ko rozana 400 mcg Folic Acid lene ki pyar se yaad dilayein. Yeh baby ke brain aur spine ke liye intehai zaroori hai.',
                      actionTitle: 'Checklist',
                      actionText: 'Paani ka glass aur supplement table par rakh dein.',
                    ),
                    const SizedBox(height: 10),

                    _buildTipCard(
                      icon: '☕',
                      title: 'PMS / Period Ke Dauran Aaram',
                      desc: 'Period se pehle ya period ke dinon mein chidchida-pan hormonal hota hai. Baatein dil par na lein aur unhe aaram dein.',
                      actionTitle: 'Practical Help',
                      actionText: 'Heating pad ya garam soup/chai offer karein.',
                    ),
                    const SizedBox(height: 10),

                    _buildTipCard(
                      icon: '🌿',
                      title: 'Stress-Free Khushgawar Mahol',
                      desc: 'Zehni dabao aur khandan ka pressure pregnancy ke chances kam kar deta hai. Biwi ko safe aur pyara mahol dein.',
                      actionTitle: 'Mutual Comfort',
                      actionText: 'Kisi strict schedule ke bajaye comfortable intimacy rakhein.',
                    ),
                  ] else ...[
                    // Pregnancy Tips
                    const Text(
                      '🤰 Hamal (Pregnancy) Ke Dauran Shohar Ka Kirdar:',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E1A47),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTipCard(
                      icon: '🏥',
                      title: 'Doctor Appointment & Ultrasound Support',
                      desc: 'Ultrasound aur checkup par hamesha biwi ke sath jayein taake unhe akelapan mehsoos na ho.',
                      actionTitle: 'Planning',
                      actionText: 'Clinic timing aur gaari ka intezam pehle se kar lein.',
                    ),
                    const SizedBox(height: 10),

                    _buildTipCard(
                      icon: '🛋️',
                      title: 'Wazan Na Uthane Dein',
                      desc: 'Heavy bartan ya wazan wali cheezein uthana pregnancy mein dangerous ho sakta hai. Ghar ke kaamo mein hath batayein.',
                      actionTitle: 'Physical Care',
                      actionText: 'Bhari cheezein khud shift karein.',
                    ),
                    const SizedBox(height: 10),

                    _buildTipCard(
                      icon: '👣',
                      title: 'Baby Kicks Record Karna',
                      desc: '3rd Trimester mein baby ki kicks check karne mein biwi ki madad karein (10 kicks in 2 hours).',
                      actionTitle: 'Bonding',
                      actionText: 'Baby ke sath baatein karein, wo awaz pehchanta hai.',
                    ),
                  ],
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text(
                          'Samajh Aa Gaya • Shukriya ❤️',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required String icon,
    required String title,
    required String desc,
    required String actionTitle,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE7F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E1A47),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF4A3B60),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  '👉 $actionTitle: ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF512DA8),
                  ),
                ),
                Expanded(
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF311B92),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
