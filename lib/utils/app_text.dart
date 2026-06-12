import '../models/app_language.dart';
import '../models/challenge.dart';
import '../models/explorer_item.dart';
import '../models/level.dart';
import '../models/memory_item.dart';
import '../models/quest.dart';
import '../models/train_mode.dart';

class AppText {
  const AppText._();

  static String ui(String key, AppLanguage language) {
    return _uiText[key]?[language] ??
        _uiText[key]?[_fallbackLanguage(language)] ??
        _uiText[key]?[AppLanguage.english] ??
        key;
  }

  /// "{n} stars to Level {l}" localized with substitution.
  static String starsToLevel(int stars, int nextLevel, AppLanguage language) {
    return ui('starsToLevel', language)
        .replaceAll('{n}', '$stars')
        .replaceAll('{l}', '$nextLevel');
  }

  /// Localized level title (falls back to the level's English title).
  static String levelTitle(AppLevel level, AppLanguage language) {
    return _levelTitles[level.level]?[language] ??
        _levelTitles[level.level]?[_fallbackLanguage(language)] ??
        level.title;
  }

  /// Localized quest title (falls back to the quest's English title).
  static String questTitle(DailyQuest quest, AppLanguage language) {
    return _questTitles[quest.id]?[language] ??
        _questTitles[quest.id]?[_fallbackLanguage(language)] ??
        quest.title;
  }

  /// Localized quest description (falls back to the quest's English text).
  static String questDescription(DailyQuest quest, AppLanguage language) {
    return _questDescriptions[quest.id]?[language] ??
        _questDescriptions[quest.id]?[_fallbackLanguage(language)] ??
        quest.description;
  }

  static String challengeTitle(Challenge challenge, AppLanguage language) {
    return label(challenge.id, language, fallback: challenge.title);
  }

  static String challengeTarget(Challenge challenge, AppLanguage language) {
    return label(challenge.id, language, fallback: challenge.targetLabel);
  }

  static String memoryLabel(MemoryItem item, AppLanguage language) {
    return label(item.id, language, fallback: item.label);
  }

  static String explorerLabel(ExplorerItem item, AppLanguage language) {
    return label(item.id, language, fallback: item.fallbackLabel);
  }

  static String findExplorerPrompt(ExplorerItem item, AppLanguage language) {
    return _format(
      _promptTemplates['findExplorer']!,
      language,
      explorerLabel(item, language),
    );
  }

  static String trainTitle(TrainMode mode, AppLanguage language) {
    return switch (mode) {
      TrainMode.numbers => ui('numberTrain', language),
      TrainMode.letters => ui('letterTrain', language),
    };
  }

  static String trainPrompt(
    TrainMode mode,
    String value,
    AppLanguage language,
  ) {
    final templateKey = switch (mode) {
      TrainMode.numbers => 'numberTrainPrompt',
      TrainMode.letters => 'letterTrainPrompt',
    };
    return _format(_promptTemplates[templateKey]!, language, value);
  }

  static String trainSpeechValue(
    TrainMode mode,
    String value,
    AppLanguage language,
  ) {
    if (mode == TrainMode.numbers) {
      return _numberWords[value]?[language] ??
          _numberWords[value]?[_fallbackLanguage(language)] ??
          _numberWords[value]?[AppLanguage.english] ??
          value;
    }
    // For letters: pass lowercase so TTS says "a", "b" not "capital A"
    return value.toLowerCase();
  }

  static String label(
    String id,
    AppLanguage language, {
    required String fallback,
  }) {
    return _labels[id]?[language] ??
        _labels[id]?[_fallbackLanguage(language)] ??
        _labels[id]?[AppLanguage.english] ??
        fallback;
  }

  static AppLanguage _fallbackLanguage(AppLanguage language) {
    return switch (language) {
      AppLanguage.indonesian => AppLanguage.malay,
      _ => AppLanguage.english,
    };
  }

  static String prompt(Challenge challenge, AppLanguage language) {
    final target = challengeTarget(challenge, language);

    switch (challenge.mode) {
      case ChallengeMode.color:
        return _format(_promptTemplates['color']!, language, target);
      case ChallengeMode.shape:
        return _format(_promptTemplates['shape']!, language, target);
      case ChallengeMode.object:
        return _format(_promptTemplates['object']!, language, target);
      case ChallengeMode.sound:
        return ui('soundPrompt', language);
      case ChallengeMode.findExplorer:
        return ui('findExplorer', language);
      case ChallengeMode.numberTrain:
        return ui('numberTrain', language);
      case ChallengeMode.letterTrain:
        return ui('letterTrain', language);
      case ChallengeMode.memory:
        return ui('memoryGame', language);
      case ChallengeMode.puzzle:
        return ui('puzzleGame', language);
    }
  }

  static String categoryTitle(MemoryCategory category, AppLanguage language) {
    final key = switch (category) {
      MemoryCategory.animals => 'animals',
      MemoryCategory.shapes => 'shapes',
      MemoryCategory.colors => 'colors',
      MemoryCategory.jawi => 'jawiCategory',
    };
    return ui(key, language);
  }

  static String categorySubtitle(
    MemoryCategory category,
    AppLanguage language,
  ) {
    final key = switch (category) {
      MemoryCategory.animals => 'animalsSubtitle',
      MemoryCategory.shapes => 'shapesSubtitle',
      MemoryCategory.colors => 'colorsSubtitle',
      MemoryCategory.jawi => 'jawiCategorySubtitle',
    };
    return ui(key, language);
  }

  static String _format(
    Map<AppLanguage, String> templates,
    AppLanguage language,
    String target,
  ) {
    final template =
        templates[language] ??
        templates[_fallbackLanguage(language)] ??
        templates[AppLanguage.english] ??
        '{target}';
    return template.replaceAll('{target}', target);
  }
}

