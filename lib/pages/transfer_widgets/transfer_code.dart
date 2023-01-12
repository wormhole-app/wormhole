import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../gen/bridge_definitions.dart';

class TransferCode extends StatefulWidget {
  const TransferCode({Key? key, required this.data}) : super(key: key);

  final TUpdate data;

  @override
  State<TransferCode> createState() => _TransferCodeState();
}

class _TransferCodeState extends State<TransferCode> {
  bool qrcodevisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (qrcodevisible) ...[
            QrImage(
              data: 'wormhole-transfer:${widget.data.value}',
              foregroundColor: theme.iconTheme.color,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(
              height: 30,
            )
          ],
          const Text('Your transmit code is:'),
          Text(
            widget.data.value,
            style: theme.textTheme.titleLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.data.value));
                  },
                  icon: const Icon(Icons.copy)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      qrcodevisible = !qrcodevisible;
                    });
                  },
                  icon: const Icon(Icons.qr_code))
            ],
          )
        ],
      ),
    );
  }
}
