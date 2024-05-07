import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../transfer/transfer_provider.dart';
import '../utils/code.dart';
import '../widgets/icon_text_button.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  TextEditingController controller = TextEditingController();
  String? errorText;

  _ReceivePageState() {
    controller.addListener(() {
      setState(() {
        errorText = null;
      });

      // Replace spaces with dashes
      if (controller.text.endsWith(' ')) {
        controller.text =
            '${controller.text.substring(0, controller.text.length - 1)}-';
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.download,
              size: 96,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.receive_page_label,
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(AppLocalizations.of(context)!.receive_page_sublabel),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: controller,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+.*')),
                ],
                cursorColor: theme.colorScheme.onPrimary,
                decoration: InputDecoration(
                  filled: true,
                  errorText: errorText,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                          color: theme.colorScheme.secondary, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 2)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  hintText:
                      AppLocalizations.of(context)!.receive_page_textfield_hint,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            IconTextButton(
                onClick: _onReceiveButtonClick,
                text: AppLocalizations.of(context)!.receive_page_button,
                icon: Icons.archive),
          ],
        ),
      ),
    );
  }

  void _onReceiveButtonClick() async {
    final text = controller.value.text;

    if (!isCodeValid(text) || !mounted) {
      setState(() {
        errorText = 'Invalid Code';
      });
      return;
    }

    Provider.of<TransferProvider>(context, listen: false).receiveFile(text);
  }
}