const _uiText = <String, Map<AppLanguage, String>>{
  'appName': {
    AppLanguage.english: 'Bijak Belajar',
    AppLanguage.malay: 'Bijak Belajar',
    AppLanguage.mandarin: 'Bijak Belajar',
    AppLanguage.tamil: 'Bijak Belajar',
  },
  'homeQuestion': {
    AppLanguage.english: 'What can you learn today?',
    AppLanguage.malay: 'Apa yang boleh kamu belajar hari ini?',
    AppLanguage.mandarin: '今天你能学到什么？',
    AppLanguage.tamil: 'இன்று நீ என்ன கற்கலாம்?',
  },
  'findExplorer': {
    AppLanguage.english: 'Find Explorer',
    AppLanguage.malay: 'Penjelajah Cari',
    AppLanguage.mandarin: '寻找探险',
    AppLanguage.tamil: 'கண்டுபிடி பயணம்',
  },
  'findExplorerSubtitle': {
    AppLanguage.english: 'Find real objects around you',
    AppLanguage.malay: 'Cari objek sebenar di sekeliling kamu',
    AppLanguage.mandarin: '在身边寻找真实物品',
    AppLanguage.tamil: 'உன்னைச் சுற்றியுள்ள உண்மையான பொருட்களை தேடு',
  },
  'numberTrain': {
    AppLanguage.english: 'Number Train',
    AppLanguage.malay: 'Kereta Api Nombor',
    AppLanguage.mandarin: '数字火车',
    AppLanguage.tamil: 'எண் ரயில்',
  },
  'letterTrain': {
    AppLanguage.english: 'Letter Train',
    AppLanguage.malay: 'Kereta Api Huruf',
    AppLanguage.mandarin: '字母火车',
    AppLanguage.tamil: 'எழுத்து ரயில்',
  },
  'numberTrainSubtitle': {
    AppLanguage.english: 'Sort number cars in order',
    AppLanguage.malay: 'Susun gerabak nombor mengikut turutan',
    AppLanguage.mandarin: '按顺序排列数字车厢',
    AppLanguage.tamil: 'எண் வண்டிகளை வரிசைப்படுத்து',
  },
  'letterTrainSubtitle': {
    AppLanguage.english: 'Sort letter cars from A to E',
    AppLanguage.malay: 'Susun gerabak huruf dari A hingga E',
    AppLanguage.mandarin: '按 A 到 E 排列字母车厢',
    AppLanguage.tamil: 'A முதல் E வரை எழுத்து வண்டிகளை வரிசைப்படுத்து',
  },
  'colorHunt': {
    AppLanguage.english: 'Color Hunt',
    AppLanguage.malay: 'Cari Warna',
    AppLanguage.mandarin: '找颜色',
    AppLanguage.tamil: 'நிற வேட்டை',
  },
  'shapeHunt': {
    AppLanguage.english: 'Shape Hunt',
    AppLanguage.malay: 'Cari Bentuk',
    AppLanguage.mandarin: '找形状',
    AppLanguage.tamil: 'வடிவ வேட்டை',
  },
  'objectHunt': {
    AppLanguage.english: 'Object Hunt',
    AppLanguage.malay: 'Cari Objek',
    AppLanguage.mandarin: '找物品',
    AppLanguage.tamil: 'பொருள் வேட்டை',
  },
  'soundGuess': {
    AppLanguage.english: 'Sound Guess',
    AppLanguage.malay: 'Teka Bunyi',
    AppLanguage.mandarin: '猜声音',
    AppLanguage.tamil: 'ஒலி கணிப்பு',
  },
  'memoryGame': {
    AppLanguage.english: 'Memory Game',
    AppLanguage.malay: 'Permainan Memori',
    AppLanguage.mandarin: '记忆游戏',
    AppLanguage.tamil: 'நினைவுப் விளையாட்டு',
  },
  'puzzleGame': {
    AppLanguage.english: 'Puzzle Game',
    AppLanguage.malay: 'Permainan Teka-Teki',
    AppLanguage.mandarin: '拼图游戏',
    AppLanguage.tamil: 'புதிர் விளையாட்டு',
  },
  'colorSubtitle': {
    AppLanguage.english: 'Find things by color',
    AppLanguage.malay: 'Cari benda mengikut warna',
    AppLanguage.mandarin: '按颜色找东西',
    AppLanguage.tamil: 'நிறப்படி பொருட்களை கண்டுபிடி',
  },
  'shapeSubtitle': {
    AppLanguage.english: 'Look for circles and more',
    AppLanguage.malay: 'Cari bulatan dan bentuk lain',
    AppLanguage.mandarin: '寻找圆形和其他形状',
    AppLanguage.tamil: 'வட்டம் மற்றும் பிற வடிவங்களை தேடு',
  },
  'objectSubtitle': {
    AppLanguage.english: 'Find everyday things',
    AppLanguage.malay: 'Cari benda harian',
    AppLanguage.mandarin: '寻找日常物品',
    AppLanguage.tamil: 'தினசரி பொருட்களை தேடு',
  },
  'soundSubtitle': {
    AppLanguage.english: 'Listen and choose',
    AppLanguage.malay: 'Dengar dan pilih',
    AppLanguage.mandarin: '听一听再选择',
    AppLanguage.tamil: 'கேட்டு தேர்வு செய்',
  },
  'memorySubtitle': {
    AppLanguage.english: 'Match animals, shapes, and colors',
    AppLanguage.malay: 'Padankan haiwan, bentuk, dan warna',
    AppLanguage.mandarin: '配对动物、形状和颜色',
    AppLanguage.tamil: 'விலங்குகள், வடிவங்கள், நிறங்களை பொருத்து',
  },
  'foundIt': {
    AppLanguage.english: 'Found It',
    AppLanguage.malay: 'Sudah Jumpa',
    AppLanguage.mandarin: '找到了',
    AppLanguage.tamil: 'கண்டுபிடித்தேன்',
  },
  'tryAnother': {
    AppLanguage.english: 'Try Another',
    AppLanguage.malay: 'Cuba Lagi',
    AppLanguage.mandarin: '换一个',
    AppLanguage.tamil: 'மற்றொன்று முயற்சி',
  },
  'newMission': {
    AppLanguage.english: 'New Mission',
    AppLanguage.malay: 'Misi Baharu',
    AppLanguage.mandarin: '新任务',
    AppLanguage.tamil: 'புதிய பணி',
  },
  'hearWord': {
    AppLanguage.english: 'Hear Word',
    AppLanguage.malay: 'Dengar Perkataan',
    AppLanguage.mandarin: '听词语',
    AppLanguage.tamil: 'சொல்லைக் கேள்',
  },
  'soundPrompt': {
    AppLanguage.english: 'Which sound did you hear?',
    AppLanguage.malay: 'Bunyi apa yang kamu dengar?',
    AppLanguage.mandarin: '你听到了什么声音？',
    AppLanguage.tamil: 'நீ எந்த ஒலியை கேட்டாய்?',
  },
  'playSound': {
    AppLanguage.english: 'Play Sound',
    AppLanguage.malay: 'Mainkan Bunyi',
    AppLanguage.mandarin: '播放声音',
    AppLanguage.tamil: 'ஒலியை இயக்கு',
  },
  'listenClosely': {
    AppLanguage.english: 'Listen closely',
    AppLanguage.malay: 'Dengar baik-baik',
    AppLanguage.mandarin: '仔细听',
    AppLanguage.tamil: 'கவனமாக கேள்',
  },
  'pickMemoryGame': {
    AppLanguage.english: 'Pick a memory game',
    AppLanguage.malay: 'Pilih permainan memori',
    AppLanguage.mandarin: '选择记忆游戏',
    AppLanguage.tamil: 'நினைவுப் விளையாட்டை தேர்வு செய்',
  },
  'animals': {
    AppLanguage.english: 'Animals',
    AppLanguage.malay: 'Haiwan',
    AppLanguage.mandarin: '动物',
    AppLanguage.tamil: 'விலங்குகள்',
  },
  'shapes': {
    AppLanguage.english: 'Shapes',
    AppLanguage.malay: 'Bentuk',
    AppLanguage.mandarin: '形状',
    AppLanguage.tamil: 'வடிவங்கள்',
  },
  'colors': {
    AppLanguage.english: 'Colors',
    AppLanguage.malay: 'Warna',
    AppLanguage.mandarin: '颜色',
    AppLanguage.tamil: 'நிறங்கள்',
  },
  'jawiCategory': {
    AppLanguage.english: 'Jawi Letters',
    AppLanguage.malay: 'Huruf Jawi',
    AppLanguage.mandarin: '爪夷字母',
    AppLanguage.tamil: 'ஜாவி எழுத்துகள்',
  },
  'jawiCategorySubtitle': {
    AppLanguage.english: 'Match Jawi letter pairs',
    AppLanguage.malay: 'Padankan pasangan huruf Jawi',
    AppLanguage.mandarin: '配对爪夷字母',
    AppLanguage.tamil: 'ஜாவி எழுத்து ஜோடிகளைப் பொருத்துங்கள்',
  },
  'animalsSubtitle': {
    AppLanguage.english: 'Match animal pairs',
    AppLanguage.malay: 'Padankan pasangan haiwan',
    AppLanguage.mandarin: '配对动物',
    AppLanguage.tamil: 'விலங்கு ஜோடிகளை பொருத்து',
  },
  'shapesSubtitle': {
    AppLanguage.english: 'Match shape pairs',
    AppLanguage.malay: 'Padankan pasangan bentuk',
    AppLanguage.mandarin: '配对形状',
    AppLanguage.tamil: 'வடிவ ஜோடிகளை பொருத்து',
  },
  'colorsSubtitle': {
    AppLanguage.english: 'Match color pairs',
    AppLanguage.malay: 'Padankan pasangan warna',
    AppLanguage.mandarin: '配对颜色',
    AppLanguage.tamil: 'நிற ஜோடிகளை பொருத்து',
  },
  'lookCarefully': {
    AppLanguage.english: 'Look carefully',
    AppLanguage.malay: 'Lihat baik-baik',
    AppLanguage.mandarin: '仔细看',
    AppLanguage.tamil: 'கவனமாக பார்',
  },
  'findPairs': {
    AppLanguage.english: 'Find the pairs',
    AppLanguage.malay: 'Cari pasangan',
    AppLanguage.mandarin: '找配对',
    AppLanguage.tamil: 'ஜோடிகளை கண்டுபிடி',
  },
  'pairs': {
    AppLanguage.english: 'pairs',
    AppLanguage.malay: 'pasangan',
    AppLanguage.mandarin: '对',
    AppLanguage.tamil: 'ஜோடிகள்',
  },
  'hiddenCard': {
    AppLanguage.english: 'Hidden card',
    AppLanguage.malay: 'Kad tersembunyi',
    AppLanguage.mandarin: '隐藏的卡片',
    AppLanguage.tamil: 'மறைந்த அட்டை',
  },
  'language': {
    AppLanguage.english: 'Language',
    AppLanguage.malay: 'Bahasa',
    AppLanguage.mandarin: '语言',
    AppLanguage.tamil: 'மொழி',
  },
  'selectLanguage': {
    AppLanguage.english: 'Select language',
    AppLanguage.malay: 'Pilih bahasa',
    AppLanguage.mandarin: '选择语言',
    AppLanguage.tamil: 'மொழியை தேர்வு செய்',
  },
  'parentSettings': {
    AppLanguage.english: 'Parent Settings',
    AppLanguage.malay: 'Tetapan Ibu Bapa',
    AppLanguage.mandarin: '家长设置',
    AppLanguage.tamil: 'பெற்றோர் அமைப்புகள்',
  },
  'progress': {
    AppLanguage.english: 'Progress',
    AppLanguage.malay: 'Kemajuan',
    AppLanguage.mandarin: '进度',
    AppLanguage.tamil: 'முன்னேற்றம்',
  },
  'badges': {
    AppLanguage.english: 'Badges',
    AppLanguage.malay: 'Lencana',
    AppLanguage.mandarin: '徽章',
    AppLanguage.tamil: 'பதக்கங்கள்',
  },
  'earnedStar': {
    AppLanguage.english: 'You earned a star!',
    AppLanguage.malay: 'Kamu dapat satu bintang!',
    AppLanguage.mandarin: '你获得了一颗星！',
    AppLanguage.tamil: 'நீ ஒரு நட்சத்திரம் பெற்றாய்!',
  },
  'newBadge': {
    AppLanguage.english: 'New badge!',
    AppLanguage.malay: 'Lencana baharu!',
    AppLanguage.mandarin: '新徽章！',
    AppLanguage.tamil: 'புதிய பதக்கம்!',
  },
  'greatWorkIn': {
    AppLanguage.english: 'Great work in',
    AppLanguage.malay: 'Bagus dalam',
    AppLanguage.mandarin: '做得很好：',
    AppLanguage.tamil: 'சிறப்பாக செய்தாய்:',
  },
  'playAgain': {
    AppLanguage.english: 'Play Again',
    AppLanguage.malay: 'Main Lagi',
    AppLanguage.mandarin: '再玩一次',
    AppLanguage.tamil: 'மீண்டும் விளையாடு',
  },
  'home': {
    AppLanguage.english: 'Home',
    AppLanguage.malay: 'Laman utama',
    AppLanguage.mandarin: '首页',
    AppLanguage.tamil: 'முகப்பு',
  },
  'trainComplete': {
    AppLanguage.english: 'Train complete!',
    AppLanguage.malay: 'Kereta api lengkap!',
    AppLanguage.mandarin: '火车完成了！',
    AppLanguage.tamil: 'ரயில் முடிந்தது!',
  },
  'tryNextCar': {
    AppLanguage.english: 'Try the next car in order.',
    AppLanguage.malay: 'Cuba gerabak seterusnya mengikut turutan.',
    AppLanguage.mandarin: '试试下一个正确的车厢。',
    AppLanguage.tamil: 'வரிசையில் அடுத்த வண்டியை முயற்சி செய்.',
  },
  'sound': {
    AppLanguage.english: 'Sound',
    AppLanguage.malay: 'Bunyi',
    AppLanguage.mandarin: '声音',
    AppLanguage.tamil: 'ஒலி',
  },
  'voiceInstruction': {
    AppLanguage.english: 'Voice instruction',
    AppLanguage.malay: 'Arahan suara',
    AppLanguage.mandarin: '语音提示',
    AppLanguage.tamil: 'குரல் வழிகாட்டல்',
  },
  'voiceSubtitle': {
    AppLanguage.english: 'Pronounce prompts and words',
    AppLanguage.malay: 'Sebut arahan dan perkataan',
    AppLanguage.mandarin: '朗读提示和词语',
    AppLanguage.tamil: 'வழிகாட்டல்களையும் சொற்களையும் உச்சரி',
    AppLanguage.indonesian: 'Ucapkan petunjuk dan kata',
  },
  // ── Home screen UI (added for full multi-language coverage) ───────────────
  'todaysQuests': {
    AppLanguage.english: "TODAY'S QUESTS",
    AppLanguage.malay: 'MISI HARI INI',
    AppLanguage.mandarin: '今日任务',
    AppLanguage.tamil: 'இன்றைய பணிகள்',
    AppLanguage.indonesian: 'MISI HARI INI',
  },
  'learn': {
    AppLanguage.english: 'LEARN',
    AppLanguage.malay: 'BELAJAR',
    AppLanguage.mandarin: '学习',
    AppLanguage.tamil: 'கற்க',
    AppLanguage.indonesian: 'BELAJAR',
  },
  'games': {
    AppLanguage.english: 'GAMES',
    AppLanguage.malay: 'PERMAINAN',
    AppLanguage.mandarin: '游戏',
    AppLanguage.tamil: 'விளையாட்டு',
    AppLanguage.indonesian: 'PERMAINAN',
  },
  'numbers': {
    AppLanguage.english: 'Numbers',
    AppLanguage.malay: 'Nombor',
    AppLanguage.mandarin: '数字',
    AppLanguage.tamil: 'எண்கள்',
    AppLanguage.indonesian: 'Angka',
  },
  'letters': {
    AppLanguage.english: 'Letters',
    AppLanguage.malay: 'Huruf',
    AppLanguage.mandarin: '字母',
    AppLanguage.tamil: 'எழுத்துக்கள்',
    AppLanguage.indonesian: 'Huruf',
  },
  'jawi': {
    AppLanguage.english: 'Jawi',
    AppLanguage.malay: 'Jawi',
    AppLanguage.mandarin: '爪夷文',
    AppLanguage.tamil: 'ஜாவி',
    AppLanguage.indonesian: 'Jawi',
  },
  'letters28': {
    AppLanguage.english: '28 Letters',
    AppLanguage.malay: '28 Huruf',
    AppLanguage.mandarin: '28 个字母',
    AppLanguage.tamil: '28 எழுத்துக்கள்',
    AppLanguage.indonesian: '28 Huruf',
  },
  'bodyParts': {
    AppLanguage.english: 'Body Parts',
    AppLanguage.malay: 'Anggota Badan',
    AppLanguage.mandarin: '身体部位',
    AppLanguage.tamil: 'உடல் உறுப்புகள்',
    AppLanguage.indonesian: 'Anggota Tubuh',
  },
  'bodyPartsTwoLine': {
    AppLanguage.english: 'Body\nParts',
    AppLanguage.malay: 'Anggota\nBadan',
    AppLanguage.mandarin: '身体\n部位',
    AppLanguage.tamil: 'உடல்\nஉறுப்புகள்',
    AppLanguage.indonesian: 'Anggota\nTubuh',
  },
  'parts14': {
    AppLanguage.english: '14 Parts',
    AppLanguage.malay: '14 Bahagian',
    AppLanguage.mandarin: '14 个部位',
    AppLanguage.tamil: '14 உறுப்புகள்',
    AppLanguage.indonesian: '14 Bagian',
  },
  'math': {
    AppLanguage.english: 'Math',
    AppLanguage.malay: 'Matematik',
    AppLanguage.mandarin: '数学',
    AppLanguage.tamil: 'கணிதம்',
    AppLanguage.indonesian: 'Matematika',
  },
  'addSubtract': {
    AppLanguage.english: 'Add & Subtract',
    AppLanguage.malay: 'Tambah & Tolak',
    AppLanguage.mandarin: '加法和减法',
    AppLanguage.tamil: 'கூட்டல் & கழித்தல்',
    AppLanguage.indonesian: 'Tambah & Kurang',
  },
  'colour': {
    AppLanguage.english: 'Colour',
    AppLanguage.malay: 'Mewarna',
    AppLanguage.mandarin: '涂色',
    AppLanguage.tamil: 'வண்ணம்',
    AppLanguage.indonesian: 'Mewarnai',
  },
  'drawPaint': {
    AppLanguage.english: 'Draw & Paint',
    AppLanguage.malay: 'Lukis & Warna',
    AppLanguage.mandarin: '画画和涂色',
    AppLanguage.tamil: 'வரைதல் & வண்ணம்',
    AppLanguage.indonesian: 'Menggambar & Mewarnai',
  },
  'allGames': {
    AppLanguage.english: 'All Games & Activities',
    AppLanguage.malay: 'Semua Permainan',
    AppLanguage.mandarin: '所有游戏与活动',
    AppLanguage.tamil: 'அனைத்து விளையாட்டுகள் & செயல்கள்',
    AppLanguage.indonesian: 'Semua Game & Aktivitas',
  },
  'allGamesSub': {
    AppLanguage.english: 'Memory, Puzzle, Number Train & Letter Train',
    AppLanguage.malay: 'Memori, Teka-Teki, Tren Nombor & Huruf',
    AppLanguage.mandarin: '记忆、拼图、数字火车和字母火车',
    AppLanguage.tamil: 'நினைவு, புதிர், எண் ரயில் & எழுத்து ரயில்',
    AppLanguage.indonesian: 'Memori, Puzzle, Kereta Angka & Huruf',
  },
  'homeGreeting': {
    AppLanguage.english: '👋 Hi, smart learner!',
    AppLanguage.malay: '👋 Hai, anak bijak!',
    AppLanguage.mandarin: '👋 你好，聪明的小朋友！',
    AppLanguage.tamil: '👋 வணக்கம், புத்திசாலி குழந்தை!',
    AppLanguage.indonesian: '👋 Hai, anak pintar!',
  },
  'levelWord': {
    AppLanguage.english: 'Level',
    AppLanguage.malay: 'Tahap',
    AppLanguage.mandarin: '等级',
    AppLanguage.tamil: 'நிலை',
    AppLanguage.indonesian: 'Level',
  },
  'starsToLevel': {
    AppLanguage.english: '{n} stars to Level {l}',
    AppLanguage.malay: '{n} bintang ke Tahap {l}',
    AppLanguage.mandarin: '还差 {n} 颗星到等级 {l}',
    AppLanguage.tamil: 'நிலை {l}க்கு {n} நட்சத்திரங்கள்',
    AppLanguage.indonesian: '{n} bintang ke Level {l}',
  },
  'continueLearning': {
    AppLanguage.english: '▶ Continue Learning',
    AppLanguage.malay: '▶ Teruskan Belajar',
    AppLanguage.mandarin: '▶ 继续学习',
    AppLanguage.tamil: '▶ தொடர்ந்து கற்க',
    AppLanguage.indonesian: '▶ Lanjut Belajar',
  },
  'navHome': {
    AppLanguage.english: 'Home',
    AppLanguage.malay: 'Utama',
    AppLanguage.mandarin: '首页',
    AppLanguage.tamil: 'முகப்பு',
    AppLanguage.indonesian: 'Beranda',
  },
  'navSyllabus': {
    AppLanguage.english: 'Syllabus',
    AppLanguage.malay: 'Sukatan',
    AppLanguage.mandarin: '课程',
    AppLanguage.tamil: 'பாடத்திட்டம்',
    AppLanguage.indonesian: 'Silabus',
  },
  'navProgress': {
    AppLanguage.english: 'Progress',
    AppLanguage.malay: 'Kemajuan',
    AppLanguage.mandarin: '进度',
    AppLanguage.tamil: 'முன்னேற்றம்',
    AppLanguage.indonesian: 'Kemajuan',
  },
  'navVoice': {
    AppLanguage.english: 'Voice',
    AppLanguage.malay: 'Suara',
    AppLanguage.mandarin: '语音',
    AppLanguage.tamil: 'குரல்',
    AppLanguage.indonesian: 'Suara',
  },
  'navSettings': {
    AppLanguage.english: 'Settings',
    AppLanguage.malay: 'Tetapan',
    AppLanguage.mandarin: '设置',
    AppLanguage.tamil: 'அமைப்புகள்',
    AppLanguage.indonesian: 'Pengaturan',
  },
};

