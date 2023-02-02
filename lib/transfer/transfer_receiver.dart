import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';

import '../gen/ffi.dart';
import '../navigation/navigation_provider.dart';
import '../pages/connecting_page.dart';
import '../pages/transfer_widgets/transfer_finished.dart';
import '../settings/settings.dart';
import '../utils/paths.dart';
import 'transfer_provider.dart';

class TransferReceiver extends StatefulWidget {
  const TransferReceiver({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<TransferReceiver> createState() => _TransferReceiverState();
}

class _TransferReceiverState extends State<TransferReceiver> {
  final provider = TransferProvider();

  void _sendFile(String filename, String filepath, bool causedByIntent) async {
    final codeLength = (await Settings.getWordLength()) ?? Defaults.wordlength;
    final stream = api.sendFile(
        fileName: filename, filePath: filepath, codeLength: codeLength);

    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false).push(ConnectingPage(
        key: UniqueKey(),
        stream: stream,
        finish: (file) {
          // auto close app if share cause was an intent
          // this happens only if share was successful
          if (causedByIntent) {
            Future.delayed(const Duration(seconds: 2))
                .then((value) => SystemNavigator.pop());
          }

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
                    child: Text(AppLocalizations.of(context)
                        .transfer_finished_send_label),
                  ),
                ]),
          );
        }));
  }

  void _receiveFile(String passphrase) async {
    final dpath = await getDownloadPath();
    if (dpath == null) {
      debugPrint('no download path available');
      return;
    }

    final s = api.requestFile(passphrase: passphrase, storageFolder: dpath);
    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false).push(
      ConnectingPage(
        key: UniqueKey(),
        stream: s,
        finish: (file) => ReceiveFinished(file: file),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    provider.addOnSendListener((name, path) {
      _sendFile(name, path, false);
    });

    provider.addOnReceiveListener((passphrase) {
      _receiveFile(passphrase);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context, child) {
        return widget.child;
      },
      create: (context) => provider,
    );
  }

  /// register handler for intent shares coming from outside of app
  void registerIntentShareHandler() {
    final handler = ShareHandlerPlatform.instance;
    handler.getInitialSharedMedia().then((media) {
      if (media?.attachments != null) {
        _sendIntentFile(media!.attachments!);
      }
    });

    handler.sharedMediaStream.listen((SharedMedia media) {
      if (media.attachments != null) {
        _sendIntentFile(media.attachments!);
      }
    });
  }

  void _sendIntentFile(List<SharedAttachment?> attachments) {
    // todo multiple file not supported for now
    if (attachments.isEmpty || attachments[0] == null) {
      return;
    }

    final path = attachments[0]!.path;
    debugPrint('sending file $path');
    _sendFile(path.split('/').last, path, true);
  }

  _TransferReceiverState() {
    // Intent shares only on android and ios
    if (Platform.isAndroid || Platform.isIOS) {
      registerIntentShareHandler();
    }
  }
}
