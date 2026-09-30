
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_pill.dart';
import '../app_providers.dart';
import 'ai_service.dart';
import 'gemini_ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? citation;
  final bool isOffline;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.citation,
    this.isOffline = false,
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
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text:
          'Hello! I am your WeTrack Educational Assistant. I can help explain your cycle phases, fertile window science, and help you prepare questions for your doctor.\n\nRemember: I am an educational guide, not a medical doctor. I do not provide clinical diagnoses.',
      isUser: false,
      citation: 'ASRM Grounded Knowledgebase',
    ),
  ];

  static const List<String> _suggestions = [
    'What does cycle day mean?',
    'Explain fertile window',
    'Do I have PCOS?',
    'Folic acid benefits',
    'Questions for my doctor',
  ];

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

    final reqContext = AIRequestContext(
      goal: profile.goal,
      userName: profile.name,
      currentCycleDay: cycleCalc.currentCycleDay,
      cycleLength: cycleCalc.estimatedCycleLength,
      cyclePhaseName: cycleCalc.currentPhase.displayName,
      pregnancyGestationalAge: pregCalc?.formattedGestationalAge,
      pregnancyTrimester: pregCalc?.currentTrimester,
    );

    final response = await _aiService.askQuestion(
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
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ClayColors.surfaceTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: ClayColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WeTrack AI Companion',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Educational Only • Zero Diagnosis',
                        style: TextStyle(
                          fontSize: 11,
                          color: ClayColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: ClayColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20, color: ClayColors.outline),

          // Suggestion Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _suggestions.map((sug) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClayPill(
                    label: sug,
                    onTap: () => _sendMessage(sug),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(msg);
              },
            ),
          ),

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
                      valueColor: AlwaysStoppedAnimation(ClayColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Consulting ASRM educational knowledgebase...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: ClayColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: ClayColors.canvas,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: ClayColors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: _sendMessage,
                    decoration: const InputDecoration(
                      hintText: 'Ask about cycle, symptoms, fertility...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: ClayColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  color: ClayColors.primary,
                  onPressed: () => _sendMessage(_inputController.text),
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
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: ClayColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
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
          color: ClayColors.canvas,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ClayColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: const TextStyle(
                fontSize: 14,
                color: ClayColors.textPrimary,
                height: 1.45,
              ),
            ),
            if (msg.citation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.menu_book, size: 12, color: ClayColors.mint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      msg.citation!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ClayColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
