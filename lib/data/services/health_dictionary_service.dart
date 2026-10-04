class HealthDictionaryEntry {
  final String term;
  final String romanPronunciation;
  final String simpleTitle;
  final String romanDefinition;
  final String practicalExample;
  final String icon;
  final String category; // 'cycle', 'fertility', 'pregnancy', 'general'

  const HealthDictionaryEntry({
    required this.term,
    required this.romanPronunciation,
    required this.simpleTitle,
    required this.romanDefinition,
    required this.practicalExample,
    required this.icon,
    this.category = 'general',
  });
}

class HealthDictionaryService {
  static const List<HealthDictionaryEntry> entries = [
    HealthDictionaryEntry(
      term: 'Fertile Window',
      romanPronunciation: 'Far-ta-il Vin-do',
      simpleTitle: 'Hamal / Bacha theharne ke din',
      romanDefinition:
          'Ye maheene ke wo 5 se 6 din hote hain jab agar aap husband ke sath intercourse (sex) karein to pregnancy hone ke sab se zyada chances hote hain.',
      practicalExample:
          'Agar aap baby plan kar rahi hain to in dino me sath rehna chahiye. Aur agar abhi baby nahi chahiye to in dino me ehtiyat karein.',
      icon: '🌿',
      category: 'fertility',
    ),
    HealthDictionaryEntry(
      term: 'Fertilization',
      romanPronunciation: 'Far-ti-lai-zay-shan',
      simpleTitle: 'Egg aur Sperm ka milna (Conception)',
      romanDefinition:
          'Jab mard ka sperm aur aurat ka egg aapas me mil jaate hain aur pet me bacha banna shuru hota hai, us amal ko fertilization kehte hain.',
      practicalExample:
          'Ovulation ke din ya us se 1-2 din pehle sex karne se fertilization aasani se ho jati hai.',
      icon: '✨',
      category: 'fertility',
    ),
    HealthDictionaryEntry(
      term: 'Ovulation',
      romanPronunciation: 'O-vyu-lay-shan',
      simpleTitle: 'Egg release hone ka din',
      romanDefinition:
          'Har maheene cycle ke darmiyan me ovary (baizah-daan) se ek mature egg bahar nikalta hai jo 24 ghante tak zinda rehta hai.',
      practicalExample:
          'Agar cycle 28 din ki hai, to aam tor par 14vein din ovulation hoti hai. Ye bacha conceive karne ka sab se main din hota hai.',
      icon: '🌸',
      category: 'fertility',
    ),
    HealthDictionaryEntry(
      term: 'Menstrual Phase / Period',
      romanPronunciation: 'Men-stru-al Phays / Haiz',
      simpleTitle: 'Mahwari / Period ke din',
      romanDefinition:
          'Body se har maheene 3 se 7 din normal bleeding hona. Ye is baat ka saboot hota hai ke is maheene pregnancy nahi hui aur uterus agle cycle ke liye saaf ho raha hai.',
      practicalExample:
          'In dino me garam paani piyein, rest karein aur hygiene ka khaas khayal rakhein.',
      icon: '🩸',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'Follicular Phase',
      romanPronunciation: 'Foh-li-kyu-lar Phays',
      simpleTitle: 'Period ke foran baad ka waqt',
      romanDefinition:
          'Period khatam hone ke agle din se lekar egg release hone tak ka waqt. Is waqt body me estrogen hormone barhta hai.',
      practicalExample:
          'In dino me energy achi mehsoos hoti hai, mood fresh rehta hai aur skin glow karti hai.',
      icon: '🌱',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'Luteal Phase',
      romanPronunciation: 'Lyoo-tee-al Phays',
      simpleTitle: 'Agla period aane se pehle ka waqt',
      romanDefinition:
          'Ovulation ke baad se agle period shuru hone tak ka 12 se 14 din ka waqt. Is waqt progesterone hormone zyada hota hai.',
      practicalExample:
          'Body aram mangti hai. Kuch larkiyon ko meetha khane ka dil chahta hai ya chidchida-pan mehsoos hota hai.',
      icon: '🌙',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'PMS (Premenstrual Syndrome)',
      romanPronunciation: 'P-M-S',
      simpleTitle: 'Period aane se pehle ki be-chaini',
      romanDefinition:
          'Periods aane se 2 se 5 din pehle hone wale jismaani aur jazbaati badlao, jaise mood swings, gussa aana, pet me dard ya phoolna.',
      practicalExample:
          'Agar bina wajah rona ya chidchida-pan aa raha ho to tension na lein, ye PMS ki wajah se normal hai.',
      icon: '⚡',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'Cervical Mucus',
      romanPronunciation: 'Sar-vi-kal Myu-kas',
      simpleTitle: 'Sharmgah ka natural discharge',
      romanDefinition:
          'Body ka qudrati discharge. Fertile dino me ye kachay anday ki safedi (stretchy & clear) jaisa patla aur chikna ho jata hai.',
      practicalExample:
          'Jab discharge slippery aur clear ho, samajh jayein ke aaj kal pregnant hone ka sab se acha waqt hai.',
      icon: '💧',
      category: 'fertility',
    ),
    HealthDictionaryEntry(
      term: 'BBT (Basal Body Temperature)',
      romanPronunciation: 'B-B-T',
      simpleTitle: 'Subah ka pehla body temperature',
      romanDefinition:
          'Bistar se uthne se pehle check kiya gaya body temperature. Ovulation ke foran baad ye halka sa (0.5°F) barh jata hai.',
      practicalExample:
          'Roz subah bina hiley thermometer se check kiya jata hai taake ovulation confirm ho sakey.',
      icon: '🌡️',
      category: 'fertility',
    ),
    HealthDictionaryEntry(
      term: 'EDD (Estimated Due Date)',
      romanPronunciation: 'E-D-D',
      simpleTitle: 'Bacha paida hone ki tareekh',
      romanDefinition:
          'Doctor ke mutabiq aapki delivery ki mutawaqqo tareekh jo aakhri period ki date (LMP) se hisaab laga kar nikaali jati hai.',
      practicalExample:
          'Aam tor par pregnancy 40 hafte (280 din) ki hoti hai, EDD us hisaab se delivery ka din batati hai.',
      icon: '👶',
      category: 'pregnancy',
    ),
    HealthDictionaryEntry(
      term: 'Trimester',
      romanPronunciation: 'Trai-mes-tar',
      simpleTitle: 'Pregnancy ke teen hissay',
      romanDefinition:
          '9 maheenon ki pregnancy ko 3 barabar hisson me baanta gaya hai: 1st Trimester (1-12 hafte), 2nd (13-26 hafte), 3rd (27-40 hafte).',
      practicalExample:
          'Pehle trimester me ulti ya jee ghabrana aam hai, doosre me baby ki movement shuru hoti hai.',
      icon: '🤰',
      category: 'pregnancy',
    ),
    HealthDictionaryEntry(
      term: 'Cramps',
      romanPronunciation: 'Kraymps',
      simpleTitle: 'Pet ya nalle me maror/dard',
      romanDefinition:
          'Period ke dino me uterus ke sukurne (contract hone) ki wajah se pet ke nichlay hissay ya kamar me hone wala dard.',
      practicalExample:
          'Garam paani ki botal se seknay aur chamomile chai peenay se dard me sukoon milta hai.',
      icon: '🔥',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'Spotting',
      romanPronunciation: 'Spaw-ting',
      simpleTitle: 'Halka sa khoon ka daagh lagna',
      romanDefinition:
          'Full period aane ke ilawa kabhi kabhi sirf halka sa pink ya brown daagh lagna. Ye ovulation ya pregnancy ki shuruat me bhi ho sakta hai.',
      practicalExample:
          'Agar expected period se pehle sirf ek do daagh lagein to ye implantation spotting ho sakti hai.',
      icon: '🩸',
      category: 'cycle',
    ),
    HealthDictionaryEntry(
      term: 'LMP (Last Menstrual Period)',
      romanPronunciation: 'L-M-P',
      simpleTitle: 'Aakhri period shuru hone ki tareekh',
      romanDefinition:
          'Aapko aakhri baar period jis din shuru hua tha (pehla din). Doctor hamesha pregnancy aur cycle ka hisaab isi date se lagate hain.',
      practicalExample:
          'Doctor ke paas jane par wo sab se pehle LMP hi poochte hain.',
      icon: '📅',
      category: 'general',
    ),
  ];

  static List<HealthDictionaryEntry> search(String query) {
    if (query.trim().isEmpty) return entries;
    final q = query.toLowerCase().trim();
    return entries.where((e) {
      return e.term.toLowerCase().contains(q) ||
          e.simpleTitle.toLowerCase().contains(q) ||
          e.romanDefinition.toLowerCase().contains(q);
    }).toList();
  }

  static HealthDictionaryEntry? findByTerm(String term) {
    final clean = term.toLowerCase().trim();
    try {
      return entries.firstWhere((e) =>
          e.term.toLowerCase().contains(clean) ||
          clean.contains(e.term.toLowerCase()));
    } catch (_) {
      return null;
    }
  }
}