const _promptTemplates = <String, Map<AppLanguage, String>>{
  'color': {
    AppLanguage.english: 'Find something {target}.',
    AppLanguage.malay: 'Cari sesuatu berwarna {target}.',
    AppLanguage.mandarin: '找一个{target}的东西。',
    AppLanguage.tamil: '{target} நிறமுள்ள பொருளைக் கண்டுபிடி.',
  },
  'shape': {
    AppLanguage.english: 'Find a {target}.',
    AppLanguage.malay: 'Cari bentuk {target}.',
    AppLanguage.mandarin: '找一个{target}。',
    AppLanguage.tamil: '{target} வடிவத்தை கண்டுபிடி.',
  },
  'object': {
    AppLanguage.english: 'Find a {target}.',
    AppLanguage.malay: 'Cari {target}.',
    AppLanguage.mandarin: '找一个{target}。',
    AppLanguage.tamil: '{target} கண்டுபிடி.',
  },
  'findExplorer': {
    AppLanguage.english: 'Explorer mission: find a {target}.',
    AppLanguage.malay: 'Misi penjelajah: cari {target}.',
    AppLanguage.mandarin: '探险任务：找一个{target}。',
    AppLanguage.tamil: 'பயண பணி: {target} கண்டுபிடி.',
  },
  'numberTrainPrompt': {
    AppLanguage.english: 'Tap number {target}.',
    AppLanguage.malay: 'Tekan nombor {target}.',
    AppLanguage.mandarin: '点击数字 {target}。',
    AppLanguage.tamil: '{target} எண்ணைத் தட்டு.',
  },
  'letterTrainPrompt': {
    AppLanguage.english: 'Tap letter {target}.',
    AppLanguage.malay: 'Tekan huruf {target}.',
    AppLanguage.mandarin: '点击字母 {target}。',
    AppLanguage.tamil: '{target} எழுத்தைத் தட்டு.',
  },
};

