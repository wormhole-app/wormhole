import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../navigation_provider.dart';
import 'connecting_page.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  void listenShareMediaFiles() {
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

  void _sendFile(String filename, String filepath) {
    // todo codelength from settings page
    final stream =
        api.sendFile(fileName: filename, filePath: filepath, codeLength: 2);

    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false)
        .setActivePage(ConnectingPage(
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

  void _onSendButtonClick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;
      _sendFile(file.name, file.path!);
    } else {
      debugPrint('user canceled picker');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.upload,
            size: 96,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Send File',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text('Select a file to send'),
          const SizedBox(
            height: 25,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  onPressed: _onSendButtonClick,
                  child: const Text(
                    'Select File',
                  )),
            ),
          ),
        ],
      ),
    );
  }

  _SendPageState() {
    // Intent shares only on android and ios
    if (Platform.isAndroid || Platform.isIOS) {
      listenShareMediaFiles();
    }
  }
}
