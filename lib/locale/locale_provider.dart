import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../settings/settings.dart';

enum LanguageType { system, de, en, et, pt, sv, uk }

class LocaleProvider with ChangeNotifier {
  // Native language names - displayed in their native form universally, and thus not localized
  static const Map<LanguageType, String> nativeLanguageNames = {
    LanguageType.de: 'Deutsch',
    LanguageType.en: 'English',
    LanguageType.et: 'Eesti',
    LanguageType.pt: 'Português',
    LanguageType.sv: 'Svenska',
    LanguageType.uk: 'Українська',
  };

  static String getLanguageDisplayName(
      LanguageType language, BuildContext context) {
    if (language == LanguageType.system) {
      return AppLocalizations.of(context)!.settings_page_system_language;
    }
    final name = nativeLanguageNames[language];
    assert(name != null, 'Missing native language name for $language');
    return name ?? 'Unknown language';
  }

  LanguageType _language = LanguageType.system;

  LanguageType get language => _language;

  set language(LanguageType language) {
    _language = language;
    Settings.setLanguage(language);
    notifyListeners();
  }

  Locale? getLocale() {
    if (_language == LanguageType.system) {
      return null; // Let the system decide
    }
    return Locale(_language.name);
  }
}
