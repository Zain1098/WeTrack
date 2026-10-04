import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/user_profile.dart';
import '../app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Audio 2 Profile Fields
  String _name = 'Sarah';
  int _age = 23;
  String _maritalStatus = 'unmarried'; // 'married' or 'unmarried'
  double _heightCm = 160.0;
  double _weightKg = 53.0;
  AppGoal _selectedGoal = AppGoal.trackCycle;
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  int _cycleLength = 28;
  int _periodDuration = 5;
  String _todayMood = 'Khush (Happy)';

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(userProfileProvider.notifier).completeOnboarding(
          name: _name.trim().isEmpty ? 'Sarah' : _name.trim(),
          goal: _selectedGoal,
          lastPeriodDate: _lastPeriodDate,
          usualCycleLength: _cycleLength,
          usualPeriodDuration: _periodDuration,
          age: _age,
          maritalStatus: _maritalStatus,
          heightCm: _heightCm,
          weightKg: _weightKg,
          todayMood: _todayMood,
        );

    // If goal is already pregnant, create initial pregnancy record
    if (_selectedGoal == AppGoal.alreadyPregnant) {
      await ref
          .read(pregnancyRecordProvider.notifier)
          .startPregnancyFromLmp(_lastPeriodDate);
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: _prevPage,
                      color: ClayColors.textPrimary,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 28 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? ClayColors.primary
                                  : ClayColors.outline,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildProfileBasicsPage(),
                  _buildPhysicalAndGoalPage(),
                  _buildCycleBasicsPage(),
                  _buildTodayMoodPage(),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: ClayButton(
                text: _currentPage == 3 ? 'WeTrack Shuru Karein ✨' : 'Aage Barhein (Continue)',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Name, Age & Marital Status
  Widget _buildProfileBasicsPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Companion preview card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 180,
              width: double.infinity,
              color: ClayColors.surfaceTint,
              child: Image.asset(
                'UI/Pastel clay-style app login screen.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Icon(Icons.spa_rounded, size: 64, color: ClayColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Khush Aamdeed! 🌸',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aapki personal health companion. Pehle aapka chhota sa ta\'aruf:',
            style: TextStyle(
              fontSize: 14,
              color: ClayColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Name Input
          const Text(
            'Aapka Pyara Naam:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 6),
          ClayCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            backgroundColor: Colors.white,
            child: TextField(
              controller: TextEditingController(text: _name)..selection = TextSelection.collapsed(offset: _name.length),
              onChanged: (val) => _name = val,
              decoration: const InputDecoration(
                icon: Icon(Icons.person_outline_rounded, color: ClayColors.primary, size: 20),
                hintText: 'Apna naam likhein (e.g. Ayesha, Fatima)',
                hintStyle: TextStyle(fontSize: 13, color: ClayColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Age Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aapki Umar (Age):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ClayColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_age Saal',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: ClayColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: _age.toDouble(),
            min: 14,
            max: 55,
            divisions: 41,
            activeColor: ClayColors.primary,
            inactiveColor: ClayColors.primaryContainer,
            onChanged: (val) => setState(() => _age = val.round()),
          ),
          const SizedBox(height: 12),

          // Marital Status (Audio 2: Married ya Unmarried)
          const Text(
            'Shadi Shuda Hain ya Ghair Shadi Shuda?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: '💍 Shadi Shuda\n(Married)',
                  isSelected: _maritalStatus == 'married',
                  onTap: () => setState(() => _maritalStatus = 'married'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceCard(
                  title: '🌸 Ghair Shadi\n(Unmarried)',
                  isSelected: _maritalStatus == 'unmarried',
                  onTap: () => setState(() => _maritalStatus = 'unmarried'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Step 2: Physical Stats & Primary Goal
  Widget _buildPhysicalAndGoalPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qad aur Wazan (Body Stats)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Is se aapke cycle aur health ki behtar calculation hoti hai.',
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 18),

          // Height Slider
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Qad (Height):', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${_heightCm.round()} cm (${(_heightCm / 30.48).toStringAsFixed(1)} ft)',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: ClayColors.primary),
                    ),
                  ],
                ),
                Slider(
                  value: _heightCm,
                  min: 130,
                  max: 200,
                  divisions: 70,
                  activeColor: ClayColors.primary,
                  inactiveColor: ClayColors.primaryContainer,
                  onChanged: (v) => setState(() => _heightCm = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Weight Slider
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Wazan (Weight):', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${_weightKg.round()} kg',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: ClayColors.secondary),
                    ),
                  ],
                ),
                Slider(
                  value: _weightKg,
                  min: 35,
                  max: 120,
                  divisions: 85,
                  activeColor: ClayColors.secondary,
                  inactiveColor: ClayColors.secondaryContainer,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // App Goal
          const Text(
            'Aapka Main Maqsad (Goal) Kya Hai?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
          ),
          const SizedBox(height: 10),

          _buildGoalCard(
            goal: AppGoal.trackCycle,
            emoji: '🌸',
            title: 'Mahwari (Period) Track Karna',
            subtitle: 'Agla period kab aayega aur dates yaad rakhne ke liye',
          ),
          _buildGoalCard(
            goal: AppGoal.tryToConceive,
            emoji: '🌿',
            title: 'Hamal Theharne Ki Koshish (Baby Plan)',
            subtitle: 'Fertile days aur ovulation ke dino ki guidance',
          ),
          _buildGoalCard(
            goal: AppGoal.alreadyPregnant,
            emoji: '🤰',
            title: 'Hamal Thehar Chuka Hai (Pregnant)',
            subtitle: 'Hafte-ba-hafte baby ki growth aur delivery date',
          ),
        ],
      ),
    );
  }

  // Step 3: Cycle Basics & Last Period Date
  Widget _buildCycleBasicsPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aakhri Period aur Cycle',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aakhri period kis tareekh ko shuru hua tha?',
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Last Period Date Picker Card
          ClayCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: ClayColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: ClayColors.secondary, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  DateHelpers.formatFriendly(_lastPeriodDate),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: ClayColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateHelpers.daysBetween(_lastPeriodDate, DateTime.now())} din pehle shuru hua tha',
                  style: const TextStyle(fontSize: 13, color: ClayColors.textSecondary),
                ),
                const SizedBox(height: 14),
                ClayButton(
                  text: 'Tareekh Badlein (Pick Date)',
                  variant: ClayButtonVariant.subtle,
                  height: 40,
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastPeriodDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _lastPeriodDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cycle length
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cycle kitne din ki hoti hai?', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_cycleLength Din', style: const TextStyle(fontWeight: FontWeight.w900, color: ClayColors.primary)),
                  ],
                ),
                Slider(
                  value: _cycleLength.toDouble(),
                  min: 21,
                  max: 42,
                  divisions: 21,
                  activeColor: ClayColors.primary,
                  inactiveColor: ClayColors.primaryContainer,
                  onChanged: (v) => setState(() => _cycleLength = v.round()),
                ),
                const Text('Aam tor par larkiyon me 28 din ki hoti hai.', style: TextStyle(fontSize: 11, color: ClayColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bleeding duration
          ClayCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bleeding kitne din chalti hai?', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$_periodDuration Din', style: const TextStyle(fontWeight: FontWeight.w900, color: ClayColors.secondary)),
                  ],
                ),
                Slider(
                  value: _periodDuration.toDouble(),
                  min: 2,
                  max: 9,
                  divisions: 7,
                  activeColor: ClayColors.secondary,
                  inactiveColor: ClayColors.secondaryContainer,
                  onChanged: (v) => setState(() => _periodDuration = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Today Mood Check-in (Audio 2)
  Widget _buildTodayMoodPage() {
    final moods = [
      {'emoji': '😊', 'title': 'Khush (Happy)', 'desc': 'Mood bilkul acha aur fresh hai'},
      {'emoji': '😌', 'title': 'Pur Sukoon (Calm)', 'desc': 'Normal routine, koi pareshani nahi'},
      {'emoji': '😴', 'title': 'Thakan (Tired)', 'desc': 'Thakan mehsoos ho rahi hai, aaram chahiye'},
      {'emoji': '😤', 'title': 'Chidchida-pan (Moody)', 'desc': 'Bina wajah ghussa ya chirh aa rahi hai'},
      {'emoji': '🤕', 'title': 'Pet / Kamar Dard (Cramps)', 'desc': 'Period ya PMS ki wajah se dard hai'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aaj Ka Mood Kaisa Hai? ✨',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rozana sirf ek tap me batayein taake WeTrack aapki body ko samajh sakey.',
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 20),

          ...moods.map((m) {
            final isSelected = _todayMood == m['title'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _todayMood = m['title']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFFBFBFE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? ClayColors.primary : const Color(0xFFECE7F6),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: ClayColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? ClayColors.surfaceTint : const Color(0xFFF3EEFA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(m['emoji']!, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['title']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m['desc']!,
                              style: const TextStyle(fontSize: 11.5, color: ClayColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: ClayColors.primary, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F5FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ClayColors.primary : const Color(0xFFE8DEF8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ClayColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required AppGoal goal,
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedGoal == goal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedGoal = goal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFFBFBFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? ClayColors.primary : const Color(0xFFECE7F6),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ClayColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: ClayColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
