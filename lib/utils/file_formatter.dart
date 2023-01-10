import 'dart:math';

double _log10(num x) => log(x) / ln10;

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    if (this <= 0) return '0';
    final base = base1024 ? 1024 : 1000;
    final units = base1024
        ? ['Bi', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB']
        : ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
    final digitGroups = (_log10(this) / _log10(base)).floor();
    return '${(this / pow(base, digitGroups)).toStringAsFixed(2)} ${units[digitGroups]}';
  }
}
