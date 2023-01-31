import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../gen/bridge_definitions.dart';
import '../../utils/file_formatter.dart';
import '../type_helpers.dart';

class TransferProgress extends StatelessWidget {
  const TransferProgress(
      {Key? key,
      required this.data,
      required this.total,
      this.linkType,
      this.linkName})
      : super(key: key);

  final TUpdate data;
  final int? total;
  final ConnectionType? linkType;
  final String? linkName;

  @override
  Widget build(BuildContext context) {
    final int sent = data.getValue();
    double? percent;
    if (total != null) {
      percent = sent.toDouble() / total!.toDouble();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${sent.readableFileSize()}/${total?.readableFileSize()}'),
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
            Text(parseLinkType(linkType!, linkName!, context)),
          ]
        ],
      ),
    );
  }

  String parseLinkType(
      ConnectionType linkType, String linkName, BuildContext context) {
    switch (linkType) {
      case ConnectionType.Relay:
        final relayName = linkName;
        final locText =
            AppLocalizations.of(context).transfer_progress_connection_relay;
        return "$locText '$relayName'";
      case ConnectionType.Direct:
        return AppLocalizations.of(context).transfer_progress_connection_direct;
    }
  }
}
