import 'package:logger/logger.dart';
import 'package:rotation_log/rotation_log.dart';

/// Application logger using rotation_log for file management
final term = RotationLogTerm.term(RotationLogTermEnum.daily);
final log = RotationLogger(term);

class AppLogger {
  /// Initialize the logger with daily rotation
  static Future<void> initialize() async {
    await log.init();
    info('Logger initialized with daily rotation');
  }

  /// Archive logs and return the path to the zip file
  static Future<String> archiveLog() async {
    await log.close();
    final archivePath = await log.archiveLog();
    await log.init();
    return archivePath;
  }

  /// Close the logger
  static Future<void> close() async {
    await log.close();
  }

  /// Log methods for convenience
  static void info(String message) => log.log(Level.info, message);
  static void warning(String message) => log.log(Level.warning, message);
  static void severe(String message) => log.log(Level.error, message);
  static void fine(String message) => log.log(Level.debug, message);
}
