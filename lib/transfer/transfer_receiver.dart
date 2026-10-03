import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:app_links/app_links.dart';

import '../l10n/app_localizations.dart';
import '../src/rust/api/wormhole.dart';
import '../navigation/navigation.dart';
import '../pages/connecting_page.dart';
import '../pages/toasts/error_toast.dart';
import '../pages/toasts/info_toast.dart';
import '../pages/transfer_widgets/transfer_finished.dart';
import '../pages/transfer_widgets/receive_saf_finalize.dart';
import '../settings/settings.dart';
import '../utils/paths.dart';
import '../utils/saf.dart';
import '../utils/logger.dart';
import '../utils/code.dart';
import 'send_target.dart';
import 'transfer_provider.dart';
import 'demo_transfer.dart';

class TransferReceiver extends StatefulWidget {
  const TransferReceiver(
      {super.key,
      required this.child,
      required this.pushPage,
      required this.showTab,
      required this.isTransferRunning});

  final Widget child;

  /// Switches to the given tab and pushes the page onto its navigator.
  /// Provided by [Navigation], which owns the per-tab navigators.
  final void Function(AppTab tab, Widget page) pushPage;

  /// Switches to the given tab and returns it to its root page.
  final void Function(AppTab tab) showTab;

  /// Whether a transfer that can still be cancelled runs on the given tab.
  final bool Function(AppTab tab) isTransferRunning;

  @override
  State<TransferReceiver> createState() => _TransferReceiverState();
}

class _TransferReceiverState extends State<TransferReceiver> {
  final provider = TransferProvider();

  /// Copy files from iOS shared app group container to app's temp directory
  /// This is needed because files from share intent may be in a restricted container
  Future<List<String>> _copyIntentFilesToTempDir(List<String> paths) async {
    if (!Platform.isIOS) return paths;

    try {
      final tempDir = await getTemporaryDirectory();
      final copiedPaths = <String>[];

      for (final filePath in paths) {
        final sourceFile = File(filePath);
        if (!await sourceFile.exists()) {
          AppLogger.warn('Intent file not found: $filePath');
          continue;
        }

        final fileName = filePath.split('/').last;
        final destPath = '${tempDir.path}/$fileName';

        // Copy file to temp directory
        await sourceFile.copy(destPath);
        AppLogger.debug('Copied intent file to temp: $destPath');
        copiedPaths.add(destPath);
      }

      return copiedPaths.isNotEmpty ? copiedPaths : paths;
    } catch (e) {
      AppLogger.warn('Failed to copy intent files: $e');
      // Fall back to original paths if copy fails
      return paths;
    }
  }

  void _sendFolder(String name, String path, bool causedByIntent,
      {String? code}) async {
    final codeLength = (await Settings.getWordLength()) ?? Defaults.wordlength;

    final cancelToken = CancelToken();
    final stream = sendFolder(
        folderPath: path,
        name: name,
        codeLength: codeLength,
        code: code,
        serverConfig: await _getServerConfig(),
        cancel: cancelToken);
    _showConnectionPage(stream, cancelToken, causedByIntent);
  }

  void _sendFiles(String name, List<String> filepaths, bool causedByIntent,
      {String? code}) async {
    final codeLength = (await Settings.getWordLength()) ?? Defaults.wordlength;
    final cancelToken = CancelToken();
    final stream = sendFiles(
        name: name,
        filePaths: filepaths,
        codeLength: codeLength,
        code: code,
        serverConfig: await _getServerConfig(),
        cancel: cancelToken);

    _showConnectionPage(stream, cancelToken, causedByIntent);
  }

  void _showConnectionPage(
      Stream<TUpdate> stream, CancelToken cancelToken, bool causedByIntent) {
    if (!mounted) {
      cancelToken.cancel();
      return;
    }
    widget.pushPage(
      AppTab.send,
      ConnectingPage(
        stream: stream,
        finish: (file) => SendFinished(causedByIntent: causedByIntent),
        onCancel: cancelToken.cancel,
      ),
    );
  }

  Future<ServerConfig> _getServerConfig() async {
    final rendezvousUrl =
        (await Settings.getRendezvousUrl()) ?? await defaultRendezvousUrl();
    final transitUrl =
        (await Settings.getTransitUrl()) ?? await defaultTransitUrl();
    final serverConfig =
        ServerConfig(rendezvousUrl: rendezvousUrl, transitUrl: transitUrl);
    return serverConfig;
  }

