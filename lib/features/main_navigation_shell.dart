import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/clay_colors.dart';
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Quick Action',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: ClayColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop, color: ClayColors.secondary),
              ),
              title: const Text('Log Period Day', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Record bleeding flow & start date', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                LogPeriodModal.show(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: ClayColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.healing, color: ClayColors.primary),
              ),
              title: const Text('Log Symptoms & Mood', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Record cramps, energy, headaches, moods', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                LogSymptomsModal.show(context);
              },
            ),
            if (goal == AppGoal.tryToConceive) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: ClayColors.sunnyContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Color(0xFFD97706)),
                ),
                title: const Text('Log Ovulation Test (LH)', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Record test result, cervical mucus, intimacy', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  LogFertilityModal.show(context);
                },
              ),
            ],
            if (goal != AppGoal.alreadyPregnant) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: ClayColors.mintContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.child_care, color: ClayColors.mint),
                ),
                title: const Text('Positive Pregnancy Test', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Transition to pregnancy tracking mode', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  PositivePregnancyTestModal.show(context);
                },
              ),
            ],
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: ClayColors.surfaceTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: ClayColors.primary),
              ),
              title: const Text('Ask AI Educational Companion',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Questions on cycle, science & doctor prep',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                AIAssistantSheet.show(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: ClayColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _showQuickLogMenu(context),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x208B5CF6),
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.spa_outlined, Icons.spa_rounded, 'Home'),
            _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Calendar'),
            const SizedBox(width: 44), // Space for notched FAB
            _buildNavItem(2, Icons.auto_graph_outlined, Icons.auto_graph_rounded, 'Insights'),
            _buildNavItem(3, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Learn'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? ClayColors.primary : ClayColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? ClayColors.primary : ClayColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
