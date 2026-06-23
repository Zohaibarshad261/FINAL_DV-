import 'package:flutter/foundation.dart';

class LanguageService {
  LanguageService._();

  static final ValueNotifier<String> language = ValueNotifier('en');

  static const Map<String, String> names = {
    'en': 'English',
    'ur': 'Urdu',
    'hi': 'Hindi',
  };

  static bool get isEnglish => language.value == 'en';
}
