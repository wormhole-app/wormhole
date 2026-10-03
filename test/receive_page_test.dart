import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wormhole/l10n/app_localizations.dart';
import 'package:wormhole/pages/receive_page.dart';
import 'package:wormhole/transfer/transfer_provider.dart';

void main() {
  late TransferProvider transfer;
  late List<String?> received;

  setUp(() {
    transfer = TransferProvider();
    received = [];
    transfer.addOnReceiveListener(received.add);
  });

  Future<void> pumpReceivePage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: transfer,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ReceivePage()),
      ),
    ));
  }

  Finder buttonWith(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));

  testWidgets('receives with the typed code', (tester) async {
    await pumpReceivePage(tester);

    await tester.enterText(find.byType(TextField), '7-guitarist-revenge');
    await tester.tap(buttonWith('Receive File'));
    await tester.pump();

    expect(received, ['7-guitarist-revenge']);
  });

  group('Receive with My Code', () {
    testWidgets('is an outlined button, unlike Receive File', (tester) async {
      await pumpReceivePage(tester);

      expect(tester.widget(buttonWith('Receive with My Code')),
          isA<OutlinedButton>());
      expect(tester.widget(buttonWith('Receive File')), isA<FilledButton>());
    });

    testWidgets('receives without a code, so a new one is made',
        (tester) async {
      await pumpReceivePage(tester);

      await tester.tap(find.text('Receive with My Code'));
      await tester.pump();

      expect(received, [null]);
    });
  });
}