const _numberWords = <String, Map<AppLanguage, String>>{
  '1': {
    AppLanguage.english: 'one',
    AppLanguage.malay: 'satu',
    AppLanguage.mandarin: '一',
    AppLanguage.tamil: 'ஒன்று',
  },
  '2': {
    AppLanguage.english: 'two',
    AppLanguage.malay: 'dua',
    AppLanguage.mandarin: '二',
    AppLanguage.tamil: 'இரண்டு',
  },
  '3': {
    AppLanguage.english: 'three',
    AppLanguage.malay: 'tiga',
    AppLanguage.mandarin: '三',
    AppLanguage.tamil: 'மூன்று',
  },
  '4': {
    AppLanguage.english: 'four',
    AppLanguage.malay: 'empat',
    AppLanguage.mandarin: '四',
    AppLanguage.tamil: 'நான்கு',
  },
  '5': {
    AppLanguage.english: 'five',
    AppLanguage.malay: 'lima',
    AppLanguage.mandarin: '五',
    AppLanguage.tamil: 'ஐந்து',
  },
  '6': {
    AppLanguage.english: 'six',
    AppLanguage.malay: 'enam',
    AppLanguage.mandarin: '六',
    AppLanguage.tamil: 'ஆறு',
  },
  '7': {
    AppLanguage.english: 'seven',
    AppLanguage.malay: 'tujuh',
    AppLanguage.mandarin: '七',
    AppLanguage.tamil: 'ஏழு',
  },
  '8': {
    AppLanguage.english: 'eight',
    AppLanguage.malay: 'lapan',
    AppLanguage.mandarin: '八',
    AppLanguage.tamil: 'எட்டு',
  },
  '9': {
    AppLanguage.english: 'nine',
    AppLanguage.malay: 'sembilan',
    AppLanguage.mandarin: '九',
    AppLanguage.tamil: 'ஒன்பது',
  },
  '10': {
    AppLanguage.english: 'ten',
    AppLanguage.malay: 'sepuluh',
    AppLanguage.mandarin: '十',
    AppLanguage.tamil: 'பத்து',
  },
  '11': {
    AppLanguage.english: 'eleven',
    AppLanguage.malay: 'sebelas',
    AppLanguage.mandarin: '十一',
    AppLanguage.tamil: 'பதினொன்று',
  },
  '12': {
    AppLanguage.english: 'twelve',
    AppLanguage.malay: 'dua belas',
    AppLanguage.mandarin: '十二',
    AppLanguage.tamil: 'பன்னிரண்டு',
  },
  '13': {
    AppLanguage.english: 'thirteen',
    AppLanguage.malay: 'tiga belas',
    AppLanguage.mandarin: '十三',
    AppLanguage.tamil: 'பதின்மூன்று',
  },
  '14': {
    AppLanguage.english: 'fourteen',
    AppLanguage.malay: 'empat belas',
    AppLanguage.mandarin: '十四',
    AppLanguage.tamil: 'பதினான்கு',
  },
  '15': {
    AppLanguage.english: 'fifteen',
    AppLanguage.malay: 'lima belas',
    AppLanguage.mandarin: '十五',
    AppLanguage.tamil: 'பதினைந்து',
  },
  '16': {
    AppLanguage.english: 'sixteen',
    AppLanguage.malay: 'enam belas',
    AppLanguage.mandarin: '十六',
    AppLanguage.tamil: 'பதினாறு',
  },
  '17': {
    AppLanguage.english: 'seventeen',
    AppLanguage.malay: 'tujuh belas',
    AppLanguage.mandarin: '十七',
    AppLanguage.tamil: 'பதினேழு',
  },
  '18': {
    AppLanguage.english: 'eighteen',
    AppLanguage.malay: 'lapan belas',
    AppLanguage.mandarin: '十八',
    AppLanguage.tamil: 'பதினெட்டு',
  },
  '19': {
    AppLanguage.english: 'nineteen',
    AppLanguage.malay: 'sembilan belas',
    AppLanguage.mandarin: '十九',
    AppLanguage.tamil: 'பத்தொன்பது',
  },
  '20': {
    AppLanguage.english: 'twenty',
    AppLanguage.malay: 'dua puluh',
    AppLanguage.mandarin: '二十',
    AppLanguage.tamil: 'இருபது',
  },
  '21': {
    AppLanguage.english: 'twenty one',
    AppLanguage.malay: 'dua puluh satu',
    AppLanguage.mandarin: '二十一',
    AppLanguage.tamil: 'இருபத்தொன்று',
  },
  '22': {
    AppLanguage.english: 'twenty two',
    AppLanguage.malay: 'dua puluh dua',
    AppLanguage.mandarin: '二十二',
    AppLanguage.tamil: 'இருபத்திரண்டு',
  },
  '23': {
    AppLanguage.english: 'twenty three',
    AppLanguage.malay: 'dua puluh tiga',
    AppLanguage.mandarin: '二十三',
    AppLanguage.tamil: 'இருபத்துமூன்று',
  },
  '24': {
    AppLanguage.english: 'twenty four',
    AppLanguage.malay: 'dua puluh empat',
    AppLanguage.mandarin: '二十四',
    AppLanguage.tamil: 'இருபத்துநான்கு',
  },
  '25': {
    AppLanguage.english: 'twenty five',
    AppLanguage.malay: 'dua puluh lima',
    AppLanguage.mandarin: '二十五',
    AppLanguage.tamil: 'இருபத்தைந்து',
  },
  '26': {
    AppLanguage.english: 'twenty six',
    AppLanguage.malay: 'dua puluh enam',
    AppLanguage.mandarin: '二十六',
    AppLanguage.tamil: 'இருபத்தாறு',
  },
  '27': {
    AppLanguage.english: 'twenty seven',
    AppLanguage.malay: 'dua puluh tujuh',
    AppLanguage.mandarin: '二十七',
    AppLanguage.tamil: 'இருபத்தேழு',
  },
  '28': {
    AppLanguage.english: 'twenty eight',
    AppLanguage.malay: 'dua puluh lapan',
    AppLanguage.mandarin: '二十八',
    AppLanguage.tamil: 'இருபத்தெட்டு',
  },
  '29': {
    AppLanguage.english: 'twenty nine',
    AppLanguage.malay: 'dua puluh sembilan',
    AppLanguage.mandarin: '二十九',
    AppLanguage.tamil: 'இருபத்தொன்பது',
  },
  '30': {
    AppLanguage.english: 'thirty',
    AppLanguage.malay: 'tiga puluh',
    AppLanguage.mandarin: '三十',
    AppLanguage.tamil: 'முப்பது',
  },
  '31': {
    AppLanguage.english: 'thirty one',
    AppLanguage.malay: 'tiga puluh satu',
    AppLanguage.mandarin: '三十一',
    AppLanguage.tamil: 'முப்பத்தொன்று',
  },
  '32': {
    AppLanguage.english: 'thirty two',
    AppLanguage.malay: 'tiga puluh dua',
    AppLanguage.mandarin: '三十二',
    AppLanguage.tamil: 'முப்பத்திரண்டு',
  },
  '33': {
    AppLanguage.english: 'thirty three',
    AppLanguage.malay: 'tiga puluh tiga',
    AppLanguage.mandarin: '三十三',
    AppLanguage.tamil: 'முப்பத்துமூன்று',
  },
  '34': {
    AppLanguage.english: 'thirty four',
    AppLanguage.malay: 'tiga puluh empat',
    AppLanguage.mandarin: '三十四',
    AppLanguage.tamil: 'முப்பத்துநான்கு',
  },
  '35': {
    AppLanguage.english: 'thirty five',
    AppLanguage.malay: 'tiga puluh lima',
    AppLanguage.mandarin: '三十五',
    AppLanguage.tamil: 'முப்பத்தைந்து',
  },
  '36': {
    AppLanguage.english: 'thirty six',
    AppLanguage.malay: 'tiga puluh enam',
    AppLanguage.mandarin: '三十六',
    AppLanguage.tamil: 'முப்பத்தாறு',
  },
  '37': {
    AppLanguage.english: 'thirty seven',
    AppLanguage.malay: 'tiga puluh tujuh',
    AppLanguage.mandarin: '三十七',
    AppLanguage.tamil: 'முப்பத்தேழு',
  },
  '38': {
    AppLanguage.english: 'thirty eight',
    AppLanguage.malay: 'tiga puluh lapan',
    AppLanguage.mandarin: '三十八',
    AppLanguage.tamil: 'முப்பத்தெட்டு',
  },
  '39': {
    AppLanguage.english: 'thirty nine',
    AppLanguage.malay: 'tiga puluh sembilan',
    AppLanguage.mandarin: '三十九',
    AppLanguage.tamil: 'முப்பத்தொன்பது',
  },
  '40': {
    AppLanguage.english: 'forty',
    AppLanguage.malay: 'empat puluh',
    AppLanguage.mandarin: '四十',
    AppLanguage.tamil: 'நாற்பது',
  },
  '41': {
    AppLanguage.english: 'forty one',
    AppLanguage.malay: 'empat puluh satu',
    AppLanguage.mandarin: '四十一',
    AppLanguage.tamil: 'நாற்பத்தொன்று',
  },
  '42': {
    AppLanguage.english: 'forty two',
    AppLanguage.malay: 'empat puluh dua',
    AppLanguage.mandarin: '四十二',
    AppLanguage.tamil: 'நாற்பத்திரண்டு',
  },
  '43': {
    AppLanguage.english: 'forty three',
    AppLanguage.malay: 'empat puluh tiga',
    AppLanguage.mandarin: '四十三',
    AppLanguage.tamil: 'நாற்பத்துமூன்று',
  },
  '44': {
    AppLanguage.english: 'forty four',
    AppLanguage.malay: 'empat puluh empat',
    AppLanguage.mandarin: '四十四',
    AppLanguage.tamil: 'நாற்பத்துநான்கு',
  },
  '45': {
    AppLanguage.english: 'forty five',
    AppLanguage.malay: 'empat puluh lima',
    AppLanguage.mandarin: '四十五',
    AppLanguage.tamil: 'நாற்பத்தைந்து',
  },
  '46': {
    AppLanguage.english: 'forty six',
    AppLanguage.malay: 'empat puluh enam',
    AppLanguage.mandarin: '四十六',
    AppLanguage.tamil: 'நாற்பத்தாறு',
  },
  '47': {
    AppLanguage.english: 'forty seven',
    AppLanguage.malay: 'empat puluh tujuh',
    AppLanguage.mandarin: '四十七',
    AppLanguage.tamil: 'நாற்பத்தேழு',
  },
  '48': {
    AppLanguage.english: 'forty eight',
    AppLanguage.malay: 'empat puluh lapan',
    AppLanguage.mandarin: '四十八',
    AppLanguage.tamil: 'நாற்பத்தெட்டு',
  },
  '49': {
    AppLanguage.english: 'forty nine',
    AppLanguage.malay: 'empat puluh sembilan',
    AppLanguage.mandarin: '四十九',
    AppLanguage.tamil: 'நாற்பத்தொன்பது',
  },
  '50': {
    AppLanguage.english: 'fifty',
    AppLanguage.malay: 'lima puluh',
    AppLanguage.mandarin: '五十',
    AppLanguage.tamil: 'ஐம்பது',
  },
  '51': {
    AppLanguage.english: 'fifty one',
    AppLanguage.malay: 'lima puluh satu',
    AppLanguage.mandarin: '五十一',
    AppLanguage.tamil: 'ஐம்பத்தொன்று',
  },
  '52': {
    AppLanguage.english: 'fifty two',
    AppLanguage.malay: 'lima puluh dua',
    AppLanguage.mandarin: '五十二',
    AppLanguage.tamil: 'ஐம்பத்திரண்டு',
  },
  '53': {
    AppLanguage.english: 'fifty three',
    AppLanguage.malay: 'lima puluh tiga',
    AppLanguage.mandarin: '五十三',
    AppLanguage.tamil: 'ஐம்பத்துமூன்று',
  },
  '54': {
    AppLanguage.english: 'fifty four',
    AppLanguage.malay: 'lima puluh empat',
    AppLanguage.mandarin: '五十四',
    AppLanguage.tamil: 'ஐம்பத்துநான்கு',
  },
  '55': {
    AppLanguage.english: 'fifty five',
    AppLanguage.malay: 'lima puluh lima',
    AppLanguage.mandarin: '五十五',
    AppLanguage.tamil: 'ஐம்பத்தைந்து',
  },
  '56': {
    AppLanguage.english: 'fifty six',
    AppLanguage.malay: 'lima puluh enam',
    AppLanguage.mandarin: '五十六',
    AppLanguage.tamil: 'ஐம்பத்தாறு',
  },
  '57': {
    AppLanguage.english: 'fifty seven',
    AppLanguage.malay: 'lima puluh tujuh',
    AppLanguage.mandarin: '五十七',
    AppLanguage.tamil: 'ஐம்பத்தேழு',
  },
  '58': {
    AppLanguage.english: 'fifty eight',
    AppLanguage.malay: 'lima puluh lapan',
    AppLanguage.mandarin: '五十八',
    AppLanguage.tamil: 'ஐம்பத்தெட்டு',
  },
  '59': {
    AppLanguage.english: 'fifty nine',
    AppLanguage.malay: 'lima puluh sembilan',
    AppLanguage.mandarin: '五十九',
    AppLanguage.tamil: 'ஐம்பத்தொன்பது',
  },
  '60': {
    AppLanguage.english: 'sixty',
    AppLanguage.malay: 'enam puluh',
    AppLanguage.mandarin: '六十',
    AppLanguage.tamil: 'அறுபது',
  },
  '61': {
    AppLanguage.english: 'sixty one',
    AppLanguage.malay: 'enam puluh satu',
    AppLanguage.mandarin: '六十一',
    AppLanguage.tamil: 'அறுபத்தொன்று',
  },
  '62': {
    AppLanguage.english: 'sixty two',
    AppLanguage.malay: 'enam puluh dua',
    AppLanguage.mandarin: '六十二',
    AppLanguage.tamil: 'அறுபத்திரண்டு',
  },
  '63': {
    AppLanguage.english: 'sixty three',
    AppLanguage.malay: 'enam puluh tiga',
    AppLanguage.mandarin: '六十三',
    AppLanguage.tamil: 'அறுபத்துமூன்று',
  },
  '64': {
    AppLanguage.english: 'sixty four',
    AppLanguage.malay: 'enam puluh empat',
    AppLanguage.mandarin: '六十四',
    AppLanguage.tamil: 'அறுபத்துநான்கு',
  },
  '65': {
    AppLanguage.english: 'sixty five',
    AppLanguage.malay: 'enam puluh lima',
    AppLanguage.mandarin: '六十五',
    AppLanguage.tamil: 'அறுபத்தைந்து',
  },
  '66': {
    AppLanguage.english: 'sixty six',
    AppLanguage.malay: 'enam puluh enam',
    AppLanguage.mandarin: '六十六',
    AppLanguage.tamil: 'அறுபத்தாறு',
  },
  '67': {
    AppLanguage.english: 'sixty seven',
    AppLanguage.malay: 'enam puluh tujuh',
    AppLanguage.mandarin: '六十七',
    AppLanguage.tamil: 'அறுபத்தேழு',
  },
  '68': {
    AppLanguage.english: 'sixty eight',
    AppLanguage.malay: 'enam puluh lapan',
    AppLanguage.mandarin: '六十八',
    AppLanguage.tamil: 'அறுபத்தெட்டு',
  },
  '69': {
    AppLanguage.english: 'sixty nine',
    AppLanguage.malay: 'enam puluh sembilan',
    AppLanguage.mandarin: '六十九',
    AppLanguage.tamil: 'அறுபத்தொன்பது',
  },
  '70': {
    AppLanguage.english: 'seventy',
    AppLanguage.malay: 'tujuh puluh',
    AppLanguage.mandarin: '七十',
    AppLanguage.tamil: 'எழுபது',
  },
  '71': {
    AppLanguage.english: 'seventy one',
    AppLanguage.malay: 'tujuh puluh satu',
    AppLanguage.mandarin: '七十一',
    AppLanguage.tamil: 'எழுபத்தொன்று',
  },
  '72': {
    AppLanguage.english: 'seventy two',
    AppLanguage.malay: 'tujuh puluh dua',
    AppLanguage.mandarin: '七十二',
    AppLanguage.tamil: 'எழுபத்திரண்டு',
  },
  '73': {
    AppLanguage.english: 'seventy three',
    AppLanguage.malay: 'tujuh puluh tiga',
    AppLanguage.mandarin: '七十三',
    AppLanguage.tamil: 'எழுபத்துமூன்று',
  },
  '74': {
    AppLanguage.english: 'seventy four',
    AppLanguage.malay: 'tujuh puluh empat',
    AppLanguage.mandarin: '七十四',
    AppLanguage.tamil: 'எழுபத்துநான்கு',
  },
  '75': {
    AppLanguage.english: 'seventy five',
    AppLanguage.malay: 'tujuh puluh lima',
    AppLanguage.mandarin: '七十五',
    AppLanguage.tamil: 'எழுபத்தைந்து',
  },
  '76': {
    AppLanguage.english: 'seventy six',
    AppLanguage.malay: 'tujuh puluh enam',
    AppLanguage.mandarin: '七十六',
    AppLanguage.tamil: 'எழுபத்தாறு',
  },
  '77': {
    AppLanguage.english: 'seventy seven',
    AppLanguage.malay: 'tujuh puluh tujuh',
    AppLanguage.mandarin: '七十七',
    AppLanguage.tamil: 'எழுபத்தேழு',
  },
  '78': {
    AppLanguage.english: 'seventy eight',
    AppLanguage.malay: 'tujuh puluh lapan',
    AppLanguage.mandarin: '七十八',
    AppLanguage.tamil: 'எழுபத்தெட்டு',
  },
  '79': {
    AppLanguage.english: 'seventy nine',
    AppLanguage.malay: 'tujuh puluh sembilan',
    AppLanguage.mandarin: '七十九',
    AppLanguage.tamil: 'எழுபத்தொன்பது',
  },
  '80': {
    AppLanguage.english: 'eighty',
    AppLanguage.malay: 'lapan puluh',
    AppLanguage.mandarin: '八十',
    AppLanguage.tamil: 'எண்பது',
  },
  '81': {
    AppLanguage.english: 'eighty one',
    AppLanguage.malay: 'lapan puluh satu',
    AppLanguage.mandarin: '八十一',
    AppLanguage.tamil: 'எண்பத்தொன்று',
  },
  '82': {
    AppLanguage.english: 'eighty two',
    AppLanguage.malay: 'lapan puluh dua',
    AppLanguage.mandarin: '八十二',
    AppLanguage.tamil: 'எண்பத்திரண்டு',
  },
  '83': {
    AppLanguage.english: 'eighty three',
    AppLanguage.malay: 'lapan puluh tiga',
    AppLanguage.mandarin: '八十三',
    AppLanguage.tamil: 'எண்பத்துமூன்று',
  },
  '84': {
    AppLanguage.english: 'eighty four',
    AppLanguage.malay: 'lapan puluh empat',
    AppLanguage.mandarin: '八十四',
    AppLanguage.tamil: 'எண்பத்துநான்கு',
  },
  '85': {
    AppLanguage.english: 'eighty five',
    AppLanguage.malay: 'lapan puluh lima',
    AppLanguage.mandarin: '八十五',
    AppLanguage.tamil: 'எண்பத்தைந்து',
  },
  '86': {
    AppLanguage.english: 'eighty six',
    AppLanguage.malay: 'lapan puluh enam',
    AppLanguage.mandarin: '八十六',
    AppLanguage.tamil: 'எண்பத்தாறு',
  },
  '87': {
    AppLanguage.english: 'eighty seven',
    AppLanguage.malay: 'lapan puluh tujuh',
    AppLanguage.mandarin: '八十七',
    AppLanguage.tamil: 'எண்பத்தேழு',
  },
  '88': {
    AppLanguage.english: 'eighty eight',
    AppLanguage.malay: 'lapan puluh lapan',
    AppLanguage.mandarin: '八十八',
    AppLanguage.tamil: 'எண்பத்தெட்டு',
  },
  '89': {
    AppLanguage.english: 'eighty nine',
    AppLanguage.malay: 'lapan puluh sembilan',
    AppLanguage.mandarin: '八十九',
    AppLanguage.tamil: 'எண்பத்தொன்பது',
  },
  '90': {
    AppLanguage.english: 'ninety',
    AppLanguage.malay: 'sembilan puluh',
    AppLanguage.mandarin: '九十',
    AppLanguage.tamil: 'தொண்ணூறு',
  },
  '91': {
    AppLanguage.english: 'ninety one',
    AppLanguage.malay: 'sembilan puluh satu',
    AppLanguage.mandarin: '九十一',
    AppLanguage.tamil: 'தொண்ணூற்றொன்று',
  },
  '92': {
    AppLanguage.english: 'ninety two',
    AppLanguage.malay: 'sembilan puluh dua',
    AppLanguage.mandarin: '九十二',
    AppLanguage.tamil: 'தொண்ணூற்றிரண்டு',
  },
  '93': {
    AppLanguage.english: 'ninety three',
    AppLanguage.malay: 'sembilan puluh tiga',
    AppLanguage.mandarin: '九十三',
    AppLanguage.tamil: 'தொண்ணூற்றுமூன்று',
  },
  '94': {
    AppLanguage.english: 'ninety four',
    AppLanguage.malay: 'sembilan puluh empat',
    AppLanguage.mandarin: '九十四',
    AppLanguage.tamil: 'தொண்ணூற்றுநான்கு',
  },
  '95': {
    AppLanguage.english: 'ninety five',
    AppLanguage.malay: 'sembilan puluh lima',
    AppLanguage.mandarin: '九十五',
    AppLanguage.tamil: 'தொண்ணூற்றைந்து',
  },
  '96': {
    AppLanguage.english: 'ninety six',
    AppLanguage.malay: 'sembilan puluh enam',
    AppLanguage.mandarin: '九十六',
    AppLanguage.tamil: 'தொண்ணூற்றாறு',
  },
  '97': {
    AppLanguage.english: 'ninety seven',
    AppLanguage.malay: 'sembilan puluh tujuh',
    AppLanguage.mandarin: '九十七',
    AppLanguage.tamil: 'தொண்ணூற்றேழு',
  },
  '98': {
    AppLanguage.english: 'ninety eight',
    AppLanguage.malay: 'sembilan puluh lapan',
    AppLanguage.mandarin: '九十八',
    AppLanguage.tamil: 'தொண்ணூற்றெட்டு',
  },
  '99': {
    AppLanguage.english: 'ninety nine',
    AppLanguage.malay: 'sembilan puluh sembilan',
    AppLanguage.mandarin: '九十九',
    AppLanguage.tamil: 'தொண்ணூற்றொன்பது',
  },
  '100': {
    AppLanguage.english: 'one hundred',
    AppLanguage.malay: 'seratus',
    AppLanguage.mandarin: '一百',
    AppLanguage.tamil: 'நூறு',
  },
};

