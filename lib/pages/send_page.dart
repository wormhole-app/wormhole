import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/navigation_provider.dart';
import 'package:flutter_rust_bridge_template/pages/connecting_page.dart';
import 'package:provider/provider.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  void _onSendButtonClick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;

      // todo codelength from settings page
      final stream = api.sendFile(
          fileName: file.name, filePath: file.path!, codeLength: 2);

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
    } else {
      print("user canceled picker");
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
            "Send File",
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text("Select a file to send"),
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
                    "Select File",
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
