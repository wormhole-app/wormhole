import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wormhole/l10n/app_localizations.dart';
import 'package:wormhole/locale/locale_provider.dart';
import 'package:wormhole/pages/receive_page.dart';
import 'package:wormhole/pages/send_page.dart';
import 'package:wormhole/pages/settings/settings_page.dart';
import 'package:wormhole/pages/transfer_widgets/transfer_code.dart';
import 'package:wormhole/pages/transfer_widgets/transfer_finished.dart';
import 'package:wormhole/pages/transfer_widgets/transfer_progress.dart';
import 'package:wormhole/src/rust/api/wormhole.dart';
import 'package:wormhole/src/rust/frb_generated.dart';
import 'package:wormhole/theme/dark_theme.dart';
import 'package:wormhole/theme/light_theme.dart';
import 'package:wormhole/theme/theme_provider.dart';
import 'package:wormhole/transfer/transfer_provider.dart';

class _MockRustLibApi implements RustLibApi {
  @override
  Future<String> crateApiWormholeGetPassphraseUri(
          {required String passphrase, String? rendezvousServer}) =>
      Future.value('wormhole-transfer:$passphrase');

  @override
  Future<String> crateApiWormholeDefaultRendezvousUrl() =>
      throw UnimplementedError();
  @override
  Future<String> crateApiWormholeDefaultTransitUrl() =>
      throw UnimplementedError();
  @override
  Future<BuildInfo> crateApiWormholeGetBuildInfo() {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s+(\S+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1)!
        .split('+')
        .first;
    return Future.value(BuildInfo(devBuild: false, version: version));
  }

  @override
  Future<void> crateApiWormholeInit({required String tempFilePath}) =>
      throw UnimplementedError();
  @override
  Stream<TUpdate> crateApiWormholeRequestFile(
          {required String passphrase,
          required String storageFolder,
          required ServerConfig serverConfig}) =>
      throw UnimplementedError();
  @override
  Stream<TUpdate> crateApiWormholeSendFiles(
          {required List<String> filePaths,
          required String name,
          required int codeLength,
          required ServerConfig serverConfig}) =>
      throw UnimplementedError();
  @override
  Stream<TUpdate> crateApiWormholeSendFolder(
          {required String folderPath,
          required String name,
          required int codeLength,
          required ServerConfig serverConfig}) =>
      throw UnimplementedError();
  @override
  Stream<LogEntry> crateApiWormholeSetupLogStream() =>
      throw UnimplementedError();
}

// iPhone 13 Pro: 1170×2532 physical pixels at 3x (390×844 logical)
const _iphone13Pro = ScreenshotDevice(
  platform: TargetPlatform.iOS,
  resolution: Size(1170, 2532),
  pixelRatio: 3,
  goldenSubFolder: 'iphoneScreenshots/',
  frameBuilder: ScreenshotFrame.iphone,
);

// Google Pixel 5: 1170×2532 physical pixels (same as the iPhone, as there is not good Android device)
const _androidPhone = ScreenshotDevice(
  platform: TargetPlatform.android,
  resolution: Size(1170, 2532),
  pixelRatio: 3,
  goldenSubFolder: 'phoneScreenshots/',
  frameBuilder: ScreenshotFrame.androidPhone,
);

// iPad Mini 2019: 1536×2048 physical pixels at 2x (768×1024 logical)
const _android7Portrait = ScreenshotDevice(
  platform: TargetPlatform.android,
  resolution: Size(1536, 2048),
  pixelRatio: 2,
  goldenSubFolder: 'sevenInchScreenshots/',
  frameBuilder: ScreenshotFrame.androidTablet,
);

// iPad Pro 13" (M4): App Store Connect accepts 2048×2732 for the "iPad 13" Display" slot.
// 2064×2752 (the M4's native size) is not yet recognized by frameit.
const _ipad = ScreenshotDevice(
  platform: TargetPlatform.iOS,
  resolution: Size(2048, 2732),
  pixelRatio: 2,
  goldenSubFolder: 'ipadScreenshots/',
  frameBuilder: ScreenshotFrame.ipad,
);

