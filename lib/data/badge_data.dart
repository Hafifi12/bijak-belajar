import 'package:flutter/material.dart';

import '../models/badge.dart';

const badges = <FinderBadge>[
  FinderBadge(
    id: 'badge_first_five',
    title: 'First Finder',
    description: 'Completed 5 challenges',
    requiredChallenges: 5,
    icon: Icons.travel_explore_rounded,
    color: Color(0xFFFFC857),
  ),
  FinderBadge(
    id: 'badge_ten',
    title: 'Bright Explorer',
    description: 'Completed 10 challenges',
    requiredChallenges: 10,
    icon: Icons.lightbulb_rounded,
    color: Color(0xFF4ECDC4),
  ),
  FinderBadge(
    id: 'badge_twenty',
    title: 'Super Spotter',
    description: 'Completed 20 challenges',
    requiredChallenges: 20,
    icon: Icons.visibility_rounded,
    color: Color(0xFFFF6B6B),
  ),
  FinderBadge(
    id: 'badge_forty',
    title: 'Tiny Champion',
    description: 'Completed 40 challenges',
    requiredChallenges: 40,
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFF7E57C2),
  ),
];
