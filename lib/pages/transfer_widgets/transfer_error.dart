import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../gen/bridge_definitions.dart';

class TransferError extends StatelessWidget {
  const TransferError({Key? key, required this.error, this.message})
      : super(key: key);

  final ErrorType error;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(AppLocalizations.of(context).transfer_error_base),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(genErrorMessage(error, message))
          ]),
    );
  }

  String genErrorMessage(ErrorType error, String? message) {
    // todo error translations
    switch (error) {
      case ErrorType.InvalidFilename:
        return 'Sender did not specify a filename';
      case ErrorType.NoFilePathFound:
        return 'No valid filepath could be found';
      case ErrorType.ConnectionError:
      case ErrorType.FileRequestError:
      case ErrorType.FileOpen:
      case ErrorType.TransferError:
      case ErrorType.TransferConnectionError:
      case ErrorType.ZipFileError:
        return message ?? 'invalid message';
    }
  }
}
