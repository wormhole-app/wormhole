import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../src/rust/api/wormhole.dart';
import '../type_helpers.dart';

class TransferZipProgress extends StatelessWidget {
  const TransferZipProgress(
      {super.key, required this.data, required this.totalFileNr});

  final TUpdate data;
  final int? totalFileNr;

  @override
  Widget build(BuildContext context) {
    final int alreadyProcessed = data.getValue();
    double? percent;
    if (totalFileNr != null) {
      percent = alreadyProcessed.toDouble() / totalFileNr!.toDouble();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_zip,
            size: 60,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
              '${AppLocalizations.of(context)!.transfer_zipping} $alreadyProcessed/$totalFileNr'),
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
        ],
      ),
    );
  }
}
