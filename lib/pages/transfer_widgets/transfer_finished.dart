import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveFinished extends StatelessWidget {
  const ReceiveFinished({super.key, required this.file});

  final String file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(AppLocalizations.of(context)!.transfer_finished_label),
          ),
          const SizedBox(
            height: 25,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                  onPressed: () {
                    OpenFilex.open(file);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.transfer_finished_open,
                  )),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                  onPressed: () {
                    Share.shareXFiles([XFile(file)],
                        text: file.split('/').last);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.transfer_finished_share,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
