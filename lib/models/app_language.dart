enum AppLanguage { english, malay, mandarin, tamil, indonesian }

extension AppLanguageDetails on AppLanguage {
  /// Indonesian shares most of its vocabulary with Malay. Screens that only
  /// have Malay copy show it to Indonesian users rather than English.
  bool get usesMalayCopy =>
      this == AppLanguage.malay || this == AppLanguage.indonesian;

  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.malay:
        return 'ms';
      case AppLanguage.mandarin:
        return 'zh';
      case AppLanguage.tamil:
        return 'ta';
      case AppLanguage.indonesian:
        return 'id';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.malay:
        return 'Malay';
      case AppLanguage.mandarin:
        return 'Mandarin';
      case AppLanguage.tamil:
        return 'Tamil';
      case AppLanguage.indonesian:
        return 'Indonesian';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.malay:
        return 'Bahasa Melayu';
      case AppLanguage.mandarin:
        return '中文';
      case AppLanguage.tamil:
        return 'தமிழ்';
      case AppLanguage.indonesian:
        return 'Bahasa Indonesia';
    }
  }

  String get ttsLocale {
    switch (this) {
      case AppLanguage.english:
        return 'en-US';
      case AppLanguage.malay:
        return 'ms-MY';
      case AppLanguage.mandarin:
        return 'zh-CN';
      case AppLanguage.tamil:
        return 'ta-IN';
      case AppLanguage.indonesian:
        return 'id-ID';
    }
  }

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'ms':
        return AppLanguage.malay;
      case 'en':
        return AppLanguage.english;
      case 'zh':
        return AppLanguage.mandarin;
      case 'ta':
        return AppLanguage.tamil;
      case 'id':
        return AppLanguage.indonesian;
      default:
        // Malaysian-first product: Bahasa Melayu is the default experience
        // for new installs; parents can switch in Settings.
        return AppLanguage.malay;
    }
  }
}

/// Picks the copy for the child's language. Indonesian uses the Malay copy.
extension AppLanguageCopy on AppLanguage {
  String copy({
    required String ms,
    required String en,
    required String zh,
    required String ta,
  }) {
    return switch (this) {
      AppLanguage.malay || AppLanguage.indonesian => ms,
      AppLanguage.english => en,
      AppLanguage.mandarin => zh,
      AppLanguage.tamil => ta,
    };
  }
}
