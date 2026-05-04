enum AppLanguage { english, malay, mandarin, tamil }

extension AppLanguageDetails on AppLanguage {
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
    }
  }

  static AppLanguage fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }
    return AppLanguage.english;
  }
}
