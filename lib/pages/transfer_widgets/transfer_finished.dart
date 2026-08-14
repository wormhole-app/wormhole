import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_close_app/flutter_close_app.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/icon_text_button.dart';

class ReceiveFinished extends StatelessWidget {
  const ReceiveFinished({super.key, required this.file});

  final String file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(AppLocalizations.of(context)!.transfer_finished_label),
          ),
          const SizedBox(
            height: 25,
          ),
          IconTextButton(
              onClick: () {
                OpenFilex.open(file);
              },
              text: AppLocalizations.of(context)!.transfer_finished_open,
              icon: Icons.file_open_outlined),
          const SizedBox(
            height: 15,
          ),
          Builder(
            builder: (BuildContext context) {
              return IconTextButton(
                  onClick: () {
                    final box = context.findRenderObject() as RenderBox?;
                    Share.shareXFiles(
                      [XFile(file)],
                      text: file.split('/').last,
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  text: AppLocalizations.of(context)!.transfer_finished_share,
                  icon: Icons.share);
            },
          ),
          const SizedBox(height: 15),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.arrow_back),
            label: Text(AppLocalizations.of(context)!
                .transfer_finished_receive_another),
          ),
        ],
      ),
    );
  }
}

class SendFinished extends StatefulWidget {
  const SendFinished({super.key, required this.causedByIntent});

  /// Whether the send was started by a share intent from another app; in that
  /// case the app closes itself shortly after the transfer finished.
  final bool causedByIntent;

  @override
  State<SendFinished> createState() => _SendFinishedState();
}

class _SendFinishedState extends State<SendFinished> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      // delete temporary files cached by file_picker
      FilePicker.clearTemporaryFiles();

      // auto close app if share cause was an intent
      // this happens only if share was successful
      if (widget.causedByIntent) {
        Future.delayed(const Duration(seconds: 1)).then((value) async {
          await FlutterCloseApp().closeAndRemoveApp();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                  AppLocalizations.of(context)!.transfer_finished_send_label),
            ),
            const SizedBox(height: 25),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                  AppLocalizations.of(context)!.transfer_finished_send_another),
            ),
          ]),
    );
  }
}
