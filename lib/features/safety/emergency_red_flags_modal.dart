import 'package:flutter/material.dart';

class EmergencyRedFlagsModal extends StatelessWidget {
  const EmergencyRedFlagsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EmergencyRedFlagsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🚨', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Red Flags Guide',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC62828),
                          ),
                        ),
                        Text(
                          'Kab Foran Doctor Ya Hospital Jana Hai?',
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
          const Divider(height: 16, color: Color(0xFFF0EBF5)),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgent Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Agar niche di gayi "Red Flag" alamat mein se koi bhi mehsoos ho to ghar par intezar na karein, foran emergency room ya apni gynecologist se rabta karein.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Category 1: KHATARNAK (Emergency Red Flags)
                  const Text(
                    '🚨 Khatre Ki Alamat (Immediate Medical Attention):',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB71C1C),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Shadeed Heavy Bleeding 🩸',
                    description: 'Agar 1 ghante mein poora sanitary pad khoon se bhar jaye ya bare blood clots aane lagein.',
                    action: 'Foran emergency room jayein (Miscarriage ya placental issue ka khatra).',
                    isDanger: true,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Aik Taraf Ka Shadeed Pait Dard ⚡',
                    description: 'Pet ke kisi aik side par achanak shadeed tez dard (cramp se bohot mukhtalif dard).',
                    action: 'Foran doctor ke paas jayein (Ectopic pregnancy ka khatra ho sakta hai).',
                    isDanger: true,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Shadeed Sar Dard Aur Dhundla-Pan 👁️',
                    description: 'Aankhon ke aage chamak ya dhundla-pan, chehre aur hathon par achanak sujan (swelling).',
                    action: 'Blood pressure check karwayein (Preeclampsia ka ahem sign hai).',
                    isDanger: true,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Baby Ki Movement / Kicks Ka Kam Hona 👣',
                    description: '28 hafton ke baad agar baby ki regular halchal ya kicks achanak band ya bohot kam ho jayein.',
                    action: 'Khana kha kar 2 ghante check karein, agar movement na ho to foran clinic jayein.',
                    isDanger: true,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Tez Bukhar Aur Kapkapi 🌡️',
                    description: '100.4°F (38°C) se zyada bukhar jiske sath pait mein dard ya ajeeb discharge ho.',
                    action: 'Infection ka risk ho sakta hai, doctor se mashwara karein.',
                    isDanger: true,
                  ),
                  const SizedBox(height: 22),

                  // Category 2: NORMAL ALAMAT (Ghabrane ki baat nahi)
                  const Text(
                    '🟢 Normal Alamat (Yeh Aksar Aam Hoti Hain):',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Halki Cramps / Khichao 🌱',
                    description: 'Cycle ke shuru ya early pregnancy mein uterus expand hone ki wajah se mild khichao normal hai.',
                    action: 'Garam paani piyein aur halka aaram karein.',
                    isDanger: false,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Halka Brown Spotting (Implantation) 🌸',
                    description: 'Period se kuch din pehle halki si light brown ya pink spotting jo 1–2 din mein theek ho jaye.',
                    action: 'Yeh egg ke uterus mein judne ka aam nishan ho sakta hai.',
                    isDanger: false,
                  ),
                  const SizedBox(height: 10),

                  _buildSignCard(
                    title: 'Subah Ki Matli (Morning Sickness) 🍋',
                    description: 'Khaas tor par pehle trimester mein dil khrab hona ya ulti aana.',
                    action: 'Thoda thoda khayein, lemon water piyein aur hydration ka khayal rakhein.',
                    isDanger: false,
                  ),
                  const SizedBox(height: 20),

                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1A47),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text(
                          'Samajh Aa Gaya • Shukriya',
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

  Widget _buildSignCard({
    required String title,
    required String description,
    required String action,
    required bool isDanger,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xFFFFF5F5) : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDanger ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDanger ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF4A3B60),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDanger ? const Color(0xFFFFEBEE) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '👉 $action',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDanger ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
