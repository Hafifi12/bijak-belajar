import 'package:flutter/material.dart';

import 'challenge.dart';

enum TrainMode { numbers, letters }

extension TrainModeDetails on TrainMode {
  ChallengeMode get challengeMode {
    switch (this) {
      case TrainMode.numbers:
        return ChallengeMode.numberTrain;
      case TrainMode.letters:
        return ChallengeMode.letterTrain;
    }
  }

  IconData get icon {
    switch (this) {
      case TrainMode.numbers:
        return Icons.looks_one_rounded;
      case TrainMode.letters:
        return Icons.abc_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TrainMode.numbers:
        return const Color(0xFF00A896);
      case TrainMode.letters:
        return const Color(0xFF277DA1);
    }
  }
}
