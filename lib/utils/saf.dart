import 'package:flutter/services.dart';

import 'logger.dart';

/// Bridge to the Android Storage Access Framework (SAF).
///
/// On modern Android, raw filesystem writes into a user-picked folder are
/// blocked by scoped storage. Instead we let the user grant access to a folder
/// via the system picker (which returns a persistable `content://` tree URI)
/// and write into it through the content resolver. See [issue #181].
class Saf {
  static const _channel = MethodChannel('eu.heili.wormhole/saf');

  /// Launch the system folder picker and return a persisted tree URI
  /// (`content://…`), or null if the user cancelled.
  static Future<String?> pickDirectory() async {
    try {
      return await _channel.invokeMethod<String>('pickDirectory');
    } on PlatformException catch (err) {
      AppLogger.error('SAF pickDirectory failed: ${err.message}');
      return null;
    }
  }

  /// Copy the file at [sourcePath] into the SAF folder [treeUri], creating a
  /// document named [fileName] (collision-safe). Returns the saved document URI.
  /// Throws a [PlatformException] if the copy fails.
  static Future<String> saveToTree({
    required String treeUri,
    required String sourcePath,
    required String fileName,
  }) async {
    final uri = await _channel.invokeMethod<String>('saveToTree', {
      'treeUri': treeUri,
      'sourcePath': sourcePath,
      'fileName': fileName,
    });
    if (uri == null) {
      throw PlatformException(code: 'saf', message: 'No URI returned');
    }
    return uri;
  }
}
