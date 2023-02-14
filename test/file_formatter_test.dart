import 'package:flutter_test/flutter_test.dart';
import 'package:wormhole/utils/file_formatter.dart';

void main() {
  group('file_formatter', () {
    test('kb', () {
      const i = 300000;
      expect(i.readableFileSize(base1024: false), '300.00 KB');
    });

    test('mb', () {
      const i = 412045123;
      expect(i.readableFileSize(base1024: false), '412.05 MB');
    });

    test('gb', () {
      const i = 98124045123;
      expect(i.readableFileSize(base1024: false), '98.12 GB');
    });

    test('mib', () {
      const i = 412045123;
      expect(i.readableFileSize(), '392.96 MiB');
    });

    test('tib', () {
      const i = 41204512926453;
      expect(i.readableFileSize(), '37.48 TiB');
    });
  });
}
