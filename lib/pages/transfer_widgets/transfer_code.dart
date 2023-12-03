import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../gen/ffi.dart';
import '../../settings/settings.dart';
import '../../widgets/fast_future_builder.dart';
import '../toasts/info_toast.dart';
import '../type_helpers.dart';
import 'transfer_connecting.dart';

class TransferCode extends StatefulWidget {
  const TransferCode({super.key, required this.data});

  final TUpdate data;

  @override
  State<TransferCode> createState() => _TransferCodeState();
}

class _TransferCodeState extends State<TransferCode> {
  bool qrcodevisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FastFutureBuilder<List<dynamic>>(
      future: Future.wait(
          [Settings.getCodeAlwaysVisible(), Settings.getCodeType()]),
      onData: (data) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (qrcodevisible || data[0]) ...[
                _buildQRCode(widget.data.getValue(), data[1]),
                const SizedBox(
                  height: 30,
                )
              ],
              Text(AppLocalizations.of(context)!.transfer_code_label),
              SelectableText(
                widget.data.getValue(),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () => _showHelpDialog(),
                      icon: const Icon(Icons.help_outline)),
                  IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.data.getValue()));
                        if (mounted) {
                          InfoToast(
                            message: AppLocalizations.of(context)!
                                .toast_info_passphrase_copy,
                          ).show(context);
                        }
                      },
                      icon: const Icon(Icons.copy)),
                  if (!data[0])
                    IconButton(
                      onPressed: () {
                        setState(() {
                          qrcodevisible = !qrcodevisible;
                        });
                      },
                      icon: const Icon(Icons.qr_code),
                    )
                ],
              )
            ],
          ),
        );
      },
      loadWidget: const TransferConnecting(),
    );
  }

  Widget _buildQRCode(String code, CodeType codeType) {
    final theme = Theme.of(context);

    // the built in qr scanner doesn't support scanning of
    // inverted aztec codes -> so we need to invert colors when in dark theme

    Color color = theme.iconTheme.color ?? Colors.black;
    Color? backgroundColor;

    return FastFutureBuilder<String>(
        future: api.getPassphraseUri(passphrase: widget.data.getValue()),
        onData: (data) {
          return BarcodeWidget(
            data: data,
            barcode: codeType == CodeType.qrCode
                ? Barcode.qrCode()
                : Barcode.aztec(),
            color: color,
            backgroundColor: backgroundColor,
            height: 200,
            width: 200,
          );
        });
  }

  void _showHelpDialog() {
    final text = AppLocalizations.of(context)!.transfer_code_help;
    final textParts = text.split('<link>');

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.transfer_code_help_title),
          content: SizedBox(
            width: 250,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: textParts.first,
                      style: Theme.of(context).textTheme.bodyMedium),
                  TextSpan(
                    text: 'Warp',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                            Uri.parse(
                                'https://apps.gnome.org/app/app.drey.Warp/'),
                            mode: LaunchMode.externalApplication);
                      },
                  ),
                  TextSpan(text: textParts.last)
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
