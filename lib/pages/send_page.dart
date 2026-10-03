import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../transfer/send_target.dart';
import '../transfer/transfer_provider.dart';
import '../utils/code.dart';
import '../widgets/icon_text_button.dart';
import '../utils/logger.dart';

/// A single send action, rendered either as an inline button or as an entry
/// in the "more options" sheet depending on available screen space.
class _SendAction {
  const _SendAction(
      {required this.text,
      required this.icon,
      required this.onClick,
      this.outlined = false});

  final String text;
  final IconData icon;
  final VoidCallback onClick;

  /// Drawn as an outlined button: a secondary action.
  final bool outlined;
}

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final bool _showMediaButton = Platform.isAndroid || Platform.isIOS;

  // Estimated extents used to decide how many actions fit on screen.
  static const double _headerHeight = 185;
  static const double _buttonSpacing = 15;
  static const double _buttonExtent = 56 + _buttonSpacing;
  // The send-to banner and its spacing, added to the header while shown.
  static const double _bannerExtent = 60 + _buttonSpacing;

  // The code sheet's text field keeps using its controller while the sheet
  // animates out, so the page owns it instead of the sheet call.
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// The receiver's code to send to, if any. A starting send takes it, as
  /// codes are single-use.
  String? _takeTarget() =>
      Provider.of<SendTarget>(context, listen: false).take();

  void _onSendButtonClick() async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);

    if (result != null) {
      final files =
          result.files.where((element) => element.path != null).toList();

      if (!mounted) return;
      AppLogger.info('Sending ${files.length} file(s)');
      Provider.of<TransferProvider>(context, listen: false).sendFiles(
          files.first.name,
          files.map((e) => e.path).whereType<String>().toList(),
          code: _takeTarget());
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
          .sendFolder(result.split('/').last, result, code: _takeTarget());
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
          .sendFiles(media.first.name, paths, code: _takeTarget());
    } else {
      AppLogger.debug('User canceled media picker');
    }
  }

  void _onSendTextButtonClick() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final text = await showModalBottomSheet<String>(
      context: context,
      // The page sits inside a per-tab navigator; the sheet should cover the
      // whole screen including the bottom navigation bar.
      useRootNavigator: true,
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
                decoration:
                    _sheetFieldDecoration(theme, l10n.send_page_text_hint),
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
      Provider.of<TransferProvider>(context, listen: false)
          .sendText(text, code: _takeTarget());
    }
  }

  void _onSendToCodeButtonClick() async {
    final controller = _codeController..clear();
    final l10n = AppLocalizations.of(context)!;

    // a trailing dash (a typed space) is never part of the receiver's code
    String typedCode() => controller.text.replaceFirst(RegExp(r'-+$'), '');

    final code = await showModalBottomSheet<String>(
      context: context,
      // The page sits inside a per-tab navigator; the sheet should cover the
      // whole screen including the bottom navigation bar.
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: _sheetShape(context),
      builder: (context) {
        final theme = Theme.of(context);
        void submit() {
          if (isCodeValid(typedCode())) Navigator.of(context).pop(typedCode());
        }

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
                autocorrect: false,
                enableSuggestions: false,
                // like the receive page: digits first, a space becomes a dash
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+.*')),
                  const _SpaceToDashFormatter(),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(),
                cursorColor: theme.colorScheme.onSurface,
                decoration:
                    _sheetFieldDecoration(theme, l10n.send_page_code_hint),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, child) {
                  return FilledButton.icon(
                    onPressed: isCodeValid(typedCode()) ? submit : null,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.send_page_code_set),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (code != null) {
      if (!mounted) return;
      AppLogger.info('Send target set by typing');
      Provider.of<SendTarget>(context, listen: false).code = code;
    }
  }

  /// The outlined, filled look of the text fields in the bottom sheets.
  static InputDecoration _sheetFieldDecoration(
      ThemeData theme, String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: theme.colorScheme.onSurface, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
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
      useRootNavigator: true,
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
    final target = Provider.of<SendTarget>(context).code;

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
      _SendAction(
          text: l10n.send_page_code_button,
          icon: Icons.pin,
          onClick: _onSendToCodeButtonClick,
          outlined: true),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight -
            _headerHeight -
            (target == null ? 0 : _bannerExtent);
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
              onClick: action.onClick,
              text: action.text,
              icon: action.icon,
              outlined: action.outlined));
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
                  height: 25,
                ),
                if (target != null) ...[
                  _SendTargetBanner(
                    code: target,
                    onClear: () =>
                        Provider.of<SendTarget>(context, listen: false).code =
                            null,
                  ),
                  const SizedBox(height: _buttonSpacing),
                ],
                ...buttons,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Turns spaces into dashes while a code is typed, like the receive page.
class _SpaceToDashFormatter extends TextInputFormatter {
  const _SpaceToDashFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.replaceAll(' ', '-'));
  }
}

/// The receiver's code that every send action sends to, with a button to
/// drop it.
class _SendTargetBanner extends StatelessWidget {
  const _SendTargetBanner({required this.code, required this.onClear});

  final String code;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.send_page_target_label(code),
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close),
                tooltip: l10n.send_page_target_clear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