const _labels = <String, Map<AppLanguage, String>>{
  // ── Previously untranslated explorer objects: these fell back to English
  // inside Malay sentences ("cari Apple!") and were mispronounced by the
  // ms-MY voice. Every object the explorer can ask for MUST have a full set.
  'object_apple': {
    AppLanguage.english: 'Apple',
    AppLanguage.malay: 'Epal',
    AppLanguage.indonesian: 'Apel',
    AppLanguage.mandarin: '苹果',
    AppLanguage.tamil: 'ஆப்பிள்',
  },
  'object_banana': {
    AppLanguage.english: 'Banana',
    AppLanguage.malay: 'Pisang',
    AppLanguage.indonesian: 'Pisang',
    AppLanguage.mandarin: '香蕉',
    AppLanguage.tamil: 'வாழைப்பழம்',
  },
  'object_cat': {
    AppLanguage.english: 'Cat',
    AppLanguage.malay: 'Kucing',
    AppLanguage.indonesian: 'Kucing',
    AppLanguage.mandarin: '猫',
    AppLanguage.tamil: 'பூனை',
  },
  'object_dog': {
    AppLanguage.english: 'Dog',
    AppLanguage.malay: 'Anjing',
    AppLanguage.indonesian: 'Anjing',
    AppLanguage.mandarin: '狗',
    AppLanguage.tamil: 'நாய்',
  },
  'object_flower': {
    AppLanguage.english: 'Flower',
    AppLanguage.malay: 'Bunga',
    AppLanguage.indonesian: 'Bunga',
    AppLanguage.mandarin: '花',
    AppLanguage.tamil: 'பூ',
  },
  'object_star': {
    AppLanguage.english: 'Star',
    AppLanguage.malay: 'Bintang',
    AppLanguage.indonesian: 'Bintang',
    AppLanguage.mandarin: '星星',
    AppLanguage.tamil: 'நட்சத்திரம்',
  },
  'color_red': {
    AppLanguage.english: 'Red',
    AppLanguage.malay: 'Merah',
    AppLanguage.mandarin: '红色',
    AppLanguage.tamil: 'சிவப்பு',
  },
  'color_blue': {
    AppLanguage.english: 'Blue',
    AppLanguage.malay: 'Biru',
    AppLanguage.mandarin: '蓝色',
    AppLanguage.tamil: 'நீலம்',
  },
  'color_yellow': {
    AppLanguage.english: 'Yellow',
    AppLanguage.malay: 'Kuning',
    AppLanguage.mandarin: '黄色',
    AppLanguage.tamil: 'மஞ்சள்',
  },
  'color_green': {
    AppLanguage.english: 'Green',
    AppLanguage.malay: 'Hijau',
    AppLanguage.mandarin: '绿色',
    AppLanguage.tamil: 'பச்சை',
  },
  'color_orange': {
    AppLanguage.english: 'Orange',
    AppLanguage.malay: 'Jingga',
    AppLanguage.mandarin: '橙色',
    AppLanguage.tamil: 'ஆரஞ்சு',
  },
  'color_purple': {
    AppLanguage.english: 'Purple',
    AppLanguage.malay: 'Ungu',
    AppLanguage.mandarin: '紫色',
    AppLanguage.tamil: 'ஊதா',
  },
  'color_pink': {
    AppLanguage.english: 'Pink',
    AppLanguage.malay: 'Merah jambu',
    AppLanguage.mandarin: '粉色',
    AppLanguage.tamil: 'இளஞ்சிவப்பு',
  },
  'color_black': {
    AppLanguage.english: 'Black',
    AppLanguage.malay: 'Hitam',
    AppLanguage.mandarin: '黑色',
    AppLanguage.tamil: 'கருப்பு',
  },
  'color_white': {
    AppLanguage.english: 'White',
    AppLanguage.malay: 'Putih',
    AppLanguage.mandarin: '白色',
    AppLanguage.tamil: 'வெள்ளை',
  },
  'color_brown': {
    AppLanguage.english: 'Brown',
    AppLanguage.malay: 'Coklat',
    AppLanguage.mandarin: '棕色',
    AppLanguage.tamil: 'பழுப்பு',
  },
  'shape_circle': {
    AppLanguage.english: 'Circle',
    AppLanguage.malay: 'Bulatan',
    AppLanguage.mandarin: '圆形',
    AppLanguage.tamil: 'வட்டம்',
  },
  'shape_square': {
    AppLanguage.english: 'Square',
    AppLanguage.malay: 'Segi empat sama',
    AppLanguage.mandarin: '正方形',
    AppLanguage.tamil: 'சதுரம்',
  },
  'shape_triangle': {
    AppLanguage.english: 'Triangle',
    AppLanguage.malay: 'Segi tiga',
    AppLanguage.mandarin: '三角形',
    AppLanguage.tamil: 'முக்கோணம்',
  },
  'shape_rectangle': {
    AppLanguage.english: 'Rectangle',
    AppLanguage.malay: 'Segi empat tepat',
    AppLanguage.mandarin: '长方形',
    AppLanguage.tamil: 'செவ்வகம்',
  },
  'shape_star': {
    AppLanguage.english: 'Star',
    AppLanguage.malay: 'Bintang',
    AppLanguage.mandarin: '星形',
    AppLanguage.tamil: 'நட்சத்திரம்',
  },
  'shape_heart': {
    AppLanguage.english: 'Heart',
    AppLanguage.malay: 'Hati',
    AppLanguage.mandarin: '心形',
    AppLanguage.tamil: 'இதயம்',
  },
  'shape_oval': {
    AppLanguage.english: 'Oval',
    AppLanguage.malay: 'Bujur',
    AppLanguage.mandarin: '椭圆形',
    AppLanguage.tamil: 'நீள்வட்டம்',
  },
  'shape_diamond': {
    AppLanguage.english: 'Diamond',
    AppLanguage.malay: 'Berlian',
    AppLanguage.mandarin: '菱形',
    AppLanguage.tamil: 'வைரம்',
  },
  'object_book': {
    AppLanguage.english: 'Book',
    AppLanguage.malay: 'Buku',
    AppLanguage.mandarin: '书',
    AppLanguage.tamil: 'புத்தகம்',
  },
  'object_cup': {
    AppLanguage.english: 'Cup',
    AppLanguage.malay: 'Cawan',
    AppLanguage.mandarin: '杯子',
    AppLanguage.tamil: 'கோப்பை',
  },
  'object_spoon': {
    AppLanguage.english: 'Spoon',
    AppLanguage.malay: 'Sudu',
    AppLanguage.mandarin: '勺子',
    AppLanguage.tamil: 'கரண்டி',
  },
  'object_toy': {
    AppLanguage.english: 'Toy',
    AppLanguage.malay: 'Mainan',
    AppLanguage.mandarin: '玩具',
    AppLanguage.tamil: 'பொம்மை',
  },
  'object_ball': {
    AppLanguage.english: 'Ball',
    AppLanguage.malay: 'Bola',
    AppLanguage.mandarin: '球',
    AppLanguage.tamil: 'பந்து',
  },
  'object_shoe': {
    AppLanguage.english: 'Shoe',
    AppLanguage.malay: 'Kasut',
    AppLanguage.mandarin: '鞋',
    AppLanguage.tamil: 'காலணி',
  },
  'object_pencil': {
    AppLanguage.english: 'Pencil',
    AppLanguage.malay: 'Pensel',
    AppLanguage.mandarin: '铅笔',
    AppLanguage.tamil: 'பென்சில்',
  },
  'object_bottle': {
    AppLanguage.english: 'Bottle',
    AppLanguage.malay: 'Botol',
    AppLanguage.mandarin: '瓶子',
    AppLanguage.tamil: 'பாட்டில்',
  },
  'object_chair': {
    AppLanguage.english: 'Chair',
    AppLanguage.malay: 'Kerusi',
    AppLanguage.mandarin: '椅子',
    AppLanguage.tamil: 'நாற்காலி',
  },
  'object_bag': {
    AppLanguage.english: 'Bag',
    AppLanguage.malay: 'Beg',
    AppLanguage.mandarin: '包',
    AppLanguage.tamil: 'பை',
  },
  'object_clock': {
    AppLanguage.english: 'Clock',
    AppLanguage.malay: 'Jam',
    AppLanguage.mandarin: '时钟',
    AppLanguage.tamil: 'கடிகாரம்',
  },
  'object_plate': {
    AppLanguage.english: 'Plate',
    AppLanguage.malay: 'Pinggan',
    AppLanguage.mandarin: '盘子',
    AppLanguage.tamil: 'தட்டு',
  },
  'sound_cat': {
    AppLanguage.english: 'Cat',
    AppLanguage.malay: 'Kucing',
    AppLanguage.mandarin: '猫',
    AppLanguage.tamil: 'பூனை',
  },
  'sound_dog': {
    AppLanguage.english: 'Dog',
    AppLanguage.malay: 'Anjing',
    AppLanguage.mandarin: '狗',
    AppLanguage.tamil: 'நாய்',
  },
  'sound_cow': {
    AppLanguage.english: 'Cow',
    AppLanguage.malay: 'Lembu',
    AppLanguage.mandarin: '牛',
    AppLanguage.tamil: 'பசு',
  },
  'sound_bird': {
    AppLanguage.english: 'Bird',
    AppLanguage.malay: 'Burung',
    AppLanguage.mandarin: '鸟',
    AppLanguage.tamil: 'பறவை',
  },
  'sound_rain': {
    AppLanguage.english: 'Rain',
    AppLanguage.malay: 'Hujan',
    AppLanguage.mandarin: '雨',
    AppLanguage.tamil: 'மழை',
  },
  'sound_car': {
    AppLanguage.english: 'Car',
    AppLanguage.malay: 'Kereta',
    AppLanguage.mandarin: '汽车',
    AppLanguage.tamil: 'கார்',
  },
  'sound_train': {
    AppLanguage.english: 'Train',
    AppLanguage.malay: 'Kereta api',
    AppLanguage.mandarin: '火车',
    AppLanguage.tamil: 'ரயில்',
  },
  'sound_doorbell': {
    AppLanguage.english: 'Doorbell',
    AppLanguage.malay: 'Loceng pintu',
    AppLanguage.mandarin: '门铃',
    AppLanguage.tamil: 'கதவு மணி',
  },
  'sound_phone': {
    AppLanguage.english: 'Phone',
    AppLanguage.malay: 'Telefon',
    AppLanguage.mandarin: '电话',
    AppLanguage.tamil: 'தொலைபேசி',
  },
  'sound_clock': {
    AppLanguage.english: 'Clock',
    AppLanguage.malay: 'Jam',
    AppLanguage.mandarin: '时钟',
    AppLanguage.tamil: 'கடிகாரம்',
  },
  'animal_cat': {
    AppLanguage.english: 'Cat',
    AppLanguage.malay: 'Kucing',
    AppLanguage.mandarin: '猫',
    AppLanguage.tamil: 'பூனை',
  },
  'animal_dog': {
    AppLanguage.english: 'Dog',
    AppLanguage.malay: 'Anjing',
    AppLanguage.mandarin: '狗',
    AppLanguage.tamil: 'நாய்',
  },
  'animal_cow': {
    AppLanguage.english: 'Cow',
    AppLanguage.malay: 'Lembu',
    AppLanguage.mandarin: '牛',
    AppLanguage.tamil: 'பசு',
  },
  'animal_bird': {
    AppLanguage.english: 'Bird',
    AppLanguage.malay: 'Burung',
    AppLanguage.mandarin: '鸟',
    AppLanguage.tamil: 'பறவை',
  },
  'animal_fish': {
    AppLanguage.english: 'Fish',
    AppLanguage.malay: 'Ikan',
    AppLanguage.mandarin: '鱼',
    AppLanguage.tamil: 'மீன்',
  },
  'animal_bug': {
    AppLanguage.english: 'Bug',
    AppLanguage.malay: 'Serangga',
    AppLanguage.mandarin: '虫子',
    AppLanguage.tamil: 'பூச்சி',
  },
};

