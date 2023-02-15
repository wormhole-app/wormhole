import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../navigation/back_pop_context.dart';
import '../navigation/navigation_provider.dart';
import '../transfer/transfer_provider.dart';
import 'toasts/error_toast.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  void _onQrDetect(List<Barcode> barcode, BuildContext context) async {
    if (barcode.isNotEmpty && barcode.first.rawValue != null) {
      final String code = barcode.first.rawValue!;
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
        Provider.of<NavigationProvider>(context, listen: false).pop();
        ErrorToast(message: AppLocalizations.of(context).toast_error_qr_invalid)
            .show(context);
      }
    } else {
      debugPrint('Failed to scan Barcode');
      Provider.of<NavigationProvider>(context, listen: false).pop();
      ErrorToast(message: AppLocalizations.of(context).toast_error_qr_fail)
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackPopContext(
      child: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) => _onQrDetect(capture.barcodes, context),
          ),
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
