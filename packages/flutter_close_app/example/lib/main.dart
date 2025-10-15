import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_close_app/flutter_close_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterCloseAppPlugin = FlutterCloseApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Close Example'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () async {
              try {
                await _flutterCloseAppPlugin.closeAndRemoveApp();
              } on PlatformException {
                print("failed to close app");
              }
            },
            child: const Text("close app"),
          ),
        ),
      ),
    );
  }
}
