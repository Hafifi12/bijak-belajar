import 'package:flutter/material.dart';

import '../models/badge.dart';

const badges = <FinderBadge>[
  // ── First Steps ────────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_first_number', title: 'Number Starter', titleMalay: 'Pemula Nombor',
    description: 'Learned first number!', descriptionMalay: 'Belajar nombor pertama!',
    condition: BadgeCondition.moduleComplete, requiredCount: 1, moduleId: 'numbers',
    icon: Icons.looks_one_rounded, color: Color(0xFFFF6B6B),
  ),
  FinderBadge(
    id: 'badge_first_letter', title: 'ABC Starter', titleMalay: 'Pemula ABC',
    description: 'Learned first letter!', descriptionMalay: 'Belajar huruf pertama!',
    condition: BadgeCondition.moduleComplete, requiredCount: 1, moduleId: 'letters',
    icon: Icons.text_fields_rounded, color: Color(0xFF00C9A7),
  ),
  FinderBadge(
    id: 'badge_first_jawi', title: 'Jawi Beginner', titleMalay: 'Pemula Jawi',
    description: 'Started learning Jawi!', descriptionMalay: 'Mula belajar Jawi!',
    condition: BadgeCondition.moduleComplete, requiredCount: 1, moduleId: 'jawi',
    icon: Icons.auto_stories_rounded, color: Color(0xFF34C759),
  ),
  FinderBadge(
    id: 'badge_first_body', title: 'Body Explorer', titleMalay: 'Penjelajah Badan',
    description: 'Learned first body part!', descriptionMalay: 'Belajar anggota badan pertama!',
    condition: BadgeCondition.moduleComplete, requiredCount: 1, moduleId: 'bodyparts',
    icon: Icons.accessibility_new_rounded, color: Color(0xFF7A5CFF),
  ),

  // ── Numbers ────────────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_numbers_10', title: 'Counting to 10', titleMalay: 'Kira Hingga 10',
    description: 'Learned 10 numbers!', descriptionMalay: 'Belajar 10 nombor!',
    condition: BadgeCondition.moduleComplete, requiredCount: 10, moduleId: 'numbers',
    icon: Icons.dialpad_rounded, color: Color(0xFFFF4D4F),
  ),
  FinderBadge(
    id: 'badge_numbers_50', title: 'Halfway There!', titleMalay: 'Separuh Jalan!',
    description: 'Learned 50 numbers!', descriptionMalay: 'Belajar 50 nombor!',
    condition: BadgeCondition.moduleComplete, requiredCount: 50, moduleId: 'numbers',
    icon: Icons.star_half_rounded, color: Color(0xFFE84393),
  ),
  FinderBadge(
    id: 'badge_numbers_complete', title: 'Number Master', titleMalay: 'Master Nombor',
    description: 'Mastered all 100 numbers!', descriptionMalay: 'Kuasai semua 100 nombor!',
    condition: BadgeCondition.moduleComplete, requiredCount: 100, moduleId: 'numbers',
    icon: Icons.format_list_numbered_rounded, color: Color(0xFFB71C1C),
  ),

  // ── Letters ────────────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_letters_13', title: 'Halfway ABC', titleMalay: 'Separuh ABC',
    description: 'Learned 13 letters!', descriptionMalay: 'Belajar 13 huruf!',
    condition: BadgeCondition.moduleComplete, requiredCount: 13, moduleId: 'letters',
    icon: Icons.sort_by_alpha_rounded, color: Color(0xFF00838F),
  ),
  FinderBadge(
    id: 'badge_letters_complete', title: 'Alphabet Hero', titleMalay: 'Wira Abjad',
    description: 'Completed the full alphabet!', descriptionMalay: 'Siapkan abjad penuh!',
    condition: BadgeCondition.moduleComplete, requiredCount: 26, moduleId: 'letters',
    icon: Icons.spellcheck_rounded, color: Color(0xFF00695C),
  ),

  // ── Jawi & Body Parts ──────────────────────────────────────────────
  FinderBadge(
    id: 'badge_jawi_complete', title: 'Jawi Champion', titleMalay: 'Juara Jawi',
    description: 'Completed all 28 Jawi letters!', descriptionMalay: 'Siapkan semua 28 huruf Jawi!',
    condition: BadgeCondition.moduleComplete, requiredCount: 28, moduleId: 'jawi',
    icon: Icons.auto_stories_rounded, color: Color(0xFF1B5E20),
  ),
  FinderBadge(
    id: 'badge_bodyparts_complete', title: 'Body Expert', titleMalay: 'Pakar Badan',
    description: 'Learned all 14 body parts!', descriptionMalay: 'Belajar semua 14 anggota badan!',
    condition: BadgeCondition.moduleComplete, requiredCount: 14, moduleId: 'bodyparts',
    icon: Icons.accessibility_new_rounded, color: Color(0xFF4527A0),
  ),

  // ── Star Milestones ────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_stars_5', title: 'First Stars', titleMalay: 'Bintang Pertama',
    description: 'Collected 5 stars!', descriptionMalay: 'Kumpul 5 bintang!',
    condition: BadgeCondition.totalStars, requiredCount: 5,
    icon: Icons.star_rounded, color: Color(0xFFFFC857),
  ),
  FinderBadge(
    id: 'badge_stars_25', title: 'Star Collector', titleMalay: 'Pengumpul Bintang',
    description: 'Collected 25 stars!', descriptionMalay: 'Kumpul 25 bintang!',
    condition: BadgeCondition.totalStars, requiredCount: 25,
    icon: Icons.stars_rounded, color: Color(0xFFFFD21E),
  ),
  FinderBadge(
    id: 'badge_stars_75', title: 'Star Hunter', titleMalay: 'Pemburu Bintang',
    description: 'Collected 75 stars!', descriptionMalay: 'Kumpul 75 bintang!',
    condition: BadgeCondition.totalStars, requiredCount: 75,
    icon: Icons.auto_awesome_rounded, color: Color(0xFFFF9F43),
  ),
  FinderBadge(
    id: 'badge_stars_150', title: 'Century Star', titleMalay: 'Bintang Abad',
    description: 'Collected 150 stars!', descriptionMalay: 'Kumpul 150 bintang!',
    condition: BadgeCondition.totalStars, requiredCount: 150,
    icon: Icons.workspace_premium_rounded, color: Color(0xFFE84393),
  ),

  // ── Games ──────────────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_games_5', title: 'First Finder', titleMalay: 'Pencari Pertama',
    description: 'Completed 5 challenges!', descriptionMalay: 'Siapkan 5 cabaran!',
    condition: BadgeCondition.completedChallenges, requiredCount: 5,
    icon: Icons.travel_explore_rounded, color: Color(0xFFFFC857),
  ),
  FinderBadge(
    id: 'badge_games_15', title: 'Bright Explorer', titleMalay: 'Penjelajah Cerah',
    description: 'Completed 15 challenges!', descriptionMalay: 'Siapkan 15 cabaran!',
    condition: BadgeCondition.completedChallenges, requiredCount: 15,
    icon: Icons.lightbulb_rounded, color: Color(0xFF4ECDC4),
  ),
  FinderBadge(
    id: 'badge_games_30', title: 'Super Spotter', titleMalay: 'Pengesan Super',
    description: 'Completed 30 challenges!', descriptionMalay: 'Siapkan 30 cabaran!',
    condition: BadgeCondition.completedChallenges, requiredCount: 30,
    icon: Icons.visibility_rounded, color: Color(0xFFFF6B6B),
  ),
  FinderBadge(
    id: 'badge_games_60', title: 'Tiny Champion', titleMalay: 'Juara Cilik',
    description: 'Completed 60 challenges!', descriptionMalay: 'Siapkan 60 cabaran!',
    condition: BadgeCondition.completedChallenges, requiredCount: 60,
    icon: Icons.workspace_premium_rounded, color: Color(0xFF7E57C2),
  ),

  // ── Streaks ────────────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_streak_3', title: '3-Day Hero!', titleMalay: 'Wira 3 Hari!',
    description: '3-day learning streak!', descriptionMalay: 'Belajar 3 hari berturut-turut!',
    condition: BadgeCondition.streak, requiredCount: 3,
    icon: Icons.local_fire_department_rounded, color: Color(0xFFFF9F43),
  ),
  FinderBadge(
    id: 'badge_streak_7', title: 'Week Warrior', titleMalay: 'Pejuang Minggu',
    description: '7-day learning streak!', descriptionMalay: 'Belajar 7 hari berturut-turut!',
    condition: BadgeCondition.streak, requiredCount: 7,
    icon: Icons.whatshot_rounded, color: Color(0xFFFF6B6B),
  ),
  FinderBadge(
    id: 'badge_streak_30', title: 'Monthly Master', titleMalay: 'Master Bulanan',
    description: '30-day learning streak!', descriptionMalay: 'Belajar 30 hari berturut-turut!',
    condition: BadgeCondition.streak, requiredCount: 30,
    icon: Icons.emoji_events_rounded, color: Color(0xFFFFD700),
  ),

  // ── Level Badges ───────────────────────────────────────────────────
  FinderBadge(
    id: 'badge_level_3', title: 'Rising Star', titleMalay: 'Bintang Muda',
    description: 'Reached Level 3!', descriptionMalay: 'Capai Tahap 3!',
    condition: BadgeCondition.level, requiredCount: 3,
    icon: Icons.trending_up_rounded, color: Color(0xFFFFD21E),
  ),
  FinderBadge(
    id: 'badge_level_5', title: 'Champion!', titleMalay: 'Juara!',
    description: 'Reached Level 5!', descriptionMalay: 'Capai Tahap 5!',
    condition: BadgeCondition.level, requiredCount: 5,
    icon: Icons.military_tech_rounded, color: Color(0xFFFF9F43),
  ),
  FinderBadge(
    id: 'badge_level_10', title: 'Ultimate Master', titleMalay: 'Master Terunggul',
    description: 'Reached the highest level!', descriptionMalay: 'Capai tahap tertinggi!',
    condition: BadgeCondition.level, requiredCount: 10,
    icon: Icons.emoji_events_rounded, color: Color(0xFFFFD700),
  ),
];
