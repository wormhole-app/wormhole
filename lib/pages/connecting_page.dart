import 'dart:async';

import 'package:flutter/material.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';
import '../navigation/back_pop_context.dart';
import '../navigation/disallow_pop_context.dart';
import 'transfer_widgets/transfer_code.dart';
import 'transfer_widgets/transfer_connecting.dart';
import 'transfer_widgets/transfer_error.dart';
import 'transfer_widgets/transfer_progress.dart';
import 'type_helpers.dart';

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
  ConnectionType? connectionType;
  String? connectionTypeName;

  late StreamController<TUpdate> controller =
      StreamController<TUpdate>.broadcast()..addStream(widget.stream);

  @override
  void initState() {
    super.initState();
    controller.stream.listen((e) {
      switch (e.event) {
        case Events.Total:
          total = e.getValue();
          break;
        case Events.ConnectionType:
          connectionType = (e.value as Value_ConnectionType).field0;
          connectionTypeName = (e.value as Value_ConnectionType).field1;
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
              linkName: connectionTypeName),
        );
      case Events.Error:
        return BackPopContext(
            child: TransferError(
                error: event.value.field0 as ErrorType,
                message: event.value is Value_ErrorValue
                    ? (event.value as Value_ErrorValue).field1
                    : null));
      case Events.Finished:
        return BackPopContext(child: widget.finish(event.getValue()));
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
                child: TransferError(
              error: ErrorType.ConnectionError,
              message: 'Connection Stream closed',
            ));
        }
      },
      stream: controller.stream,
    );
  }
}
