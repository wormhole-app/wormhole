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
          final params = uri.queryParameters;
          if(params.containsKey('rendezvous')) {
            final rendezvousServer = params['rendezvous']!;
            final _rendezvousUri = Uri.parse(rendezvousServer);
            // todo use this rendezvous server encoded in qr code
          }

          if(params.containsKey('role')){
            switch(params['role']) {
              case 'follower':
                Provider.of<TransferProvider>(context, listen: false)
                    .receiveFile(passphrase);
                break;
              case 'leader':
                // todo we want to send file/s -> so open filechooser
                  // then we want send with code
                break;
              default:
                break;
            }
          } else {
            Provider.of<TransferProvider>(context, listen: false)
                .receiveFile(passphrase);
          }

          return;
        }
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