// ── Level titles (EN/MS from models/level.dart; ZH/TA/ID added here) ─────────
const _levelTitles = <int, Map<AppLanguage, String>>{
  1: {
    AppLanguage.english: 'Tiny Learner', AppLanguage.malay: 'Pelajar Cilik',
    AppLanguage.mandarin: '小小学习者', AppLanguage.tamil: 'சிறு கற்பவர்',
    AppLanguage.indonesian: 'Pelajar Cilik',
  },
  2: {
    AppLanguage.english: 'Little Explorer', AppLanguage.malay: 'Penjelajah Kecil',
    AppLanguage.mandarin: '小探险家', AppLanguage.tamil: 'சிறிய ஆய்வாளர்',
    AppLanguage.indonesian: 'Penjelajah Kecil',
  },
  3: {
    AppLanguage.english: 'Star Finder', AppLanguage.malay: 'Pencari Bintang',
    AppLanguage.mandarin: '寻星者', AppLanguage.tamil: 'நட்சத்திர தேடுபவர்',
    AppLanguage.indonesian: 'Pencari Bintang',
  },
  4: {
    AppLanguage.english: 'Smart Scholar', AppLanguage.malay: 'Sarjana Bijak',
    AppLanguage.mandarin: '聪明学者', AppLanguage.tamil: 'புத்திசாலி அறிஞர்',
    AppLanguage.indonesian: 'Cendekiawan Pintar',
  },
  5: {
    AppLanguage.english: 'Bright Champion', AppLanguage.malay: 'Juara Cerah',
    AppLanguage.mandarin: '闪亮冠军', AppLanguage.tamil: 'பிரகாச வீரர்',
    AppLanguage.indonesian: 'Juara Cerdas',
  },
  6: {
    AppLanguage.english: 'Wise Wizard', AppLanguage.malay: 'Ahli Sihir Bijak',
    AppLanguage.mandarin: '智慧巫师', AppLanguage.tamil: 'ஞான மந்திரவாதி',
    AppLanguage.indonesian: 'Penyihir Bijak',
  },
  7: {
    AppLanguage.english: 'Super Star', AppLanguage.malay: 'Bintang Super',
    AppLanguage.mandarin: '超级明星', AppLanguage.tamil: 'சூப்பர் நட்சத்திரம்',
    AppLanguage.indonesian: 'Bintang Super',
  },
  8: {
    AppLanguage.english: 'Knowledge Hero', AppLanguage.malay: 'Wira Ilmu',
    AppLanguage.mandarin: '知识英雄', AppLanguage.tamil: 'அறிவு வீரர்',
    AppLanguage.indonesian: 'Pahlawan Ilmu',
  },
  9: {
    AppLanguage.english: 'Learning Legend', AppLanguage.malay: 'Legenda Belajar',
    AppLanguage.mandarin: '学习传奇', AppLanguage.tamil: 'கற்றல் புராணம்',
    AppLanguage.indonesian: 'Legenda Belajar',
  },
  10: {
    AppLanguage.english: 'Master Explorer', AppLanguage.malay: 'Penjelajah Master',
    AppLanguage.mandarin: '探险大师', AppLanguage.tamil: 'மாஸ்டர் ஆய்வாளர்',
    AppLanguage.indonesian: 'Penjelajah Master',
  },
};

