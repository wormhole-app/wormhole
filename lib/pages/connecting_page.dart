import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/utils/file_formatter.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({Key? key, required this.stream, required this.finish})
      : super(key: key);

  final Stream<TUpdate> stream;
  final Widget Function(String file) finish;

  @override
  State<ConnectingPage> createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  int? total;

  late StreamController<TUpdate> controller =
      StreamController<TUpdate>.broadcast()..addStream(widget.stream);

  @override
  void initState() {
    super.initState();
    controller.stream.listen((e) {
      if (e.event == Events.Total) {
        total = int.tryParse(e.value) ?? -1;
      }
    });
  }

  Widget _waitingProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text("Connecting..."),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
            ),
          )
        ],
      ),
    );
  }

  Widget _sendProgress(TUpdate data) {
    final sent = int.tryParse(data.value);
    double? percent;
    if (sent != null && total != null) {
      percent = sent.toDouble() / total!.toDouble();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${sent?.readableFileSize()}/${total?.readableFileSize()}"),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
            ),
          )
        ],
      ),
    );
  }

  Widget _errorView(TUpdate data) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("Transfer error occured: ${data.value}"),
            ),
          ]),
    );
  }

  Widget _handleEvent(TUpdate event) {
    final theme = Theme.of(context);

    switch (event.event) {
      case Events.Code:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Your transmit code is:"),
              Text(
                event.value,
                style: theme.textTheme.titleLarge,
              )
            ],
          ),
        );
      case Events.StartTransfer:
      case Events.Total:
      case Events.Sent:
        return _sendProgress(event);
      case Events.Error:
        return _errorView(event);
      case Events.Finished:
        return widget.finish(event.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<TUpdate>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // todo is this neccessary?
              return Column(
                children: const [
                  Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Connecting to stream'),
                  ),
                ],
              );
            case ConnectionState.waiting:
              return _waitingProgress();
            case ConnectionState.active:
              final d = snapshot.data!;
              return _handleEvent(d);
            case ConnectionState.done:
              // todo what to do with this stuff here
              return Column(children: [
                const Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('\$${snapshot.data} (closed)'),
                ),
              ]);
          }
        },
        stream: controller.stream,
      ),
    );
  }
}
