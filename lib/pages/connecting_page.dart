import 'dart:async';

import 'package:flutter/material.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'transfer_widgets/transfer_code.dart';
import 'transfer_widgets/transfer_connecting.dart';
import 'transfer_widgets/transfer_error.dart';
import 'transfer_widgets/transfer_progress.dart';

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

  Widget _handleEvent(TUpdate event) {
    switch (event.event) {
      case Events.Code:
        return TransferCode(
          data: event,
        );
      case Events.StartTransfer:
      case Events.Total:
      case Events.Sent:
        return TransferProgress(
          data: event,
          total: total,
        );
      case Events.Error:
        return TransferError(error: event.value);
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
              return const TransferConnecting();
            case ConnectionState.waiting:
              return const TransferConnecting();
            case ConnectionState.active:
              final d = snapshot.data!;
              return _handleEvent(d);
            case ConnectionState.done:
              return const TransferError(error: 'Connection Stream closed');
          }
        },
        stream: controller.stream,
      ),
    );
  }
}
