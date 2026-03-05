import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'logger.dart';

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      // Derive the public Downloads path from the app-specific external storage
      // directory. This handles secondary user profiles correctly (e.g.
      // /storage/emulated/14/Download instead of /storage/emulated/0/Download).
      final extDir = await getExternalStorageDirectory();
      AppLogger.debug('External storage directory: ${extDir?.path}');
      if (extDir != null) {
        final rootPath = extDir.path.split('/Android/').first;
        final downloadsDir = Directory('$rootPath/Download');
        AppLogger.debug('Derived downloads directory: ${downloadsDir.path}');
        directory = await downloadsDir.exists() ? downloadsDir : extDir;
      }
    } else {
      directory = await getDownloadsDirectory();
    }
  } catch (err) {
    AppLogger.error('Cannot get download folder path: $err');
  }
  return directory?.path;
}
