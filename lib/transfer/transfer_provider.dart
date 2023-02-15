import 'package:flutter/cupertino.dart';

class TransferProvider with ChangeNotifier {
  final List<Function(String name, String path)> _sendHandlers = [];
  final List<void Function(String passphrase)> _receiveHandlers = [];

  TransferProvider();

  void addOnSendListener(void Function(String name, String path) listener) {
    _sendHandlers.add(listener);
  }

  void addOnReceiveListener(void Function(String passphrase) listener) {
    _receiveHandlers.add(listener);
  }

  void sendFile(String name, String path) {
    for (final h in _sendHandlers) {
      h(name, path);
    }
  }

  void receiveFile(String passphrase) {
    for (final h in _receiveHandlers) {
      h(passphrase);
    }
  }
}
