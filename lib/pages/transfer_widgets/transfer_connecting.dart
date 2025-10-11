import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class TransferConnecting extends StatelessWidget {
  const TransferConnecting({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.transfer_connecting),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
              color: theme.colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }
}
