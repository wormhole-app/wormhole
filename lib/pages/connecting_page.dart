import 'dart:async';

import 'package:flutter/material.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../navigation/back_pop_context.dart';
import '../navigation/disallow_pop_context.dart';
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
  String? connectionType;

  late StreamController<TUpdate> controller =
      StreamController<TUpdate>.broadcast()..addStream(widget.stream);

  @override
  void initState() {
    super.initState();
    controller.stream.listen((e) {
      switch (e.event) {
        case Events.Total:
          total = int.tryParse(e.value) ?? -1;
          break;
        case Events.ConnectionType:
          connectionType = e.value;
          break;
        default:
          break;
      }
    });
  }

  Widget _handleEvent(TUpdate event) {
    switch (event.event) {
      case Events.Code:
        return BackPopContext(
          child: TransferCode(
            data: event,
          ),
        );
      case Events.StartTransfer:
      case Events.ConnectionType:
      case Events.Total:
      case Events.Sent:
        return DisallowPopContext(
          child: TransferProgress(
            data: event,
            total: total,
            linkType: connectionType,
          ),
        );
      case Events.Error:
        return BackPopContext(child: TransferError(error: event.value));
      case Events.Finished:
        return BackPopContext(child: widget.finish(event.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TUpdate>(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const DisallowPopContext(child: TransferConnecting());
          case ConnectionState.waiting:
            return const DisallowPopContext(child: TransferConnecting());
          case ConnectionState.active:
            final d = snapshot.data!;
            return _handleEvent(d);
          case ConnectionState.done:
            return const BackPopContext(
                child: TransferError(error: 'Connection Stream closed'));
        }
      },
      stream: controller.stream,
    );
  }
}
