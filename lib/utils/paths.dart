import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

// Android is intentionally excluded: scoped storage blocks raw writes into a
// user-picked folder, so the Android receive flow uses the Storage Access
// Framework instead (see [Saf] and TransferReceiver). Desktop platforms get a
// real, writable filesystem path here.
bool _canAskForDownloadFolder() => Platform.isWindows || Platform.isMacOS;

/// App-owned scratch directory the Rust backend can always write to without
/// permissions. Used to stage received files before copying them into a
/// SAF-picked folder on Android. Prefers external cache for the larger quota.
Future<Directory> getReceiveTempDir() async {
  Directory base;
  if (Platform.isAndroid) {
    final extCaches = await getExternalCacheDirectories();
    base = (extCaches != null && extCaches.isNotEmpty)
        ? extCaches.first
        : await getTemporaryDirectory();
  } else {
    base = await getTemporaryDirectory();
  }
  final dir = Directory('${base.path}/received');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Remove staged files left behind by previous SAF receives.
Future<void> clearReceiveTempDir() async {
  try {
    final dir = await getReceiveTempDir();
    await for (final entity in dir.list()) {
      await entity.delete(recursive: true);
    }
  } catch (err) {
    AppLogger.warn('Could not clear receive temp dir: $err');
  }
}

Future<String?> getDownloadPath({bool askForFolder = false}) async {
  if (askForFolder && _canAskForDownloadFolder()) {
    try {
      final selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory != null) {
        return selectedDirectory;
      }
      AppLogger.info('Download folder selection cancelled');
      return null;
    } catch (err) {
      AppLogger.error('Cannot select download folder path: $err');
      return null;
    }
  }

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
