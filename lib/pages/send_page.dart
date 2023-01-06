import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  String? code;
  double value = 0;
  int? total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OutlinedButton(
              onPressed: () async {
                FilePickerResult? result =
                await FilePicker.platform.pickFiles();

                if (result != null) {
                  final file = result.files.single;

                  print(result.files.single.path);
                  print(result.files.single.name);
                  final stream = api.sendFile(
                      fileName: file.name,
                      filePath: file.path!,
                      codeLength: 2);
                  stream.listen((event) {
                    switch (event.event) {
                      case Events.Code:
                        setState(() {
                          code = event.value;
                        });
                        break;
                      case Events.Total:
                        total = int.tryParse(event.value);
                        break;
                      case Events.Sent:
                        setState(() {
                          value = int.tryParse(event.value)! / total!;
                        });
                        break;
                      case Events.Error:
                      // TODO: Handle this case.
                        break;
                      case Events.Finished:
                      // TODO: Handle this case.
                        break;
                      case Events.StartTransfer:
                      // TODO: Handle this case.
                        break;
                    }
                    print(event.event);
                    print(event.value);
                  });
                } else {
                  print("user canceled picker");
                }
              },
              child: Text("sendfile",)),
          Text(code ?? "no code available"),
          LinearProgressIndicator(
            value: value,
          )
        ],
      ),
    );
  }
}
