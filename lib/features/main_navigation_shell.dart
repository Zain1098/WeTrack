import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/clay_colors.dart';
import '../core/localization/language_provider.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'insights/insights_screen.dart';
import 'education/learn_screen.dart';
import 'settings/settings_screen.dart';
import 'cycle/log_period_modal.dart';
import 'cycle/log_symptoms_modal.dart';
import 'fertility/log_fertility_modal.dart';
import 'pregnancy/positive_test_modal.dart';
import 'ai/ai_assistant_sheet.dart';
import '../data/models/user_profile.dart';
import 'app_providers.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    LearnScreen(),
    SettingsScreen(),
  ];

  void _showQuickLogMenu(BuildContext context) {
    final goal = ref.read(userProfileProvider).goal;
    final s = ref.read(appStringsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D9EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.quickActionsTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _build3DQuickTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFFE91E63),
                  bgColor: const Color(0xFFFCE4EC),
                  title: s.logPeriodTitle,
                  subtitle: s.logPeriodSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    LogPeriodModal.show(context);
                  },
                ),
                const SizedBox(height: 10),
                _build3DQuickTile(
                  icon: Icons.healing_rounded,
                  iconColor: const Color(0xFFAB47BC),
                  bgColor: const Color(0xFFF3E5F5),
                  title: s.logSymptomsTitle,
                  subtitle: s.logSymptomsSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    LogSymptomsModal.show(context);
                  },
                ),
                if (goal == AppGoal.tryToConceive) ...[
                  const SizedBox(height: 10),
                  _build3DQuickTile(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFF57C00),
                    bgColor: const Color(0xFFFFF3E0),
                    title: s.logOvulationTitle,
                    subtitle: s.logOvulationSubtitle,
                    onTap: () {
                      Navigator.pop(ctx);
                      LogFertilityModal.show(context);
                    },
                  ),
                ],
                if (goal != AppGoal.alreadyPregnant) ...[
                  const SizedBox(height: 10),
                  _build3DQuickTile(
                    icon: Icons.child_care_rounded,
                    iconColor: const Color(0xFF00897B),
                    bgColor: const Color(0xFFE0F2F1),
                    title: s.positiveTestTitle,
                    subtitle: s.positiveTestSubtitle,
                    onTap: () {
                      Navigator.pop(ctx);
                      PositivePregnancyTestModal.show(context);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                _build3DQuickTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFF5E35B1),
                  bgColor: const Color(0xFFEDE7F6),
                  title: s.askAiTitle,
                  subtitle: s.askAiSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    AIAssistantSheet.show(context);
                  },
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DQuickTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8FE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDE7F6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x062E1065),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ClayColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFB0A4C0)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showQuickLogMenu(context),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF85A1), // Cool soothing rose-petal
                Color(0xFFF04E78), // Tranquil signature pink
                Color(0xFFD84A78), // Calming deep rose
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF04E78).withValues(alpha: 0.40),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFFFF85A1).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3.5),
          ),
          child: const Center(
            child: Icon(Icons.add_rounded, size: 32, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF7FA), // Cool peaceful rose milk
              Color(0xFFFFEFF5), // Soothing fresh petal blush
              Color(0xFFFDE8F1), // Tranquil calm pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFFFD2E2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF04E78).withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: Color(0x082E1065),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent, // Let tranquil pink gradient shine
            notchMargin: 8,
            shape: const CircularNotchedRectangle(),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _buildNavItem(0, Icons.spa_outlined, Icons.spa_rounded, s.navHome),
                _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, s.navCalendar),
                const SizedBox(width: 48), // Space for notched FAB
                _buildNavItem(2, Icons.auto_graph_outlined, Icons.auto_graph_rounded, s.navInsights),
                _buildNavItem(3, Icons.menu_book_outlined, Icons.menu_book_rounded, s.navLearn),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFFFF0F5),
                        Color(0xFFFFDAE8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFFFFBFD6), width: 1)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF04E78).withValues(alpha: 0.16),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF9E8EA8),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? const Color(0xFFC2185B) : const Color(0xFF9E8EA8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
