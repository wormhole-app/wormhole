// generated RustLibApi member names
// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wormhole/l10n/app_localizations.dart';
import 'package:wormhole/pages/transfer_widgets/transfer_code.dart';
import 'package:wormhole/src/rust/api/wormhole.dart';
import 'package:wormhole/src/rust/frb_generated.dart';
import 'package:wormhole/theme/theme_provider.dart';

/// Only the link of a code; any other call fails the test.
class _MockRustLibApi implements RustLibApi {
  @override
  Future<String> crateApiWormholeGetPassphraseUri(
          {required String passphrase,
          String? rendezvousServer,
          required bool isLeader}) =>
      Future.value(
          'wormhole-transfer:$passphrase${isLeader ? '?role=leader' : ''}');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockRustLibApi()));

  // show the QR code right away
  setUp(() => SharedPreferences.setMockInitialValues({'CODEALVISIBLE': true}));

  Future<void> pumpCode(WidgetTester tester, {bool isReceiver = false}) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TransferCode(
            data: const TUpdate(
                event: Events.code, value: Value.string('7-guitarist-revenge')),
            isReceiver: isReceiver,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  String qrData(WidgetTester tester) => utf8
      .decode(tester.widget<BarcodeWidget>(find.byType(BarcodeWidget)).data);

  testWidgets('a sender code is for the receiver to receive from',
      (tester) async {
    await pumpCode(tester);

    expect(find.text('Your transmit code is:'), findsOneWidget);
    expect(qrData(tester), 'wormhole-transfer:7-guitarist-revenge');

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('The receiver needs to enter or scan the code',
            findRichText: true),
        findsOneWidget);
  });

  testWidgets('a receiver code asks whoever scans it to send', (tester) async {
    await pumpCode(tester, isReceiver: true);

    expect(find.text('Give this code to the sender:'), findsOneWidget);
    expect(qrData(tester), 'wormhole-transfer:7-guitarist-revenge?role=leader');

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('The sender needs to scan or enter the code',
            findRichText: true),
        findsOneWidget);
  });
}
