import 'package:flutter/cupertino.dart';

class TransferProvider with ChangeNotifier {
  final List<Function(String name, List<String> paths, String? code)>
      _sendHandlers = [];
  final List<Function(String name, String path, String? code)>
      _sendFolderHandlers = [];
  final List<void Function(String text, String? code)> _sendTextHandlers = [];
  final List<void Function(String? passphrase)> _receiveHandlers = [];
  final List<void Function(String code)> _sendTargetHandlers = [];

  TransferProvider();

  void addOnSendListener(
      void Function(String name, List<String> paths, String? code) listener) {
    _sendHandlers.add(listener);
  }

  void addOnSendFolderListener(
      void Function(String name, String path, String? code) listener) {
    _sendFolderHandlers.add(listener);
  }

  void addOnSendTextListener(
      void Function(String text, String? code) listener) {
    _sendTextHandlers.add(listener);
  }

  void addOnReceiveListener(void Function(String? passphrase) listener) {
    _receiveHandlers.add(listener);
  }

  void addOnSendTargetListener(void Function(String code) listener) {
    _sendTargetHandlers.add(listener);
  }

  /// [code]: a code made by the receiver to send to; null makes a new one.
  void sendFiles(String name, List<String> paths, {String? code}) {
    for (final h in _sendHandlers) {
      h(name, paths, code);
    }
  }

  /// [code]: a code made by the receiver to send to; null makes a new one.
  void sendFolder(String name, String path, {String? code}) {
    for (final h in _sendFolderHandlers) {
      h(name, path, code);
    }
  }

  /// [code]: a code made by the receiver to send to; null makes a new one.
  void sendText(String text, {String? code}) {
    for (final h in _sendTextHandlers) {
      h(text, code);
    }
  }

  void receiveFile(String passphrase) {
    for (final h in _receiveHandlers) {
      h(passphrase);
    }
  }

  /// Receive with a new code of ours, for the sender to send to.
  void receiveWithOwnCode() {
    for (final h in _receiveHandlers) {
      h(null);
    }
  }

  /// A receiver showed [code] for us to send to (role=leader QR code or link).
  void setSendTarget(String code) {
    for (final h in _sendTargetHandlers) {
      h(code);
    }
  }
}
