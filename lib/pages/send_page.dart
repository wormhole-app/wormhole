import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../transfer/transfer_provider.dart';

class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  void _onSendButtonClick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;

      if (!mounted) return;
      Provider.of<TransferProvider>(context, listen: false)
          .sendFile(file.name, file.path!);
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
            AppLocalizations.of(context).send_page_send_label,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(AppLocalizations.of(context).send_page_send_sublabel),
          const SizedBox(
            height: 25,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  onPressed: _onSendButtonClick,
                  child: Text(
                    AppLocalizations.of(context).send_page_button,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