// ── Daily-quest titles (keyed by quest id) ──────────────────────────────────
const _questTitles = <String, Map<AppLanguage, String>>{
  'q_lesson_2': {
    AppLanguage.english: 'Lesson Champ', AppLanguage.malay: 'Juara Pelajaran',
    AppLanguage.mandarin: '课程冠军', AppLanguage.tamil: 'பாட வீரர்',
    AppLanguage.indonesian: 'Juara Pelajaran',
  },
  'q_game_1': {
    AppLanguage.english: 'Game Time!', AppLanguage.malay: 'Masa Bermain!',
    AppLanguage.mandarin: '游戏时间！', AppLanguage.tamil: 'விளையாட்டு நேரம்!',
    AppLanguage.indonesian: 'Waktu Bermain!',
  },
  'q_numbers_3': {
    AppLanguage.english: 'Number Explorer', AppLanguage.malay: 'Penjelajah Nombor',
    AppLanguage.mandarin: '数字探险家', AppLanguage.tamil: 'எண் ஆய்வாளர்',
    AppLanguage.indonesian: 'Penjelajah Angka',
  },
  'q_letters_3': {
    AppLanguage.english: 'ABC Hero', AppLanguage.malay: 'Wira ABC',
    AppLanguage.mandarin: '字母英雄', AppLanguage.tamil: 'ABC வீரர்',
    AppLanguage.indonesian: 'Pahlawan ABC',
  },
  'q_math_3': {
    AppLanguage.english: 'Math Whiz', AppLanguage.malay: 'Ahli Matematik',
    AppLanguage.mandarin: '数学高手', AppLanguage.tamil: 'கணித மேதை',
    AppLanguage.indonesian: 'Jago Matematika',
  },
  'q_jawi_2': {
    AppLanguage.english: 'Jawi Scholar', AppLanguage.malay: 'Sarjana Jawi',
    AppLanguage.mandarin: '爪夷文学者', AppLanguage.tamil: 'ஜாவி அறிஞர்',
    AppLanguage.indonesian: 'Cendekiawan Jawi',
  },
  'q_memory_1': {
    AppLanguage.english: 'Memory Master', AppLanguage.malay: 'Master Ingatan',
    AppLanguage.mandarin: '记忆大师', AppLanguage.tamil: 'நினைவு மாஸ்டர்',
    AppLanguage.indonesian: 'Master Ingatan',
  },
  'q_body_2': {
    AppLanguage.english: 'Body Explorer', AppLanguage.malay: 'Penjelajah Badan',
    AppLanguage.mandarin: '身体探险家', AppLanguage.tamil: 'உடல் ஆய்வாளர்',
    AppLanguage.indonesian: 'Penjelajah Tubuh',
  },
  'q_color_1': {
    AppLanguage.english: 'Young Artist', AppLanguage.malay: 'Artis Muda',
    AppLanguage.mandarin: '小小艺术家', AppLanguage.tamil: 'இளம் கலைஞர்',
    AppLanguage.indonesian: 'Seniman Muda',
  },
  'q_lesson_5': {
    AppLanguage.english: 'Super Student', AppLanguage.malay: 'Pelajar Super',
    AppLanguage.mandarin: '超级学生', AppLanguage.tamil: 'சூப்பர் மாணவர்',
    AppLanguage.indonesian: 'Pelajar Super',
  },
};

