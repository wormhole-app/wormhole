import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../transfer/transfer_provider.dart';
import '../widgets/split_button.dart';

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
      Provider.of<TransferProvider>(context, listen: false).sendFiles(
          files.first.name,
          files.map((e) => e.path).whereType<String>().toList());
    } else {
      debugPrint('user canceled picker');
    }
  }

  void _onSendFolderButtonClick() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      if (!mounted) return;
      Provider.of<TransferProvider>(context, listen: false)
          .sendFolder(result.split('/').last, result);
    } else {
      debugPrint('user canceled picker');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
          SplitButton(
            onLeftButtonClick: _onSendButtonClick,
            onRightButtonClick: _onSendFolderButtonClick,
            textLeft: AppLocalizations.of(context)!.send_page_button,
            iconRight: Icons.folder,
          )
        ],
      ),
    );
  }
}
