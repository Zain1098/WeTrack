import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/date_helpers.dart';
import '../../data/models/partner_share_permission.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/cycle_calculation_service.dart';
import '../app_providers.dart';

class PartnerHubModal extends ConsumerStatefulWidget {
  final int initialTab;

  const PartnerHubModal({
    super.key,
    this.initialTab = 0,
  });

  static Future<void> show(
    BuildContext context, {
    int initialTab = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PartnerHubModal(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<PartnerHubModal> createState() => _PartnerHubModalState();
}

class _PartnerHubModalState extends ConsumerState<PartnerHubModal> {
  late int _selectedTab;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    final partner = ref.read(partnerPermissionProvider);
    if (partner.partnerCode.isNotEmpty) {
      _codeController.text = partner.partnerCode;
    }
    if (partner.partnerName.isNotEmpty) {
      _nameController.text = partner.partnerName;
    } else {
      _nameController.text = 'Shohar Jaan';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = ref.watch(partnerPermissionProvider);
    final profile = ref.watch(userProfileProvider);
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final pregCalc = ref.watch(pregnancyCalculationProvider);
    final isPregnancy = profile.goal == AppGoal.alreadyPregnant;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x334A148C),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Clay Drag Handle
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2D9EC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text('🧔', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Shohar / Partner Hub',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E1A47),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(partner.isConnected),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          partner.isConnected
                              ? 'Synced with ${partner.partnerName.isNotEmpty ? partner.partnerName : "Shohar"}'
                              : 'Connect for mutual care & family planning',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF7A6A8D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF7A6A8D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3D Clay Tabs Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F2FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFECE4F3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        tabIndex: 0,
                        title: 'Love & Care Alerts',
                        icon: '❤️',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildTabButton(
                        tabIndex: 1,
                        title: 'Pairing & Privacy',
                        icon: '🔗',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tab Content Body
            Expanded(
              child: _selectedTab == 0
                  ? _buildCareAlertsTab(context, partner, profile, cycleCalc, pregCalc, isPregnancy)
                  : _buildPairingPrivacyTab(context, partner),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected ? const Color(0xFFA5D6A7) : const Color(0xFFCE93D8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Connected' : 'Offline',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isConnected ? const Color(0xFF1B5E20) : const Color(0xFF6A1B9A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int tabIndex,
    required String title,
    required String icon,
  }) {
    final isSelected = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFF7A6A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 0: LOVE & CARE ALERTS FOR HUSBAND
  // -------------------------------------------------------------
  Widget _buildCareAlertsTab(
    BuildContext context,
    PartnerSharePermission partner,
    UserProfile profile,
    CycleCalculationResult cycleCalc,
    dynamic pregCalc,
    bool isPregnancy,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Phase Dynamic Banner
          _buildLivePhaseAdviceCard(profile, cycleCalc, pregCalc, isPregnancy),
          const SizedBox(height: 16),

          // Husband Quick Love Reactions (One-Tap Care Messages)
          Text(
            '💌 Husband Quick Love Reactions:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E1A47),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shohar biwi ko aik tap mein hosla aur pyar ka paigham bhej saktay hain:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: const Color(0xFF7A6A8D),
            ),
          ),
          const SizedBox(height: 10),

          _buildQuickReactionsGrid(context, partner),
          const SizedBox(height: 14),

          // Last Sent Love Note Banner
          if (partner.lastCareMessage != null && partner.lastCareMessage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F5), Color(0xFFF3E5F5)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF8BBD0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0DE91E63),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('💖', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aakhri Pyar Bhara Paigham',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC2185B),
                              ),
                            ),
                            if (partner.lastCareMessageTime != null)
                              Text(
                                DateHelpers.formatFriendly(partner.lastCareMessageTime!),
                                style: const TextStyle(fontSize: 10, color: Color(0xFF880E4F)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '"${partner.lastCareMessage}"',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF880E4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Do's and Don'ts Checklist
          Text(
            '📋 Shohar Ke Liye Ahem Checklist (Do\'s & Don\'ts):',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E1A47),
            ),
          ),
          const SizedBox(height: 10),

          if (isPregnancy) ...[
            _buildChecklistTile('🏥 Doctor ke checkups aur scan dates yaad rakhein aur sath jayein.', true),
            _buildChecklistTile('🛋️ Heavy bartan ya koi bhi wazan wali cheez biwi ko na uthane dein.', true),
            _buildChecklistTile('💧 Rozana 8-10 glass paani aur vitamins ki pyar se yaad dilayein.', true),
            _buildChecklistTile('❌ Kisi behes ya zehni dabao se mukammal parhez karein.', false),
          ] else ...[
            _buildChecklistTile('☕ Period dard ya thakan mein garam soup ya chai khud offer karein.', true),
            _buildChecklistTile('💊 Rozana subah Folic Acid lene ki yaad dilayein (baby planning).', true),
            _buildChecklistTile('🛋️ Ghar ke kaamo mein hath batayein taake unhe rest mil sakay.', true),
            _buildChecklistTile('❌ Mood swings ko personal na lein; yeh natural hormonal tabdeeli hai.', false),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChecklistTile(String text, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFF9FBF9) : const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPositive ? '✅' : '⛔',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePhaseAdviceCard(
    UserProfile profile,
    CycleCalculationResult cycleCalc,
    dynamic pregCalc,
    bool isPregnancy,
  ) {
    if (isPregnancy && pregCalc != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF2F8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFBCFE8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🤰', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hamal: Hafta ${pregCalc.completedWeeks} Active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF9D174D),
                        ),
                      ),
                      Text(
                        'Baby size: ${pregCalc.babyFruitComparison} jaisa hai 👶',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFBE185D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Biwi ke jism mein naye tissues aur blood supply barh rahi hai. Thakan aur kamar dard mamooli baat hai. Unhe foot massage dein aur hydration ka khayal rakhein.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF831843),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Cycle based advice
    final phase = cycleCalc.currentPhase;
    String icon = '🌸';
    String title = 'Cycle Day ${cycleCalc.currentCycleDay}';
    String subtitle = 'Normal Daily Care';
    String body = 'Biwi ke sath pyara aur pursukoon waqt guzarein.';
    Color bgColor = const Color(0xFFF3E5F5);
    Color borderColor = const Color(0xFFE1BEE7);
    Color textColor = const Color(0xFF4A148C);

    if (phase == CyclePhase.menstrual) {
      icon = '🩸';
      title = 'Biwi Period Me Hain (Cramps Alert)';
      subtitle = 'Kamar aur pet mein dard ho sakta hai';
      body = 'Warm water bag dein, thande paani ya cold drinks se rokein. Kitchen ke kaamon se aaram dein aur kisi behes se bachein.';
      bgColor = const Color(0xFFFFF0F3);
      borderColor = const Color(0xFFFFCCD5);
      textColor = const Color(0xFF9F1239);
    } else if (phase == CyclePhase.fertileWindow || phase == CyclePhase.ovulationDay) {
      icon = '🌸';
      title = 'Fertile Window Active (Best for TTC)';
      subtitle = 'Hamal theherne ke ahem din hain';
      body = 'Biwi ka mood khushgawar aur energetic hai. Stress-free mahol rakhein aur affectionate waqt guzarein.';
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
      textColor = const Color(0xFF166534);
    } else if (phase == CyclePhase.luteal) {
      icon = '🌙';
      title = 'PMS Sensitive Phase (Agla Period Qareeb)';
      subtitle = 'Hormonal swings aur mood sensitivity';
      body = 'Biwi ko sabr aur pyari baton ki zaroorat hai. Unki pasand ka khana mangwayein aur unki baaton par gussa na karein.';
      bgColor = const Color(0xFFFAF5FF);
      borderColor = const Color(0xFFE9D5FF);
      textColor = const Color(0xFF581C87);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReactionsGrid(
    BuildContext context,
    PartnerSharePermission partner,
  ) {
    final reactions = [
      {'emoji': '❤️', 'text': 'Khayal rakhna apna'},
      {'emoji': '💊', 'text': 'Dawai ya vitamins le li?'},
      {'emoji': '☕', 'text': 'Garam chai laa doon?'},
      {'emoji': '🫂', 'text': 'Rest karo, tension na lo'},
      {'emoji': '🌸', 'text': 'Proud of you, biwi jaan'},
      {'emoji': '🛒', 'text': 'Kuch mangwana hai to batao'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: reactions.map((r) {
        final label = '${r['emoji']} ${r['text']}';
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(partnerPermissionProvider.notifier).sendLoveReaction(label);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Text('💌 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text('Paigham biwi ko bhej diya gaya: "$label"'),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF6A1B9A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDE7F6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x084A148C),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r['emoji']!, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  r['text']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B1E54),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: PAIRING & PRIVACY CONTROLS
  // -------------------------------------------------------------
  Widget _buildPairingPrivacyTab(
    BuildContext context,
    PartnerSharePermission partner,
  ) {
    final myShareCode = partner.myUniqueCode.isNotEmpty
        ? partner.myUniqueCode
        : 'WT-912-748';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Wife's Own Unique Pairing Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8FE),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEADBFA)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C7B1FA2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aapka Private Pairing Code',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A6A8D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          myShareCode,
                          style: GoogleFonts.firaCode(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6A1B9A),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      label: const Text('Copy Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: myShareCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pairing code $myShareCode copied to clipboard! 📋'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeh code shohar ke sath share karein taake wo aapke sath connect ho sakein.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF7A6A8D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Connection Pod (If Connected vs If Not Connected)
          if (partner.isConnected) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🧔', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner.partnerName.isNotEmpty ? partner.partnerName : 'Shohar Jaan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${partner.partnerCode} • Connected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (partner.connectedAt != null)
                              Text(
                                'Paired on: ${DateHelpers.formatFriendly(partner.connectedAt!)}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF388E3C)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.link_off_rounded, color: Color(0xFFC62828), size: 18),
                      label: Text(
                        'Shohar Ko Unpair / Disconnect Karein',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _confirmDisconnect(context),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7FD),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFEDE7F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shohar Ka Code & Naam Darj Karein:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E1A47),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Shohar Ka Naam / Nickname (e.g. Ahmed)',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF7A6A8D)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2D9EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2D9EC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Shohar Ka Pairing Code (e.g. WT-849-210)',
                      prefixIcon: const Icon(Icons.vpn_key_rounded, color: Color(0xFF7A6A8D)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2D9EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2D9EC)),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Connect Partner Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        final code = _codeController.text.trim();
                        final name = _nameController.text.trim();
                        if (code.length < 4) {
                          setState(() => _errorMessage = 'Barahe karam durust pairing code darj karein.');
                          return;
                        }
                        setState(() => _errorMessage = null);
                        ref.read(partnerPermissionProvider.notifier).connectPartner(
                              partnerCode: code,
                              partnerName: name.isEmpty ? 'Shohar' : name,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shohar connected successfully! 🌸'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF2E7D32),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),

          // 3. Sharing Presets (3-Tier Mode)
          Text(
            '🎯 Sharing Preset (Data Sharing Ki Had):',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E1A47),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  title: 'Full Care',
                  subtitle: 'Sab Data Sync',
                  icon: '🌟',
                  isSelected: partner.sharingPreset == 'full',
                  onTap: () => ref.read(partnerPermissionProvider.notifier).applyPreset('full'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetCard(
                  title: 'Essential',
                  subtitle: 'Dates & Scans',
                  icon: '🛡️',
                  isSelected: partner.sharingPreset == 'essential',
                  onTap: () => ref.read(partnerPermissionProvider.notifier).applyPreset('essential'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetCard(
                  title: 'Custom',
                  subtitle: 'Apni Marzi',
                  icon: '⚙️',
                  isSelected: partner.sharingPreset == 'custom',
                  onTap: () => ref.read(partnerPermissionProvider.notifier).applyPreset('custom'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 4. Granular Privacy Toggles
          Text(
            '🔒 Alag Alag Permissions (Custom Controls):',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E1A47),
            ),
          ),
          const SizedBox(height: 6),

          _buildSwitchTile(
            title: '🌸 Mahwari & Aglay Period Ki Dates',
            subtitle: 'Cycle length aur expected dates share hon gi',
            value: partner.shareCycleDates,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(shareCycleDates: val, sharingPreset: 'custom'),
                  );
            },
          ),
          _buildSwitchTile(
            title: '💑 Intimacy & Conception (TTC) Logs',
            subtitle: 'Fertile days aur intimate milan taake planning ho sakay',
            value: partner.shareIntimacy,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(shareIntimacy: val, sharingPreset: 'custom'),
                  );
            },
          ),
          _buildSwitchTile(
            title: '🤰 Pregnancy Milestones & Baby Growth',
            subtitle: 'Baby size aur hafton ki updates shohar ko dikhein',
            value: partner.sharePregnancyMilestones,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(sharePregnancyMilestones: val, sharingPreset: 'custom'),
                  );
            },
          ),
          _buildSwitchTile(
            title: '🩺 Doctor Appointments & Scans',
            subtitle: 'Clinic checkup aur ultrasound ki dates',
            value: partner.shareAppointments,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(shareAppointments: val, sharingPreset: 'custom'),
                  );
            },
          ),
          _buildSwitchTile(
            title: '🌿 Symptoms, Pain & Mood Updates',
            subtitle: 'Takleef, dard aur mood updates',
            value: partner.shareSymptoms,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(shareSymptoms: val, sharingPreset: 'custom'),
                  );
            },
          ),
          _buildSwitchTile(
            title: '🔒 Niji Diary / Private Notes',
            subtitle: 'Personal dairy notes (By default band hoti hai)',
            value: partner.sharePersonalNotes,
            onChanged: (val) {
              ref.read(partnerPermissionProvider.notifier).update(
                    partner.copyWith(sharePersonalNotes: val, sharingPreset: 'custom'),
                  );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFFE2D9EC),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? const Color(0xFF4A148C) : const Color(0xFF2E1A47),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFF7A6A8D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: const Color(0xFF7A6A8D),
          ),
        ),
        activeTrackColor: const Color(0xFF6A1B9A),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _confirmDisconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828)),
            const SizedBox(width: 8),
            Text(
              'Shohar Ko Unpair Karein?',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Text(
          'Kya aap waqai shohar ko disconnect karna chahti hain? Synced data share hona band ho jaye ga aur partner access khatam ho jaye ga.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF4A3B60), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(partnerPermissionProvider.notifier).disconnectPartner();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shohar successfully disconnected.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Disconnect', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
