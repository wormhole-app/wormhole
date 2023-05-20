import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../navigation/back_pop_context.dart';
import '../navigation/navigation_provider.dart';
import '../transfer/transfer_provider.dart';
import '../utils/code.dart';
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

        if (isCodeValid(passphrase)) {
          Provider.of<TransferProvider>(context, listen: false)
              .receiveFile(passphrase);
          return;
        }
        // todo handle extra query parameters
      }

      Provider.of<NavigationProvider>(context, listen: false).pop();
      ErrorToast(message: AppLocalizations.of(context).toast_error_qr_invalid)
          .show(context);
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
      child: ReaderWidget(
        tryInverted: true,
        onScan: (result) async {
          _onQrDetect(result.text, context);
        },
      ),
    );
  }
}
