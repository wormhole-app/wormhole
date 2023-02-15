import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../gen/ffi.dart';
import '../../settings/settings.dart';
import '../toasts/info_toast.dart';
import '../type_helpers.dart';
import 'transfer_connecting.dart';

class TransferCode extends StatefulWidget {
  const TransferCode({Key? key, required this.data}) : super(key: key);

  final TUpdate data;

  @override
  State<TransferCode> createState() => _TransferCodeState();
}

class _TransferCodeState extends State<TransferCode> {
  bool qrcodevisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
        future: Future.wait(
            [Settings.getCodeAlwaysVisible(), Settings.getCodeType()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final bool qrAlwaysVisible = snapshot.data![0];
            final CodeType codeType = snapshot.data![1];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (qrcodevisible || qrAlwaysVisible) ...[
                    _buildQRCode(widget.data.getValue(), codeType),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                  Text(AppLocalizations.of(context).transfer_code_label),
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
                                message: AppLocalizations.of(context)
                                    .toast_info_passphrase_copy,
                              ).show(context);
                            }
                          },
                          icon: const Icon(Icons.copy)),
                      if (!qrAlwaysVisible)
                        IconButton(
                            onPressed: () {
                              setState(() {
                                qrcodevisible = !qrcodevisible;
                              });
                            },
                            icon: const Icon(Icons.qr_code))
                    ],
                  )
                ],
              ),
            );
          } else {
            return const TransferConnecting();
          }
        });
  }

  Widget _buildQRCode(String code, CodeType codeType) {
    final theme = Theme.of(context);

    // the built in qr scanner doesn't support scanning of
    // inverted aztec codes -> so we need to invert colors when in dark theme

    Color color = theme.iconTheme.color ?? Colors.black;
    Color? backgroundColor;

    if (codeType == CodeType.aztecCode && theme.brightness == Brightness.dark) {
      color = Colors.black;
      backgroundColor = theme.iconTheme.color ?? Colors.white;
    }

    return FutureBuilder<String>(
        future: api.getPassphraseUri(passphrase: widget.data.getValue()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BarcodeWidget(
              data: snapshot.data!,
              barcode: codeType == CodeType.qrCode
                  ? Barcode.qrCode()
                  : Barcode.aztec(),
              color: color,
              backgroundColor: backgroundColor,
              height: 200,
              width: 200,
            );
          } else {
            return Container();
          }
        });
  }

  void _showHelpDialog() {
    final text = AppLocalizations.of(context).transfer_code_help;
    final textParts = text.split('<link>');

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).transfer_code_help_title),
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
                        launchUrl(Uri.parse(
                            'https://apps.gnome.org/app/app.drey.Warp/'));
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
