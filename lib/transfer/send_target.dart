import 'package:flutter/foundation.dart';

/// A code made by the receiver to send to, set by a role=leader QR code or
/// link, or typed in. While set, the send page sends to it instead of making
/// a new code. Codes are single-use, so a send takes it.
class SendTarget with ChangeNotifier {
  String? _code;

  String? get code => _code;

  set code(String? code) {
    if (code == _code) return;
    _code = code;
    notifyListeners();
  }

  /// Returns the code for a send that starts now, and clears it.
  String? take() {
    final code = _code;
    this.code = null;
    return code;
  }
}
