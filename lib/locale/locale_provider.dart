import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../settings/settings.dart';

enum LanguageType {
  system,
  de,
  et,
  en,
  es,
  fr,
  it,
  nl,
  pt,
  sv,
  kab,
  tr,
  uk,
  ru,
  zhHans,
}

class LocaleProvider with ChangeNotifier {
  // Native language names - displayed in their native form universally, and thus not localized
  static const Map<LanguageType, String> nativeLanguageNames = {
    LanguageType.de: 'Deutsch',
    LanguageType.et: 'Eesti',
    LanguageType.en: 'English',
    LanguageType.es: 'Español',
    LanguageType.fr: 'Français',
    LanguageType.it: 'Italiano',
    LanguageType.nl: 'Nederlands',
    LanguageType.pt: 'Português',
    LanguageType.sv: 'Svenska',
    LanguageType.kab: 'Taqbaylit',
    LanguageType.tr: 'Türkçe',
    LanguageType.uk: 'Українська',
    LanguageType.ru: 'Русский',
    LanguageType.zhHans: '简体中文',
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
    if (_language == LanguageType.zhHans) {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
    }
    return Locale(_language.name);
  }
}
