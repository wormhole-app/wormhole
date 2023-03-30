import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../navigation/back_pop_context.dart';
import '../navigation/navigation_provider.dart';
import '../transfer/transfer_provider.dart';
import 'toasts/error_toast.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  void _onQrDetect(String? code, BuildContext context) async {
    if (code != null) {
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

  Widget zXingWidget(BuildContext ctx) {
    return ReaderWidget(
      onScan: (result) async {
        _onQrDetect(result.text, ctx);
      },
    );
  }

  Widget googleWidget(BuildContext ctx) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final b = capture.barcodes;
            if (b.isNotEmpty && b.first.rawValue != null) {
              _onQrDetect(b.first.rawValue, ctx);
            } else {
              _onQrDetect(null, ctx);
            }
          },
        ),
        Center(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.8,
            height: MediaQuery.of(ctx).size.width * 0.8,
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

  @override
  Widget build(BuildContext context) {
    const bool zxing = true;
    return BackPopContext(
        child: zxing ? zXingWidget(context) : googleWidget(context));
  }
}
