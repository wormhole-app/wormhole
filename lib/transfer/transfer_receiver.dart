import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_close_app/flutter_close_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:app_links/app_links.dart';

import '../l10n/app_localizations.dart';
import '../src/rust/api/wormhole.dart';
import '../navigation/navigation_provider.dart';
import '../pages/connecting_page.dart';
import '../pages/toasts/error_toast.dart';
import '../pages/transfer_widgets/transfer_finished.dart';
import '../settings/settings.dart';
import '../utils/paths.dart';
import '../utils/logger.dart';
import 'transfer_provider.dart';

class TransferReceiver extends StatefulWidget {
  const TransferReceiver({super.key, required this.child});

  final Widget child;

  @override
  State<TransferReceiver> createState() => _TransferReceiverState();
}

class _TransferReceiverState extends State<TransferReceiver> {
  final provider = TransferProvider();

  void _sendFolder(String name, String path, bool causedByIntent) async {
    final codeLength = (await Settings.getWordLength()) ?? Defaults.wordlength;

    final stream = sendFolder(
        folderPath: path,
        name: name,
        codeLength: codeLength,
        serverConfig: await _getServerConfig());
    _showConnectionPage(stream, causedByIntent);
  }

  void _sendFiles(
      String name, List<String> filepaths, bool causedByIntent) async {
    final codeLength = (await Settings.getWordLength()) ?? Defaults.wordlength;
    final stream = sendFiles(
        name: name,
        filePaths: filepaths,
        codeLength: codeLength,
        serverConfig: await _getServerConfig());

    _showConnectionPage(stream, causedByIntent);
  }

  void _showConnectionPage(Stream<TUpdate> stream, bool causedByIntent) {
    if (!mounted) return;
    Provider.of<NavigationProvider>(context, listen: false).push(ConnectingPage(
        key: UniqueKey(),
        stream: stream,
        finish: (file) {
          if (Platform.isAndroid || Platform.isIOS) {
            // delete temporary files cached by file_picker
            FilePicker.platform.clearTemporaryFiles();

            // auto close app if share cause was an intent
            // this happens only if share was successful
            if (causedByIntent) {
              Future.delayed(const Duration(seconds: 1)).then((value) async {
                await FlutterCloseApp().closeAndRemoveApp();
              });
            }
          }

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
                    child: Text(AppLocalizations.of(context)!
                        .transfer_finished_send_label),
                  ),
                ]),
          );
        }));
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

  void _receiveFile(String passphrase) async {
    final dpath = await getDownloadPath();
    if (dpath == null) {
      AppLogger.warn('No download path available');
      return;
    }

    // we need storage permission to store files
    if (!(Platform.isAndroid || Platform.isIOS) ||
        (Platform.isAndroid &&
            (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33) ||
        await Permission.storage.request().isGranted) {
      final s = requestFile(
          passphrase: passphrase,
          storageFolder: dpath,
          serverConfig: await _getServerConfig());
      if (!mounted) return;
      Provider.of<NavigationProvider>(context, listen: false).push(
        ConnectingPage(
          key: UniqueKey(),
          stream: s,
          finish: (file) => ReceiveFinished(file: file),
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

  @override
  void initState() {
    super.initState();

    provider.addOnSendListener((name, path) {
      _sendFiles(name, path, false);
    });

    provider.addOnSendFolderListener((name, path) {
      _sendFolder(name, path, false);
    });

    provider.addOnReceiveListener((passphrase) {
      _receiveFile(passphrase);
    });
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
      if (media?.attachments != null) {
        _sendIntentFile(media!.attachments!);
      }
    });

    handler.sharedMediaStream.listen((SharedMedia media) {
      if (media.attachments != null) {
        _sendIntentFile(media.attachments!);
      }
    });
  }

  void registerIntentReceiveHandler() {
    AppLinks().uriLinkStream.listen((uri) {
      _receiveFile(uri.path);
    });
  }

  void _sendIntentFile(List<SharedAttachment?> attachments) {
    final paths = attachments
        .where((e) => e != null)
        .map((e) => e!.path)
        .toList(growable: false);
    if (paths.isEmpty) {
      return;
    }

    AppLogger.info('Sending file via intent: ${paths.toString()}');
    _sendFiles(paths[0].split('/').last, paths, true);
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
