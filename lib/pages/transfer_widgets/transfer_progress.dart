import 'package:flutter/material.dart';

import '../../gen/bridge_definitions.dart';
import '../../utils/file_formatter.dart';

class TransferProgress extends StatelessWidget {
  const TransferProgress(
      {Key? key, required this.data, required this.total, this.linkType})
      : super(key: key);

  final TUpdate data;
  final int? total;
  final String? linkType;

  @override
  Widget build(BuildContext context) {
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
          Text('${sent?.readableFileSize()}/${total?.readableFileSize()}'),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
            ),
          ),
          // todo pretty
          Text("Link type: ${linkType ?? 'unknown link type'}"),
        ],
      ),
    );
  }
}
