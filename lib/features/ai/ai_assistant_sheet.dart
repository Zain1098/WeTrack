import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';
import '../app_providers.dart';
import '../pregnancy/positive_test_modal.dart';
import '../pregnancy/kick_counter_modal.dart';
import '../safety/emergency_red_flags_modal.dart';
import '../cycle/log_symptoms_modal.dart';
import '../cycle/log_period_modal.dart';
import '../appointments/appointment_modal.dart';
import '../fertility/intimacy_log_modal.dart';
import 'ai_service.dart';
import 'gemini_ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? citation;
  final bool isOffline;
  final List<AIAction> actions;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.citation,
    this.isOffline = false,
    this.actions = const [],
  });
}

class AIAssistantSheet extends ConsumerStatefulWidget {
  const AIAssistantSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AIAssistantSheet(),
    );
  }

  @override
  ConsumerState<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends ConsumerState<AIAssistantSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = GeminiAIService();

  bool _isLoading = false;
  List<ChatMessage> _messages = [];

  static const List<(String, String)> _romanSuggestions = [
    ('💕', 'Sperm andar gaya hai, kya pregnancy theher sakti hai?'),
    ('💊', 'Emergency Contraceptive Pill (ECP) kab aur kaise lein?'),
    ('🤰', 'Hamal me mubashrat / sex kab mehfooz hai?'),
    ('🌸', 'Cycle Day ka kya matlab hai?'),
    ('🥚', 'Hamal theherne ke best din kab hain?'),
    ('🧪', 'Pregnancy test kab karna chahiye?'),
    ('💊', 'Folic Acid kab aur kyun lein?'),
    ('🩸', 'PCOS aur irregular periods kya hai?'),
    ('🩺', 'Doctor se kya sawalaat poochein?'),
    ('💧', 'Safed pani (Discharge) ka matlab'),
    ('🧔', 'Shohar ko kaise samjhayein?'),
    ('⚠️', 'Emergency / Khatray ki alamat'),
  ];

  static const List<(String, String)> _englishSuggestions = [
    ('💕', 'Unprotected sex & sperm inside risk?'),
    ('💊', 'Emergency contraception (ECP) guidance?'),
    ('🤰', 'Is intercourse safe during pregnancy?'),
    ('🌸', 'What does cycle day mean?'),
    ('🥚', 'Best days for conception?'),
    ('🧪', 'When to take pregnancy test?'),
    ('💊', 'Folic acid benefits & dosage?'),
    ('🩸', 'PCOS & irregular period signs?'),
    ('🩺', 'Questions for my gynecologist'),
    ('💧', 'What does cervical mucus mean?'),
    ('🧔', 'Husband guidance & fertility support'),
    ('⚠️', 'Emergency symptoms / Red flags'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWelcomeMessage();
    });
  }

  void _initWelcomeMessage() {
    final profile = ref.read(userProfileProvider);
    final lang = ref.read(languageProvider);
    final isRoman = lang == AppLanguage.romanUrdu;
    final nameStr = profile.name.isNotEmpty ? profile.name : 'Piyari Behan';

    setState(() {
      _messages = [
        ChatMessage(
          text: isRoman
              ? 'Assalam-o-Alaikum $nameStr! 🌸\n\n'
                'Main aapki WeTrack Saathi hoon. Aap mujh se mahwari (periods), pregnancy planning, beza/ovulation, aur sehat ke baray mein be-jhijhak pooch sakti hain.\n\n'
                '💬 *Aap mujh se aasan Roman Urdu ya English mein baat kar sakti hain!*'
              : 'Hello $nameStr! 🌸\n\n'
                'I am your WeTrack AI Companion. I can help explain your cycle phases, fertile window science, and help you prepare questions for your doctor.\n\n'
                '💬 *Feel free to ask in Roman Urdu or English!*',
          isUser: false,
          citation: isRoman
              ? 'WeTrack Tibbi Rahnumai • ASRM Standard'
              : 'ASRM Grounded Knowledgebase',
        ),
      ];
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Prepare structured context
    final profile = ref.read(userProfileProvider);
    final cycleCalc = ref.read(cycleCalculationProvider);
    final pregCalc = ref.read(pregnancyCalculationProvider);
    final lang = ref.read(languageProvider);

    final reqContext = AIRequestContext(
      goal: profile.goal,
      userName: profile.name,
      currentCycleDay: cycleCalc.currentCycleDay,
      cycleLength: cycleCalc.estimatedCycleLength,
      cyclePhaseName: cycleCalc.currentPhase.displayName,
      pregnancyGestationalAge: pregCalc?.formattedGestationalAge,
      pregnancyTrimester: pregCalc?.currentTrimester,
      isRomanUrdu: lang == AppLanguage.romanUrdu,
    );

    final savedKey = ref.read(geminiApiKeyProvider);
    final activeService = savedKey.isNotEmpty ? GeminiAIService(apiKey: savedKey) : _aiService;
    final response = await activeService.askQuestion(
      context: reqContext,
      question: query,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            text: response.text,
            isUser: false,
            citation: response.sourceCitation,
            isOffline: response.isOfflineFallback,
            actions: response.actions,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _executeAction(AIAction action) async {
    switch (action.type) {
      case AIActionType.openIntimacyLog:
        Navigator.pop(context);
        IntimacyLogModal.show(context);
        break;

      case AIActionType.switchToPregnancy:
        await ref.read(userProfileProvider.notifier).switchToPregnancyMode();
        if (mounted) {
          setState(() {
            _messages.add(
              const ChatMessage(
                text: '🎉 Mubarak! WeTrack ab mukammal taur par Hamal (Pregnancy) Mode mein active ho chuka hai. Period predictions pause kar di gayi hain aur weekly baby tracker shuru ho gaya hai 🍼✨',
                isUser: false,
                citation: 'WeTrack Mode Updated',
              ),
            );
          });
          _scrollToBottom();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFC2185B),
              content: Text(
                'Mubarak! Hamal Mode Active Ho Gaya Hai 🍼✨',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );
        }
        break;

      case AIActionType.switchToCycle:
        await ref.read(userProfileProvider.notifier).switchToCycleMode();
        if (mounted) {
          setState(() {
            _messages.add(
              const ChatMessage(
                text: '🌸 WeTrack ab Mahwari (Cycle Tracking) Mode mein wapas aa chuka hai.',
                isUser: false,
                citation: 'WeTrack Mode Updated',
              ),
            );
          });
          _scrollToBottom();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF9C27B0),
              content: Text(
                'Mahwari (Cycle Tracking) Mode Active Hua 🌸',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );
        }
        break;

      case AIActionType.openEmergencyModal:
        Navigator.pop(context);
        EmergencyRedFlagsModal.show(context);
        break;

      case AIActionType.openPositiveTestModal:
        Navigator.pop(context);
        PositivePregnancyTestModal.show(context);
        break;

      case AIActionType.openLogSymptoms:
        Navigator.pop(context);
        LogSymptomsModal.show(context);
        break;

      case AIActionType.openKickCounter:
        Navigator.pop(context);
        KickCounterModal.show(context);
        break;

      case AIActionType.openAppointmentModal:
        Navigator.pop(context);
        AppointmentModal.show(context);
        break;

      case AIActionType.openLogPeriod:
        Navigator.pop(context);
        LogPeriodModal.show(context);
        break;
    }
  }

  void _showApiKeyDialog() {
    final currentKey = ref.read(geminiApiKeyProvider);
    final keyController = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: Color(0xFFF04E78)),
            SizedBox(width: 8),
            Text('Gemini AI Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apni Google Gemini API key enter karein taake real-time live AI answers milein. Agar key na ho to WeTrack offline brain bilkul muft kaam karega.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                labelText: 'Google Gemini API Key',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF04E78),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await ref.read(geminiApiKeyProvider.notifier).setApiKey(keyController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gemini API Key Mehfooz Kar Li Gayi! ✨'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isRoman = lang == AppLanguage.romanUrdu;
    final currentSuggestions = isRoman ? _romanSuggestions : _englishSuggestions;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: EdgeInsets.only(
        top: 14,
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x208B5CF6),
            blurRadius: 36,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2DCF0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sheet Header with Cute 3D Companion Avatar & Language Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFEEF3), Color(0xFFFFD4E2)],
                        center: Alignment.center,
                      ),
                      border: Border.all(color: const Color(0xFFFFBFD6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF04E78).withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'UI/Profile page character.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFF04E78),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isRoman ? 'WeTrack Saathi 🌸' : 'WeTrack AI Saathi 🌸',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1A29),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isRoman
                            ? 'Aapki Niji Health Guide • Roman English'
                            : 'Personal Health Guide • Empathetic AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF867E96),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.vpn_key_rounded, size: 20, color: Color(0xFFF04E78)),
                    tooltip: 'AI API Key',
                    onPressed: _showApiKeyDialog,
                  ),
                  const ClayLanguageToggle(isCompact: true),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF867E96)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF0ECF7)),

          // Suggestion Chips (In Roman Urdu / Roman English)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: currentSuggestions.length,
              itemBuilder: (ctx, idx) {
                final item = currentSuggestions[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _sendMessage(item.$2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF6F9), Color(0xFFFFEEF4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD4E2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.$1, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            item.$2,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9C27B0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFF04E78)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRoman
                        ? 'WeTrack Saathi soch rahi hai... 🌸'
                        : 'Consulting WeTrack health knowledgebase...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF867E96),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Input Box with 3D tactile pill design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDE8F6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: _sendMessage,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF1E1A29)),
                    decoration: InputDecoration(
                      hintText: isRoman
                          ? 'Yahan sawaal likhein (Roman Urdu/English)...'
                          : 'Ask about cycle, symptoms, fertility...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF9E8EA8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _sendMessage(_inputController.text),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7E9C), Color(0xFFF04E78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF04E78).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: const Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FD),
          borderRadius: BorderRadius.circular(22).copyWith(
            topLeft: const Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌸', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'WeTrack Saathi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF04E78),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: const Color(0xFF2C243B),
                height: 1.5,
              ),
            ),
            if (msg.citation != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EEFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, size: 12, color: Color(0xFF7E60E4)),
                    const SizedBox(width: 4),
                    Text(
                      msg.citation!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF7E60E4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (msg.actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.actions.map((act) {
                  return GestureDetector(
                    onTap: () => _executeAction(act),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF0F5), Color(0xFFFFE0EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFB6C1), width: 1.3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(act.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 7),
                          Text(
                            act.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFC2185B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFC2185B)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
