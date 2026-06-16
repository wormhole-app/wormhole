import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:open_filex/open_filex.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/logger.dart';
import '../../utils/saf.dart';
import '../../widgets/icon_text_button.dart';
import 'transfer_finished.dart';

/// Shown after an Android SAF receive finishes: the file was streamed into an
/// app-owned temp location, and now gets copied into the folder the user picked
/// through the Storage Access Framework. See [issue #181].
class ReceiveSafFinalize extends StatefulWidget {
  const ReceiveSafFinalize({
    super.key,
    required this.tempPath,
    required this.treeUri,
  });

  /// Path the Rust backend wrote the received file to (app-owned staging dir).
  final String tempPath;

  /// `content://` tree URI of the user-selected destination folder.
  final String treeUri;

  @override
  State<ReceiveSafFinalize> createState() => _ReceiveSafFinalizeState();
}

class _ReceiveSafFinalizeState extends State<ReceiveSafFinalize> {
  late final Future<String> _save;

  @override
  void initState() {
    super.initState();
    _save = Saf.saveToTree(
      treeUri: widget.treeUri,
      sourcePath: widget.tempPath,
      fileName: widget.tempPath.split('/').last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _save,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _saving(context);
        }
        if (snapshot.hasError) {
          AppLogger.error('SAF save failed: ${snapshot.error}');
          return _error(context, snapshot.error);
        }
        // The copy succeeded; the staged file is still available for the
        // open/share actions during this session.
        return ReceiveFinished(file: widget.tempPath);
      },
    );
  }

  Widget _saving(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(AppLocalizations.of(context)!.transfer_saving_label),
          ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, Object? error) {
    final localizations = AppLocalizations.of(context)!;
    final message =
        error is PlatformException ? error.message : error.toString();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              '${localizations.transfer_save_error}\n$message',
              textAlign: TextAlign.center,
            ),
          ),
          // The bytes were received successfully into the staging directory, so
          // still let the user open the file even though saving to their folder
          // failed.
          IconTextButton(
            onClick: () => OpenFilex.open(widget.tempPath),
            text: localizations.transfer_finished_open,
            icon: Icons.file_open_outlined,
          ),
        ],
      ),
    );
  }
}