// ── Daily-quest descriptions (keyed by quest id) ────────────────────────────
const _questDescriptions = <String, Map<AppLanguage, String>>{
  'q_lesson_2': {
    AppLanguage.english: 'Complete 2 lessons in any module',
    AppLanguage.malay: 'Siapkan 2 pelajaran dalam mana-mana modul',
    AppLanguage.mandarin: '完成任意模块的 2 节课',
    AppLanguage.tamil: 'எந்த தொகுதியிலும் 2 பாடங்களை முடிக்கவும்',
    AppLanguage.indonesian: 'Selesaikan 2 pelajaran di modul mana pun',
  },
  'q_game_1': {
    AppLanguage.english: 'Complete 1 game',
    AppLanguage.malay: 'Selesaikan 1 permainan',
    AppLanguage.mandarin: '完成 1 个游戏',
    AppLanguage.tamil: '1 விளையாட்டை முடிக்கவும்',
    AppLanguage.indonesian: 'Selesaikan 1 permainan',
  },
  'q_numbers_3': {
    AppLanguage.english: 'Learn 3 new numbers',
    AppLanguage.malay: 'Belajar 3 nombor baru',
    AppLanguage.mandarin: '学习 3 个新数字',
    AppLanguage.tamil: '3 புதிய எண்களைக் கற்கவும்',
    AppLanguage.indonesian: 'Pelajari 3 angka baru',
  },
  'q_letters_3': {
    AppLanguage.english: 'Learn 3 new letters',
    AppLanguage.malay: 'Belajar 3 huruf baru',
    AppLanguage.mandarin: '学习 3 个新字母',
    AppLanguage.tamil: '3 புதிய எழுத்துக்களைக் கற்கவும்',
    AppLanguage.indonesian: 'Pelajari 3 huruf baru',
  },
  'q_math_3': {
    AppLanguage.english: 'Solve 3 math problems',
    AppLanguage.malay: 'Selesaikan 3 soalan matematik',
    AppLanguage.mandarin: '解答 3 道数学题',
    AppLanguage.tamil: '3 கணிதக் கணக்குகளைத் தீர்க்கவும்',
    AppLanguage.indonesian: 'Selesaikan 3 soal matematika',
  },
  'q_jawi_2': {
    AppLanguage.english: 'Learn 2 Jawi letters',
    AppLanguage.malay: 'Belajar 2 huruf Jawi',
    AppLanguage.mandarin: '学习 2 个爪夷字母',
    AppLanguage.tamil: '2 ஜாவி எழுத்துக்களைக் கற்கவும்',
    AppLanguage.indonesian: 'Pelajari 2 huruf Jawi',
  },
  'q_memory_1': {
    AppLanguage.english: 'Play Memory Game once',
    AppLanguage.malay: 'Main Permainan Memori sekali',
    AppLanguage.mandarin: '玩一次记忆游戏',
    AppLanguage.tamil: 'நினைவு விளையாட்டை ஒருமுறை விளையாடவும்',
    AppLanguage.indonesian: 'Main Game Memori sekali',
  },
  'q_body_2': {
    AppLanguage.english: 'Learn 2 body parts',
    AppLanguage.malay: 'Belajar 2 anggota badan',
    AppLanguage.mandarin: '学习 2 个身体部位',
    AppLanguage.tamil: '2 உடல் உறுப்புகளைக் கற்கவும்',
    AppLanguage.indonesian: 'Pelajari 2 anggota tubuh',
  },
  'q_color_1': {
    AppLanguage.english: 'Do 1 coloring activity',
    AppLanguage.malay: 'Lakukan 1 aktiviti mewarna',
    AppLanguage.mandarin: '完成 1 个涂色活动',
    AppLanguage.tamil: '1 வண்ணமிடும் செயலைச் செய்யவும்',
    AppLanguage.indonesian: 'Lakukan 1 aktivitas mewarnai',
  },
  'q_lesson_5': {
    AppLanguage.english: 'Complete 5 lessons today',
    AppLanguage.malay: 'Siapkan 5 pelajaran hari ini',
    AppLanguage.mandarin: '今天完成 5 节课',
    AppLanguage.tamil: 'இன்று 5 பாடங்களை முடிக்கவும்',
    AppLanguage.indonesian: 'Selesaikan 5 pelajaran hari ini',
  },
};
