import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../transfer/transfer_provider.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
            allowDuplicates: false,
            onDetect: (barcode, args) async {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
                // todo show some error page
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');
                Vibration.vibrate();

                // assume its a valid code if it starts with this string
                if (code.startsWith('wormhole-transfer:')) {
                  Provider.of<TransferProvider>(context, listen: false)
                      .receiveFile(code.substring(18));
                } else {
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
    );
  }
}
