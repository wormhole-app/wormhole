import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/icon_text_button.dart';

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
          IconTextButton(
              onClick: () {
                OpenFilex.open(file);
              },
              text: AppLocalizations.of(context)!.transfer_finished_open,
              icon: Icons.file_open_outlined),
          const SizedBox(
            height: 15,
          ),
          Builder(
            builder: (BuildContext context) {
              return IconTextButton(
                  onClick: () {
                    final box = context.findRenderObject() as RenderBox?;
                    Share.shareXFiles(
                      [XFile(file)],
                      text: file.split('/').last,
                      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  text: AppLocalizations.of(context)!.transfer_finished_share,
                  icon: Icons.share);
            },
          ),
        ],
      ),
    );
  }
}
