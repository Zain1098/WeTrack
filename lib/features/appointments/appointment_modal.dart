import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/appointment.dart';
import '../app_providers.dart';

class AppointmentModal extends ConsumerStatefulWidget {
  const AppointmentModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AppointmentModal(),
    );
  }

  @override
  ConsumerState<AppointmentModal> createState() => _AppointmentModalState();
}

class _AppointmentModalState extends ConsumerState<AppointmentModal> {
  bool _isAddingNew = false;
  final _titleController = TextEditingController(text: 'Routine Ultrasound Scan');
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 11, minute: 0);

  final List<String> _quickTypes = [
    'Routine Ultrasound Scan',
    'Doctor Consultation',
    'Blood Test / Lab',
    'Glucose Screening',
    'Anomaly Scan (Week 20)',
    'Prenatal Checkup',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAppointment() async {
    if (_titleController.text.trim().isEmpty) return;

    final fullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await ref.read(appointmentsProvider.notifier).addAppointment(
          dateTime: fullDateTime,
          title: _titleController.text.trim(),
          clinicianName: _doctorController.text.trim().isNotEmpty
              ? _doctorController.text.trim()
              : null,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

    setState(() {
      _isAddingNew = false;
      _doctorController.clear();
      _locationController.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle bar
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

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🏥', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor Appointments',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E1A47),
                            ),
                          ),
                          Text(
                            'Ultrasound, Checkup & Test Record',
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 20, color: Color(0xFFF0EBF5)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _isAddingNew
                    ? _buildAddAppointmentForm(context)
                    : _buildAppointmentList(appointments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add New Button
        GestureDetector(
          onTap: () => setState(() => _isAddingNew = true),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9E8CE7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  '+ Naya Appointment / Scan Add Karein',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (appointments.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(26),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8FE),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEDE7F6)),
            ),
            child: Column(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                const Text(
                  'Koi Appointment Saved Nahi Hai',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E1A47),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Doctor checkup ya ultrasound scan date record karein taake waqt par reminder milay aur records mehfooz rahein.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A6A8D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const Text(
            'Schedule Kiye Gaye Appointments',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A3B60),
            ),
          ),
          const SizedBox(height: 12),
          ...appointments.map((apt) {
            final isPast = apt.dateTime.isBefore(DateTime.now());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPast ? const Color(0xFFF5F3F7) : const Color(0xFFFFF7FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPast ? const Color(0xFFE0D8E8) : const Color(0xFFFFD1DC),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x082E1065),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPast ? const Color(0xFF9E8CE7) : const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPast ? 'COMPLETED' : 'UPCOMING',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE53935)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => ref.read(appointmentsProvider.notifier).removeAppointment(apt.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apt.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E1A47),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFF7A6A8D)),
                      const SizedBox(width: 6),
                      Text(
                        DateHelpers.formatFriendly(apt.dateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4A72),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF7A6A8D)),
                      const SizedBox(width: 4),
                      Text(
                        '${apt.dateTime.hour.toString().padLeft(2, '0')}:${apt.dateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4A72),
                        ),
                      ),
                    ],
                  ),
                  if (apt.clinicianName != null && apt.clinicianName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF7A6A8D)),
                        const SizedBox(width: 6),
                        Text(
                          'Dr: ${apt.clinicianName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5D4A72),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (apt.location != null && apt.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF7A6A8D)),
                        const SizedBox(width: 6),
                        Text(
                          apt.location!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF7A6A8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Note: ${apt.notes}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5D4A72),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildAddAppointmentForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Naya Appointment Schedule Karein',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E1A47),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isAddingNew = false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E8CE7))),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick selection chips
        const Text(
          'Checkup / Scan ki Qisam',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4A72)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickTypes.map((type) {
            final isSelected = _titleController.text == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: const Color(0xFFFCE4EC),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF4A3B60),
              ),
              onSelected: (val) {
                if (val) setState(() => _titleController.text = type);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Custom Title Field
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Appointment Title',
            hintText: 'e.g. 12-Week Ultrasound Scan',
            prefixIcon: const Icon(Icons.edit_calendar_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFFBF8FE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),

        // Date and Time Pickers
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0D8E8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateHelpers.formatFriendly(_selectedDate),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0D8E8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF9E8CE7)),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Doctor Name
        TextField(
          controller: _doctorController,
          decoration: InputDecoration(
            labelText: 'Doctor / Gynecologist Name',
            hintText: 'e.g. Dr. Ayesha Khan',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            filled: true,
            fillColor: const Color(0xFFFBF8FE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),

        // Hospital / Clinic Location
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Hospital / Clinic Location',
            hintText: 'e.g. Aga Khan / Shifa International',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
            filled: true,
            fillColor: const Color(0xFFFBF8FE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),

        // Special Notes
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Notes / Instructions',
            hintText: 'e.g. Fasting required, bring old blood reports',
            prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
            filled: true,
            fillColor: const Color(0xFFFBF8FE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text(
              'Appointment Save Karein ✨',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
