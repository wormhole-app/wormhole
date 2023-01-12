import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../gen/ffi.dart';
import '../navigation/navigation_provider.dart';
import '../pages/connecting_page.dart';
import '../pages/transfer_widgets/receive_finished.dart';
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

  void _sendFile(String filename, String filepath) {
    // todo codelength from settings page
    final stream =
        api.sendFile(fileName: filename, filePath: filepath, codeLength: 2);

    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false)
        .setActivePage(ConnectingPage(
            key: UniqueKey(),
            stream: stream,
            finish: (file) => Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 60,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Finished transfer!'),
                        ),
                      ]),
                )));
  }

  void _receiveFile(String passphrase) async {
    final dpath = await getDownloadPath();
    if (dpath == null) {
      debugPrint('no download path available');
      return;
    }

    final s = api.requestFile(passphrase: passphrase, storageFolder: dpath);
    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false).setActivePage(
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
      _sendFile(name, path);
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

  void registerIntentShareHandler() {
    // For sharing images coming from outside the app
    // while the app is in the memory
    ReceiveSharingIntent.getMediaStream().listen(sendIntentFile,
        onError: (err) {
      debugPrint('$err');
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(sendIntentFile);

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    ReceiveSharingIntent.getTextStream().listen(sendIntentText, onError: (err) {
      debugPrint('$err');
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(sendIntentText);
  }

  void sendIntentFile(List<SharedMediaFile> value) {
    // todo multiple file not supported for now
    if (value.isEmpty) {
      return;
    }
    final path = value[0].path;
    debugPrint('sending file $path');
    _sendFile(path.split('/').last, path);
  }

  void sendIntentText(String? value) {
    // todo add support sending text
    if (value != null && value.toString().isNotEmpty) {
      debugPrint(value);
    }
  }

  _TransferReceiverState() {
    // Intent shares only on android and ios
    if (Platform.isAndroid || Platform.isIOS) {
      registerIntentShareHandler();
    }
  }
}
