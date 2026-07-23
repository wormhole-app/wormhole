import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../transfer/transfer_provider.dart';
import '../widgets/icon_text_button.dart';
import '../utils/logger.dart';

/// A single send action, rendered either as an inline button or as an entry
/// in the "more options" sheet depending on available screen space.
class _SendAction {
  const _SendAction(
      {required this.text, required this.icon, required this.onClick});

  final String text;
  final IconData icon;
  final VoidCallback onClick;
}

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final bool _showMediaButton = Platform.isAndroid || Platform.isIOS;

  // Estimated extents used to decide how many actions fit on screen.
  static const double _headerHeight = 210;
  static const double _buttonSpacing = 15;
  static const double _buttonExtent = 56 + _buttonSpacing;

  void _onSendButtonClick() async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);

    if (result != null) {
      final files =
          result.files.where((element) => element.path != null).toList();

      if (!mounted) return;
      AppLogger.info('Sending ${files.length} file(s)');
      Provider.of<TransferProvider>(context, listen: false).sendFiles(
          files.first.name,
          files.map((e) => e.path).whereType<String>().toList());
    } else {
      AppLogger.debug('User canceled file picker');
    }
  }

  void _onSendFolderButtonClick() async {
    String? result;

    if (Platform.isIOS) {
      const channel = MethodChannel('io.wormhole.app/folder_picker');
      try {
        result = await channel.invokeMethod<String>('pickFolder');
      } on PlatformException catch (e) {
        AppLogger.error('Folder picker error: ${e.message}');
        return;
      }
    } else {
      result = await FilePicker.getDirectoryPath();
    }

    if (result != null) {
      if (!mounted) return;
      AppLogger.info('Sending folder: ${result.split('/').last}');
      Provider.of<TransferProvider>(context, listen: false)
          .sendFolder(result.split('/').last, result);
    } else {
      AppLogger.debug('User canceled folder picker');
    }
  }

  void _onSendMediaButtonClick() async {
    final List<XFile> media = await ImagePicker().pickMultipleMedia();

    if (media.isNotEmpty) {
      if (!mounted) return;
      final paths = media.map((f) => f.path).toList();
      AppLogger.info('Sending ${media.length} media file(s)');
      Provider.of<TransferProvider>(context, listen: false)
          .sendFiles(media.first.name, paths);
    } else {
      AppLogger.debug('User canceled media picker');
    }
  }

  void _onSendTextButtonClick() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: _sheetShape(context),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                cursorColor: theme.colorScheme.onSurface,
                decoration: InputDecoration(
                  hintText: l10n.send_page_text_hint,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: theme.colorScheme.onSurface, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: theme.colorScheme.secondary, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;
                  return FilledButton.icon(
                    onPressed: hasText
                        ? () => Navigator.of(context).pop(value.text)
                        : null,
                    icon: const Icon(Icons.send),
                    label: Text(l10n.send_page_text_send),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();

    if (text != null && text.trim().isNotEmpty) {
      if (!mounted) return;
      AppLogger.info('Sending text (${text.length} chars)');
      Provider.of<TransferProvider>(context, listen: false).sendText(text);
    }
  }

  /// A bottom sheet shape with a visible outline, so the panel stands out
  /// against the (black) surface in the dark theme.
  static ShapeBorder _sheetShape(BuildContext context) {
    final theme = Theme.of(context);
    return RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(color: theme.colorScheme.secondary),
    );
  }

  void _showMoreOptions(List<_SendAction> actions) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: _sheetShape(context),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions.map((action) {
              return ListTile(
                leading: Icon(action.icon),
                title: Text(action.text),
                onTap: () {
                  Navigator.of(context).pop();
                  action.onClick();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Ordered by priority; "Select File" is the primary action and is never
    // moved into the overflow sheet.
    final actions = <_SendAction>[
      _SendAction(
          text: l10n.send_page_button,
          icon: Icons.file_present,
          onClick: _onSendButtonClick),
      if (_showMediaButton)
        _SendAction(
            text: l10n.send_page_media_button,
            icon: Icons.photo_library,
            onClick: _onSendMediaButtonClick),
      _SendAction(
          text: l10n.send_page_folder_button,
          icon: Icons.folder,
          onClick: _onSendFolderButtonClick),
      _SendAction(
          text: l10n.send_page_text_button,
          icon: Icons.notes,
          onClick: _onSendTextButtonClick),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight - _headerHeight;
        final maxButtons =
            available <= 0 ? 1 : (available / _buttonExtent).floor();

        final List<_SendAction> inline;
        final List<_SendAction> overflow;
        if (maxButtons >= actions.length) {
          inline = actions;
          overflow = const [];
        } else {
          // Reserve one slot for the "more options" button.
          final inlineCount = (maxButtons - 1).clamp(1, actions.length);
          inline = actions.sublist(0, inlineCount);
          overflow = actions.sublist(inlineCount);
        }

        final buttons = <Widget>[];
        for (final action in inline) {
          if (buttons.isNotEmpty) {
            buttons.add(const SizedBox(height: _buttonSpacing));
          }
          buttons.add(IconTextButton(
              onClick: action.onClick, text: action.text, icon: action.icon));
        }
        if (overflow.isNotEmpty) {
          buttons.add(const SizedBox(height: _buttonSpacing));
          buttons.add(IconTextButton(
              onClick: () => _showMoreOptions(overflow),
              text: l10n.send_page_more_button,
              icon: Icons.more_horiz));
        }

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
                  l10n.send_page_send_label,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(l10n.send_page_send_sublabel),
                const SizedBox(
                  height: 25,
                ),
                ...buttons,
              ],
            ),
          ),
        );
      },
    );
  }
}
