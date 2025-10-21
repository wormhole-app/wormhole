import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../transfer/transfer_provider.dart';
import '../widgets/icon_text_button.dart';
import '../utils/logger.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  void _onSendButtonClick() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      final files =
          result.files.where((element) => element.path != null).toList();

      if (!mounted) return;
      AppLogger.info('Sending ${files.length} file(s)');
      Provider.of<TransferProvider>(context, listen: false).sendFiles(
          files.first.name,
          files.map((e) => e.path).whereType<String>().toList());
    } else {
      AppLogger.fine('User canceled file picker');
    }
  }

  void _onSendFolderButtonClick() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      if (!mounted) return;
      AppLogger.info('Sending folder: ${result.split('/').last}');
      Provider.of<TransferProvider>(context, listen: false)
          .sendFolder(result.split('/').last, result);
    } else {
      AppLogger.fine('User canceled folder picker');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.upload,
              size: 96,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.send_page_send_label,
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(AppLocalizations.of(context)!.send_page_send_sublabel),
            const SizedBox(
              height: 25,
            ),
            IconTextButton(
                onClick: _onSendButtonClick,
                text: AppLocalizations.of(context)!.send_page_button,
                icon: Icons.file_present),
            const SizedBox(
              height: 15,
            ),
            IconTextButton(
                onClick: _onSendFolderButtonClick,
                text: AppLocalizations.of(context)!.send_page_folder_button,
                icon: Icons.folder),
          ],
        ),
      ),
    );
  }
}
