import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/utils/paths.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../navigation_provider.dart';
import 'connecting_page.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  TextEditingController controller = TextEditingController();

  _ReceivePageState() {
    controller.addListener(() {
      if (controller.text.endsWith(" ")) {
        controller.text =
            '${controller.text.substring(0, controller.text.length - 1)}-';
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.download,
            size: 96,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Receive File",
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text("Enter the transmit code from the sender"),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: 250,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                labelStyle: theme.textTheme.bodyMedium,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: theme.focusColor, width: 2)),
                hintStyle: theme.textTheme.bodyMedium?.apply(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(.4)),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                hintText: 'Transmit code',
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  onPressed: _onReceiveButtonClick,
                  child: const Text(
                    "Select File",
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _onReceiveButtonClick() async {
    final text = controller.value.text;

    final dpath = await getDownloadPath();
    if (dpath == null) {
      print("no download path available");
      return;
    }

    final s = api.requestFile(passphrase: text, storageFolder: dpath);

    Provider.of<NavigationProvider>(context, listen: false)
        .setActivePage(ConnectingPage(
            stream: s,
            finish: (file) => Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 60,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Finished receive of file!'),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  OpenFilex.open(file);
                                },
                                child: const Text(
                                  "Open file",
                                )),
                          ),
                        ),
                      ]),
                )));
  }
}
