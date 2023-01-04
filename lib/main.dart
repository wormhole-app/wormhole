import 'package:flutter/material.dart';
import 'gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? code;
  double value = 0;
  int? total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();

              if (result != null) {
                final file = result.files.single;

                print(result.files.single.path);
                print(result.files.single.name);
                final stream =  api.sendFile(fileName: file.name, filePath: file.path!, codeLength: 2);
                stream.listen((event) {
                  switch(event.event) {
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
                  }
                  print(event.event);
                  print(event.value);
                });

              } else {
                print("user canceled picker");
              }
            }, child: const Text("sendfile")),
            Text(code ?? "no code available"),
            LinearProgressIndicator(value: value,)
          ],
        ),
      ),
    );
  }
}
