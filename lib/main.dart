import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'gen/ffi.dart';
import 'navigation/navigation.dart';
import 'settings/settings.dart';
import 'theme/dark_theme_provider.dart';
import 'theme/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    initBackend();
  }

  void initBackend() async {
    final tempDir = (await getTemporaryDirectory()).path;
    api.init(tempFilePath: tempDir);
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.theme = await Settings.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (supportedLocales
                  .map((e) => e.languageCode)
                  .contains(deviceLocale?.languageCode)) {
                return deviceLocale;
              }
              debugPrint('fallback to default locale');
              return const Locale('en');
            },
            theme: Styles.themeData(
                themeChangeProvider.isDarkThemeActive(), context),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Navigation(),
          );
        },
      ),
    );
  }
}