// iPad Pro 12.9": 2048×2732 physical pixels at 2x (1024×1366 logical)
const _android10Portrait = ScreenshotDevice(
  platform: TargetPlatform.android,
  resolution: Size(2048, 2732),
  pixelRatio: 2,
  goldenSubFolder: 'tenInchScreenshots/',
  frameBuilder: ScreenshotFrame.androidTablet,
);

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    RustLib.initMock(api: _MockRustLibApi());
  });

  group('android', () {
    setUpAll(() {
      // Outputs to android/fastlane/metadata/android/en-US/images/{phoneScreenshots,sevenInchScreenshots,tenInchScreenshots}/
      ScreenshotDevice.screenshotsFolder =
          '../../android/fastlane/metadata/android/\$langCode/images/';
    });

    for (final (device, name) in [
      (_androidPhone, 'androidPhone'),
      (_android7Portrait, 'android7Portrait'),
      (_android10Portrait, 'android10Portrait'),
    ]) {
      _screenshotGroup(
          device, name, Brightness.light, const Locale('en', 'US'));
      _screenshotGroup(device, name, Brightness.dark, const Locale('en', 'US'));
    }
  });

  group('ios', () {
    setUpAll(() {
      // Outputs to ios/fastlane/screenshots/{en-US,de-DE}/{iphoneScreenshots,ipadScreenshots}/
      ScreenshotDevice.screenshotsFolder =
          '../../ios/fastlane/screenshots/\$langCode/';
    });

    for (final (locale) in [
      (const Locale('en', 'US')),
      (const Locale('de', 'DE')),
    ]) {
      for (final (device, name) in [
        (_iphone13Pro, 'iphone13Pro'),
        (_ipad, 'ipad'),
      ]) {
        _screenshotGroup(device, name, Brightness.light, locale);
        _screenshotGroup(device, name, Brightness.dark, locale);
      }
    }
  });
}

void _screenshotGroup(ScreenshotDevice device, String deviceName,
    Brightness brightness, Locale locale) {
  final suffix = brightness == Brightness.dark ? '_dark' : '';
  testGoldens(
      'screenshots on $deviceName $brightness ${locale.toLanguageTag()}',
      (tester) async {
    await _screenshot(
        tester, device, '1_send$suffix', const SendPage(), brightness, locale);
    await _screenshot(tester, device, '2_receive$suffix', const ReceivePage(),
        brightness, locale);
    await _screenshot(
      tester,
      device,
      '3_transfer_code$suffix',
      const TransferCode(
        data: TUpdate(
          event: Events.code,
          value: Value.string('946-millionaire-island'),
        ),
      ),
      brightness,
      locale,
      extraPrefs: const {'CODEALVISIBLE': true},
    );
    await _screenshot(
      tester,
      device,
      '4_transfer_progress$suffix',
      TransferProgress(
        data: TUpdate(
          event: Events.sent,
          value: Value.int(BigInt.from(524288)),
        ),
        total: BigInt.from(1048576),
      ),
      brightness,
      locale,
    );
    await _screenshot(tester, device, '5_settings$suffix', const SettingsPage(),
        brightness, locale);
    await _screenshot(
      tester,
      device,
      '6_transfer_finished$suffix',
      const ReceiveFinished(file: '/storage/emulated/0/Downloads/photo.jpg'),
      brightness,
      locale,
    );
  });
}

/// Pumps [page] inside a full app shell and takes a screenshot named [filename].
Future<void> _screenshot(
  WidgetTester tester,
  ScreenshotDevice device,
  String filename,
  Widget page,
  Brightness brightness,
  Locale locale, {
  Map<String, Object> extraPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(extraPrefs);
  await tester.pumpWidget(_buildApp(device, page, brightness, locale));
  await tester.loadAssets();
  await tester.pumpFrames(
    tester.widget(find.byType(ScreenshotApp)),
    const Duration(seconds: 1),
  );
  await tester.expectScreenshot(device, filename,
      langCode: locale.toLanguageTag());
}

Widget _buildApp(ScreenshotDevice device, Widget page, Brightness brightness,
    Locale locale) {
  return ScreenshotApp(
    device: device,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()
            ..theme = (brightness == Brightness.dark
                ? ThemeType.dark
                : ThemeType.light),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
      ],
      child: _AppShell(page: page),
    ),
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.upload),
            label: loc.menu_send,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.download),
            label: loc.menu_receive,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: loc.menu_settings,
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
      ),
      body: page,
    );
  }
}
