import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wormhole/l10n/app_localizations.dart';
import 'package:wormhole/navigation/navigation.dart';
import 'package:wormhole/transfer/send_target.dart';
import 'package:wormhole/transfer/transfer_provider.dart';
import 'package:wormhole/transfer/transfer_receiver.dart';

void main() {
  late SendTarget target;
  late List<AppTab> shownTabs;
  late BuildContext childContext;

  Future<void> pumpReceiver(WidgetTester tester,
      {required bool sendRunning}) async {
    target = SendTarget();
    shownTabs = [];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider.value(
        value: target,
        child: TransferReceiver(
          pushPage: (tab, page) {},
          showTab: shownTabs.add,
          isTransferRunning: (tab) => sendRunning && tab == AppTab.send,
          child: Builder(builder: (context) {
            childContext = context;
            return const SizedBox();
          }),
        ),
      ),
    ));
  }

  void scanLeaderCode(String code) =>
      Provider.of<TransferProvider>(childContext, listen: false)
          .setSendTarget(code);

  group('send target from a QR code or link', () {
    testWidgets('a receiver code opens the send tab with it as target',
        (tester) async {
      await pumpReceiver(tester, sendRunning: false);

      scanLeaderCode('7-guitarist-revenge');
      await tester.pump();

      expect(shownTabs, [AppTab.send]);
      expect(target.code, '7-guitarist-revenge');
    });

    testWidgets('a receiver code while a send runs only shows a hint',
        (tester) async {
      await pumpReceiver(tester, sendRunning: true);

      scanLeaderCode('7-guitarist-revenge');
      await tester.pump();

      expect(shownTabs, isEmpty);
      expect(target.code, isNull);
      expect(find.text('Finish or cancel the current transfer first'),
          findsOneWidget);
      // let the toast's timers run out
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
