import 'package:flutter/cupertino.dart';

class TransferProvider with ChangeNotifier {
  final List<Function(String name, List<String> paths)> _sendHandlers = [];
  final List<Function(String name, String path)> _sendFolderHandlers = [];
  final List<void Function(String passphrase)> _receiveHandlers = [];

  TransferProvider();

  void addOnSendListener(
      void Function(String name, List<String> paths) listener) {
    _sendHandlers.add(listener);
  }

  void addOnSendFolderListener(
      void Function(String name, String path) listener) {
    _sendFolderHandlers.add(listener);
  }

  void addOnReceiveListener(void Function(String passphrase) listener) {
    _receiveHandlers.add(listener);
  }

  void sendFiles(String name, List<String> paths) {
    for (final h in _sendHandlers) {
      h(name, paths);
    }
  }

  void sendFolder(String name, String path) {
    for (final h in _sendFolderHandlers) {
      h(name, path);
    }
  }

  void receiveFile(String passphrase) {
    for (final h in _receiveHandlers) {
      h(passphrase);
    }
  }
}
