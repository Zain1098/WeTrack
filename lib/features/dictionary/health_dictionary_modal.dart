import 'package:flutter/material.dart';
import '../../data/services/health_dictionary_service.dart';

class HealthDictionaryModal extends StatefulWidget {
  final String? initialSearchTerm;

  const HealthDictionaryModal({super.key, this.initialSearchTerm});

  static Future<void> show(BuildContext context, {String? initialSearchTerm}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HealthDictionaryModal(initialSearchTerm: initialSearchTerm),
    );
  }

  @override
  State<HealthDictionaryModal> createState() => _HealthDictionaryModalState();
}

class _HealthDictionaryModalState extends State<HealthDictionaryModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  List<HealthDictionaryEntry> _filteredEntries = HealthDictionaryService.entries;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchTerm != null && widget.initialSearchTerm!.isNotEmpty) {
      _searchController.text = widget.initialSearchTerm!;
      _filter();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchController.text.trim();
    var list = HealthDictionaryService.search(query);
    if (_selectedCategory != 'all') {
      list = list.where((e) => e.category == _selectedCategory).toList();
    }
    setState(() {
      _filteredEntries = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFFBF9FE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x203B1E54),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD6CEE8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD5E2)),
                  ),
                  child: const Center(
                    child: Text('📖', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aasan Roman Lughat (Dictionary)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1A47),
                        ),
                      ),
                      Text(
                        'Mushkil medical words ka aasan Roman Urdu matlab',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A6A8D),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF6B587B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8DEF8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x082E1A47),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _filter(),
                decoration: InputDecoration(
                  hintText: 'Search karein (e.g. Fertile, Ovulation, Period)...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E8EAD)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9E8CE7)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filter();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildCategoryChip('all', 'Sab Alfaz (All)'),
                _buildCategoryChip('fertility', '🌿 Hamal & Fertile'),
                _buildCategoryChip('cycle', '🌸 Periods & Cycle'),
                _buildCategoryChip('pregnancy', '🤰 Pregnancy'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dictionary Entries List
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        const Text(
                          'Koi lafz nahi mila',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dusra lafz likh kar check karein ya category badlein',
                          style: TextStyle(fontSize: 13, color: Color(0xFF7A6A8D)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return _buildEntryCard(entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, String label) {
    final isSelected = _selectedCategory == categoryKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
          _filter();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9E8CE7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9E8CE7) : const Color(0xFFE8DEF8),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF9E8CE7).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF5D4A72),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(HealthDictionaryEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0EBF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x072E1A47),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Term + Pronunciation
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(entry.icon, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.term,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1A47),
                        ),
                      ),
                      Text(
                        'Bolne ka tareeqa: "${entry.romanPronunciation}"',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E8CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Simple title banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Aasan Matlab: ${entry.simpleTitle}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD81B60),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Definition in Roman Urdu
            Text(
              entry.romanDefinition,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF3F3356),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Practical Tip
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.practicalExample,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B5B80),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