  /// [passphrase]: the sender's code; null makes a new one for the sender.
  void _receiveFile(String? passphrase) async {
    final askForFolder = await Settings.getAskForFolder();

    // On Android, scoped storage blocks raw writes into a user-picked folder.
    // When "ask for folder" is enabled we instead grant access through the
    // Storage Access Framework: pick a content tree, stage the download in
    // app-owned storage, then copy it into the chosen folder once finished.
    final String? safTreeUri =
        (Platform.isAndroid && askForFolder) ? await Saf.pickDirectory() : null;
    final String? dpath;
    if (Platform.isAndroid && askForFolder) {
      if (safTreeUri == null) {
        AppLogger.info('Download folder selection cancelled');
        return;
      }
      dpath = (await getReceiveTempDir()).path;
    } else {
      dpath = await getDownloadPath(askForFolder: askForFolder);
    }
    if (dpath == null) {
      AppLogger.warn('No download path available');
      return;
    }

    // Check if this is a demo code for App Store review
    if (passphrase != null && isDemoCode(passphrase)) {
      // Use demo transfer stream instead of real wormhole connection
      final s = generateDemoReceiveStream(dpath);
      if (!mounted) return;
      widget.pushPage(
        AppTab.receive,
        ConnectingPage(
          stream: s,
          finish: (file) => ReceiveFinished(file: file),
        ),
      );
      return;
    }

    // we need storage permission to store files. The SAF staging directory is
    // app-owned, so writing there never requires a runtime permission.
    if (safTreeUri != null ||
        !(Platform.isAndroid || Platform.isIOS) ||
        (Platform.isAndroid &&
            (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33) ||
        await Permission.storage.request().isGranted) {
      final codeLength =
          (await Settings.getWordLength()) ?? Defaults.wordlength;
      final cancelToken = CancelToken();
      final s = requestFile(
          passphrase: passphrase,
          codeLength: codeLength,
          storageFolder: dpath,
          serverConfig: await _getServerConfig(),
          cancel: cancelToken);
      if (!mounted) {
        cancelToken.cancel();
        return;
      }
      widget.pushPage(
        AppTab.receive,
        ConnectingPage(
          stream: s,
          finish: (file) => safTreeUri == null
              ? ReceiveFinished(file: file)
              : ReceiveSafFinalize(tempPath: file, treeUri: safTreeUri),
          onCancel: cancelToken.cancel,
          isReceiver: passphrase == null,
        ),
      );
    } else {
      if (!mounted) return;
      ErrorToast(
              message: AppLocalizations.of(context)!
                  .transfer_error_storagepermission)
          .show(context);
    }
  }

  /// A receiver showed its code for us to send to: open the send page with
  /// the code set, unless a send is still running there.
  void _setSendTarget(String code) {
    if (!mounted) return;
    if (widget.isTransferRunning(AppTab.send)) {
      InfoToast(
              message:
                  AppLocalizations.of(context)!.toast_info_transfer_running)
          .show(context);
      return;
    }
    widget.showTab(AppTab.send);
    Provider.of<SendTarget>(context, listen: false).code = code;
  }

  @override
  void initState() {
    super.initState();

    // Clean up any files staged by a previous SAF receive that were never
    // cleared (e.g. the app was killed mid-transfer).
    if (Platform.isAndroid) {
      clearReceiveTempDir();
    }

    provider.addOnSendListener((name, path, code) {
      _sendFiles(name, path, false, code: code);
    });

    provider.addOnSendFolderListener((name, path, code) {
      _sendFolder(name, path, false, code: code);
    });

    provider.addOnSendTextListener((text, code) {
      _sendText(text, code: code);
    });

    provider.addOnReceiveListener((passphrase) {
      _receiveFile(passphrase);
    });

    provider.addOnSendTargetListener(_setSendTarget);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context, child) {
        return widget.child;
      },
      create: (context) => provider,
    );
  }

  /// register handler for intent shares coming from outside of app
  void registerIntentShareHandler() {
    final handler = ShareHandlerPlatform.instance;
    handler.getInitialSharedMedia().then((media) {
      if (media != null) _handleSharedMedia(media);
    });

    handler.sharedMediaStream.listen(_handleSharedMedia);
  }

  void _handleSharedMedia(SharedMedia media) {
    if (media.attachments != null && media.attachments!.isNotEmpty) {
      _sendIntentFile(media.attachments!);
    } else if (media.content != null) {
      _sendText(media.content!, causedByIntent: true);
    }
  }

  void registerIntentReceiveHandler() {
    AppLinks().uriLinkStream.listen((uri) {
      final transferUri = parseTransferUri(uri);
      if (transferUri == null) {
        AppLogger.debug('Ignoring non-transfer URI scheme: ${uri.scheme}');
        return;
      }
      if (transferUri.isLeader) {
        _setSendTarget(transferUri.code);
      } else {
        _receiveFile(transferUri.code);
      }
    });
  }

  void _sendText(String text,
      {bool causedByIntent = false, String? code}) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/message.txt');
    await tempFile.writeAsString(text);
    AppLogger.info('Sending text (${text.length} chars)');
    _sendFiles('message.txt', [tempFile.path], causedByIntent, code: code);
  }

  void _sendIntentFile(List<SharedAttachment?> attachments) async {
    final paths = attachments
        .where((e) => e != null)
        .map((e) => e!.path)
        .toList(growable: false);
    if (paths.isEmpty) {
      return;
    }

    AppLogger.info('Sending file via intent: ${paths.toString()}');

    // Copy intent files from shared container to temp directory on iOS
    final accessiblePaths = await _copyIntentFilesToTempDir(paths);
    _sendFiles(accessiblePaths[0].split('/').last, accessiblePaths, true);
  }

  _TransferReceiverState() {
    // Intent shares only on android and ios
    if (Platform.isAndroid || Platform.isIOS) {
      registerIntentShareHandler();
    }

    if (Platform.isAndroid || Platform.isIOS) {
      registerIntentReceiveHandler();
    }
  }
}
