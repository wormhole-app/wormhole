import 'package:logger/logger.dart';
import 'package:rotation_log/rotation_log.dart';

/// Application logger using rotation_log for file management
final rotLog = RotationLogger(RotationLogTerm.term(RotationLogTermEnum.daily));
final log = Logger(
  output: MultiOutput([ConsoleOutput(), RotationLogOutput(rotLog)]),
);

class AppLogger {
  /// Initialize the logger with daily rotation
  static Future<void> initialize() async {
    await rotLog.init();
    info('Logger initialized with daily rotation');
  }

  /// Archive logs and return the path to the zip file
  static Future<String> archiveLog() async {
    await log.close();
    final archivePath = await rotLog.archiveLog();
    await rotLog.init();
    return archivePath;
  }

  /// Close the logger
  static Future<void> close() async {
    await log.close();
  }

  /// Log methods for convenience
  static void debug(String message) => log.log(Level.debug, message);
  static void info(String message) => log.log(Level.info, message);
  static void warn(String message) => log.log(Level.warning, message);
  static void error(String message) => log.log(Level.error, message);
}
