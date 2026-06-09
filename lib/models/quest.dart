import 'dart:math';

import 'app_language.dart';

enum QuestType {
  completeLesson,
  playGame,
  doMath,
  learnLetters,
  learnNumbers,
  learnJawi,
  learnBodyParts,
  doColoring,
  playMemory,
}

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.type,
    required this.title,
    required this.titleMalay,
    this.titleMandarin,
    this.titleTamil,
    this.titleIndonesian,
    required this.description,
    required this.descriptionMalay,
    this.descriptionMandarin,
    this.descriptionTamil,
    this.descriptionIndonesian,
    required this.emoji,
    required this.rewardStars,
    required this.requiredCount,
  });

  final String id;
  final QuestType type;

  // ── Titles ──────────────────────────────────────────────────────
  /// English title (also the fallback for any missing language).
  final String title;
  final String titleMalay;
  final String? titleMandarin;
  final String? titleTamil;
  final String? titleIndonesian;

  // ── Descriptions ────────────────────────────────────────────────
  /// English description (also the fallback for any missing language).
  final String description;
  final String descriptionMalay;
  final String? descriptionMandarin;
  final String? descriptionTamil;
  final String? descriptionIndonesian;

  final String emoji;
  final int rewardStars;
  final int requiredCount;

  // ── Localization helpers ─────────────────────────────────────────

  /// Returns the title for [lang], falling back to English if not provided.
  String localizedTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.malay:       return titleMalay;
      case AppLanguage.mandarin:    return titleMandarin ?? title;
      case AppLanguage.tamil:       return titleTamil ?? title;
      case AppLanguage.indonesian:  return titleIndonesian ?? title;
      case AppLanguage.english:     return title;
    }
  }

  /// Returns the description for [lang], falling back to English if not provided.
  String localizedDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.malay:       return descriptionMalay;
      case AppLanguage.mandarin:    return descriptionMandarin ?? description;
      case AppLanguage.tamil:       return descriptionTamil ?? description;
      case AppLanguage.indonesian:  return descriptionIndonesian ?? description;
      case AppLanguage.english:     return description;
    }
  }
}

const List<DailyQuest> allQuests = [
  DailyQuest(
    id: 'q_lesson_2', type: QuestType.completeLesson,
    title: 'Lesson Champ', titleMalay: 'Juara Pelajaran',
    description: 'Complete 2 lessons in any module', descriptionMalay: 'Siapkan 2 pelajaran dalam mana-mana modul',
    emoji: '📖', rewardStars: 3, requiredCount: 2,
  ),
  DailyQuest(
    id: 'q_game_1', type: QuestType.playGame,
    title: 'Game Time!', titleMalay: 'Masa Bermain!',
    description: 'Complete 1 game', descriptionMalay: 'Selesaikan 1 permainan',
    emoji: '🎮', rewardStars: 3, requiredCount: 1,
  ),
  DailyQuest(
    id: 'q_numbers_3', type: QuestType.learnNumbers,
    title: 'Number Explorer', titleMalay: 'Penjelajah Nombor',
    description: 'Learn 3 new numbers', descriptionMalay: 'Belajar 3 nombor baru',
    emoji: '🔢', rewardStars: 4, requiredCount: 3,
  ),
  DailyQuest(
    id: 'q_letters_3', type: QuestType.learnLetters,
    title: 'ABC Hero', titleMalay: 'Wira ABC',
    description: 'Learn 3 new letters', descriptionMalay: 'Belajar 3 huruf baru',
    emoji: '🔤', rewardStars: 4, requiredCount: 3,
  ),
  DailyQuest(
    id: 'q_math_3', type: QuestType.doMath,
    title: 'Math Whiz', titleMalay: 'Ahli Matematik',
    description: 'Solve 3 math problems', descriptionMalay: 'Selesaikan 3 soalan matematik',
    emoji: '🧮', rewardStars: 4, requiredCount: 3,
  ),
  DailyQuest(
    id: 'q_jawi_2', type: QuestType.learnJawi,
    title: 'Jawi Scholar', titleMalay: 'Sarjana Jawi',
    description: 'Learn 2 Jawi letters', descriptionMalay: 'Belajar 2 huruf Jawi',
    emoji: '🌙', rewardStars: 4, requiredCount: 2,
  ),
  DailyQuest(
    id: 'q_memory_1', type: QuestType.playMemory,
    title: 'Memory Master', titleMalay: 'Master Ingatan',
    description: 'Play Memory Game once', descriptionMalay: 'Main Permainan Memori sekali',
    emoji: '🃏', rewardStars: 3, requiredCount: 1,
  ),
  DailyQuest(
    id: 'q_body_2', type: QuestType.learnBodyParts,
    title: 'Body Explorer', titleMalay: 'Penjelajah Badan',
    description: 'Learn 2 body parts', descriptionMalay: 'Belajar 2 anggota badan',
    emoji: '🧍', rewardStars: 3, requiredCount: 2,
  ),
  DailyQuest(
    id: 'q_color_1', type: QuestType.doColoring,
    title: 'Young Artist', titleMalay: 'Artis Muda',
    description: 'Do 1 coloring activity', descriptionMalay: 'Lakukan 1 aktiviti mewarna',
    emoji: '🎨', rewardStars: 3, requiredCount: 1,
  ),
  DailyQuest(
    id: 'q_lesson_5', type: QuestType.completeLesson,
    title: 'Super Student', titleMalay: 'Pelajar Super',
    description: 'Complete 5 lessons today', descriptionMalay: 'Siapkan 5 pelajaran hari ini',
    emoji: '🌟', rewardStars: 6, requiredCount: 5,
  ),
];

List<DailyQuest> todayQuests() {
  final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
  final rng = Random(day);
  final pool = List.of(allQuests)..shuffle(rng);
  return pool.take(3).toList();
}
