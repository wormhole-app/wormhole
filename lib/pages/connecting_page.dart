import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/utils/file_formatter.dart';

import '../gen/ffi.dart' if (dart.library.html) 'ffi_web.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({Key? key, required this.stream}) : super(key: key);

  final Stream<TUpdate> stream;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            case ConnectionState.active:
              final d = snapshot.data!;

              switch (d.event) {
                case Events.Code:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Your transmit code is:"),
                        Text(
                          d.value,
                          style: theme.textTheme.titleLarge,
                        )
                      ],
                    ),
                  );
                case Events.Sent:
                  final sent = int.tryParse(d.value);
                  double? percent;
                  if (sent != null && total != null) {
                    percent = sent.toDouble() / total!.toDouble();
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${sent?.readableFileSize()}/${total?.readableFileSize()}"),
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
                  break;
                case Events.Error:
                  // TODO: Handle this case.
                  break;
                case Events.Finished:
                  return Center(
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
                  );
                case Events.StartTransfer:
                  // TODO: Handle this case.
                  break;
                case Events.Total:
                  break;
              }

              return Placeholder();
            case ConnectionState.done:
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
