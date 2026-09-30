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

  String _name = 'Sarah';
  AppGoal _selectedGoal = AppGoal.trackCycle;
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  int _cycleLength = 28;
  int _periodDuration = 5;

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
          name: _name.trim().isEmpty ? 'Friend' : _name.trim(),
          goal: _selectedGoal,
          lastPeriodDate: _lastPeriodDate,
          usualCycleLength: _cycleLength,
          usualPeriodDuration: _periodDuration,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  _buildWelcomePage(),
                  _buildGoalSelectionPage(),
                  _buildCycleBasicsPage(),
                  _buildLastPeriodDatePage(),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: ClayButton(
                text: _currentPage == 3 ? 'Get Started' : 'Continue',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Welcome & Privacy Commitment
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // 3D Companion preview card
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 220,
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
          const SizedBox(height: 24),
          const Text(
            'Welcome to WeTrack',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your private, clinical-grade companion for menstrual cycles, fertility, and pregnancy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: ClayColors.textSecondary,
              height: 1.4,
            ),
          ),
          // Name Input Card
          ClayCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            backgroundColor: Colors.white,
            child: TextField(
              onChanged: (val) => setState(() => _name = val),
              decoration: const InputDecoration(
                icon: Icon(Icons.person_outline, color: ClayColors.primary),
                hintText: 'What should we call you? (e.g. Sarah)',
                hintStyle: TextStyle(fontSize: 13, color: ClayColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy Card
          ClayCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: ClayColors.mintContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: ClayColors.mint),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Private & Offline-First',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your health data stays safely on your device. No ads, no trackers.',
                        style: TextStyle(
                          fontSize: 12,
                          color: ClayColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Goal Selection
  Widget _buildGoalSelectionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your primary goal?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We customize your daily experience based on your journey.',
            style: TextStyle(fontSize: 14, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...AppGoal.values.map((goal) {
            final isSelected = _selectedGoal == goal;
            IconData iconData;
            Color iconBg;

            switch (goal) {
              case AppGoal.trackCycle:
                iconData = Icons.calendar_month_rounded;
                iconBg = ClayColors.secondaryContainer;
                break;
              case AppGoal.tryToConceive:
                iconData = Icons.favorite_rounded;
                iconBg = ClayColors.primaryContainer;
                break;
              case AppGoal.alreadyPregnant:
                iconData = Icons.child_care_rounded;
                iconBg = ClayColors.mintContainer;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ClayCard(
                onTap: () => setState(() => _selectedGoal = goal),
                backgroundColor: isSelected ? Colors.white : const Color(0xFFFBFBFE),
                border: Border.all(
                  color: isSelected ? ClayColors.primary : Colors.transparent,
                  width: 2,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? ClayColors.primary : ClayColors.textPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? ClayColors.primary
                                  : ClayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ClayColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: ClayColors.primary)
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Step 3: Cycle Length & Period Duration
  Widget _buildCycleBasicsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your typical cycle',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Used for initial estimates. WeTrack automatically refines this as you log.',
            style: TextStyle(fontSize: 14, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 28),

          // Cycle length slider card
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Average Cycle Length',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$_cycleLength days',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _cycleLength.toDouble(),
                  min: 20,
                  max: 45,
                  divisions: 25,
                  activeColor: ClayColors.primary,
                  inactiveColor: ClayColors.primaryContainer,
                  onChanged: (val) => setState(() => _cycleLength = val.round()),
                ),
                const Text(
                  'Typically 28 days (measured from first day of one period to the next).',
                  style: TextStyle(fontSize: 12, color: ClayColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Period duration slider card
          ClayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Period Bleeding Duration',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$_periodDuration days',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _periodDuration.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8,
                  activeColor: ClayColors.secondary,
                  inactiveColor: ClayColors.secondaryContainer,
                  onChanged: (val) => setState(() => _periodDuration = val.round()),
                ),
                const Text(
                  'Number of days menstrual bleeding usually lasts (typically 4–7 days).',
                  style: TextStyle(fontSize: 12, color: ClayColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Last Period Date
  Widget _buildLastPeriodDatePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When did your last period start?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Day 1 of your cycle is the first day of menstrual bleeding.',
            style: TextStyle(fontSize: 14, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 32),

          ClayCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: ClayColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: ClayColors.secondary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateHelpers.formatFriendly(_lastPeriodDate),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateHelpers.daysBetween(_lastPeriodDate, DateTime.now())} days ago',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ClayColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ClayButton(
                  text: 'Select Date',
                  variant: ClayButtonVariant.subtle,
                  height: 44,
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastPeriodDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: ClayColors.primary,
                            onPrimary: Colors.white,
                            onSurface: ClayColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _lastPeriodDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
