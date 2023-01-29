import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          if (linkType != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(parseLinkType(linkType!, context)),
          ]
        ],
      ),
    );
  }

  String parseLinkType(String linkType, BuildContext context) {
    if (linkType.startsWith('direct:')) {
      return AppLocalizations.of(context).transfer_progress_connection_direct;
    } else {
      final relayName = linkType.split('relay:').last;
      final locText =
          AppLocalizations.of(context).transfer_progress_connection_relay;
      return "$locText '$relayName'";
    }
  }
}
