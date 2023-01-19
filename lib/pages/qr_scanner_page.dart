import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../navigation/back_pop_context.dart';
import '../navigation/navigation_provider.dart';
import '../transfer/transfer_provider.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackPopContext(
      child: Stack(
        children: [
          MobileScanner(
              allowDuplicates: false,
              onDetect: (barcode, args) async {
                if (barcode.rawValue == null) {
                  debugPrint('Failed to scan Barcode');
                  Provider.of<NavigationProvider>(context, listen: false).pop();
                  // todo show some error page
                } else {
                  final String code = barcode.rawValue!;
                  debugPrint('Barcode found! $code');
                  Vibration.vibrate();

                  final uri = Uri.parse(code);

                  // assume its a valid code if it starts with this string
                  if (uri.scheme == 'wormhole-transfer') {
                    final passphrase = uri.path;
                    Provider.of<TransferProvider>(context, listen: false)
                        .receiveFile(passphrase);
                    // todo handle extra query parameters
                  } else {
                    Provider.of<NavigationProvider>(context, listen: false)
                        .pop();
                    // todo show some error page
                  }
                }
              }),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.white38, width: 4.0),
                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
