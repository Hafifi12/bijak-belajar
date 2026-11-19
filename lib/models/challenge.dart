import 'package:flutter/material.dart';

enum ChallengeMode {
  color,
  shape,
  object,
  sound,
  findExplorer,
  numberTrain,
  letterTrain,
  memory,
  puzzle,
}

enum ShapeKind {
  circle,
  square,
  triangle,
  rectangle,
  star,
  heart,
  oval,
  diamond,
}

extension ChallengeModeLabels on ChallengeMode {
  String get storageKey {
    switch (this) {
      case ChallengeMode.color:
        return 'color';
      case ChallengeMode.shape:
        return 'shape';
      case ChallengeMode.object:
        return 'object';
      case ChallengeMode.sound:
        return 'sound';
      case ChallengeMode.findExplorer:
        return 'find_explorer';
      case ChallengeMode.numberTrain:
        return 'number_train';
      case ChallengeMode.letterTrain:
        return 'letter_train';
      case ChallengeMode.memory:
        return 'memory';
      case ChallengeMode.puzzle:
        return 'puzzle';
    }
  }
}

class Challenge {
  const Challenge({
    required this.id,
    required this.mode,
    required this.title,
    required this.prompt,
    required this.targetLabel,
    this.displayColor,
    this.icon,
    this.shapeKind,
    this.soundAsset,
  });

  final String id;
  final ChallengeMode mode;
  final String title;
  final String prompt;
  final String targetLabel;
  final Color? displayColor;
  final IconData? icon;
  final ShapeKind? shapeKind;
  final String? soundAsset;
}
