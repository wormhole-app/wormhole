import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wormhole/l10n/app_localizations.dart';
import 'package:wormhole/pages/send_page.dart';
import 'package:wormhole/transfer/send_target.dart';
import 'package:wormhole/transfer/transfer_provider.dart';
import 'package:wormhole/utils/logger.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // The page logs its sends; the logger writes to path_provider's support
    // directory, so give it a temporary one.
    final logDir = Directory.systemTemp.createTempSync('wormhole_test_logs');
    messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => logDir.path);
    await AppLogger.initialize();
    // "Select File" picks this one file
    messenger.setMockMethodCallHandler(
        const MethodChannel('miguelruivo.flutter.plugins.filepicker'),
        (call) async => [
              {'name': 'a.epub', 'path': '/tmp/a.epub', 'size': 1}
            ]);
  });

  late SendTarget target;
  late TransferProvider transfer;
  late List<(String, String?)> sentFiles;

  setUp(() {
    target = SendTarget();
    transfer = TransferProvider();
    sentFiles = [];
    transfer
        .addOnSendListener((name, paths, code) => sentFiles.add((name, code)));
  });

  Future<void> pumpSendPage(WidgetTester tester) async {
    // tall enough that every action is an inline button
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: target),
        ChangeNotifierProvider.value(value: transfer),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SendPage()),
      ),
    ));
  }

  Future<void> typeCode(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  bool continueEnabled(WidgetTester tester) => tester
      .widget<ButtonStyleButton>(find.ancestor(
          of: find.text('Continue'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton)))
      .enabled;

  group('send target banner', () {
    testWidgets('is hidden without a target', (tester) async {
      await pumpSendPage(tester);

      expect(find.textContaining('Sending to'), findsNothing);
    });

    testWidgets('shows the target, and its close button clears it',
        (tester) async {
      target.code = '7-guitarist-revenge';
      await pumpSendPage(tester);
      expect(find.text('Sending to 7-guitarist-revenge'), findsOneWidget);

      await tester.tap(find.byTooltip("Don't send to this code"));
      await tester.pump();

      expect(target.code, isNull);
      expect(find.text('Sending to 7-guitarist-revenge'), findsNothing);
    });

    testWidgets('a send takes the target', (tester) async {
      target.code = '7-guitarist-revenge';
      await pumpSendPage(tester);

      await tester.tap(find.text('Select File'));
      await tester.pumpAndSettle();

      expect(sentFiles, [('a.epub', '7-guitarist-revenge')]);
      expect(target.code, isNull);
      expect(find.textContaining('Sending to'), findsNothing);
    });
  });

  group('Send to a Code', () {
    testWidgets('is an outlined button, unlike the send actions',
        (tester) async {
      await pumpSendPage(tester);

      Finder buttonWith(String text) => find.ancestor(
          of: find.text(text),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));

      expect(
          tester.widget(buttonWith('Send to a Code')), isA<OutlinedButton>());
      expect(tester.widget(buttonWith('Select File')), isA<FilledButton>());
    });

    testWidgets('sets the target from a typed code', (tester) async {
      await pumpSendPage(tester);
      await tester.tap(find.text('Send to a Code'));
      await tester.pumpAndSettle();

      await typeCode(tester, '7');
      expect(continueEnabled(tester), isFalse);

      // a space becomes a dash, like on the receive page
      await typeCode(tester, '7 guitarist revenge');
      expect(find.text('7-guitarist-revenge'), findsOneWidget);
      expect(continueEnabled(tester), isTrue);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(target.code, '7-guitarist-revenge');
      expect(find.text('Sending to 7-guitarist-revenge'), findsOneWidget);
      expect(sentFiles, isEmpty);
    });

    testWidgets('ignores a trailing space', (tester) async {
      await pumpSendPage(tester);
      await tester.tap(find.text('Send to a Code'));
      await tester.pumpAndSettle();

      await typeCode(tester, '7-guitarist-revenge ');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(target.code, '7-guitarist-revenge');
    });

    testWidgets('only takes codes that start with digits', (tester) async {
      await pumpSendPage(tester);
      await tester.tap(find.text('Send to a Code'));
      await tester.pumpAndSettle();

      await typeCode(tester, 'guitarist');

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
      expect(continueEnabled(tester), isFalse);
    });
  });
}
