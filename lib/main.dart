import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'src/rust/api/wormhole.dart';
import 'src/rust/frb_generated.dart';
import 'navigation/navigation.dart';
import 'settings/settings.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'theme/theme_provider.dart';
import 'utils/logger.dart';

Future<void> main() async {
  // Run app with global error logging
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppLogger.initialize();

    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) AppLogger.debug(message);
    };

    await RustLib.init();

    // Setup Rust logging bridge
    await setupRustLogger();

    AppLogger.info('Application starting');
    runApp(const MyApp());
  }, (error, stackTrace) {
    AppLogger.error('Uncaught error: $error');
    AppLogger.error('Stack trace: $stackTrace');
  });
}

/// Setup Rust logger to bridge Rust logs into Flutter logging system
Future<void> setupRustLogger() async {
  try {
    setupLogStream().listen((logEntry) {
      // Map Rust log levels to Flutter AppLogger
      final message = '[Rust:${logEntry.lbl}] ${logEntry.msg}';

      switch (logEntry.logLevel) {
        case Level.error:
          AppLogger.error(message);
          break;
        case Level.warn:
          AppLogger.warn(message);
          break;
        case Level.info:
          AppLogger.info(message);
          break;
        case Level.debug:
        case Level.trace:
          AppLogger.debug(message);
          break;
      }
    }, onError: (error) {
      AppLogger.error('Rust log stream error: $error');
    });
    AppLogger.info('Rust logger initialized');
  } catch (e) {
    AppLogger.error('Failed to setup Rust logger: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeChangeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    initBackend();
  }

  void initBackend() async {
    final tempDir = (await getTemporaryDirectory()).path;
    init(tempFilePath: tempDir);
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
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (supportedLocales
                  .map((e) => e.languageCode)
                  .contains(deviceLocale?.languageCode)) {
                return deviceLocale;
              }
              AppLogger.info('Fallback to default locale');
              return const Locale('en');
            },
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeChangeProvider.isDarkThemeActive()
                ? ThemeMode.dark
                : ThemeMode.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Navigation(),
          );
        },
      ),
    );
  }
}
