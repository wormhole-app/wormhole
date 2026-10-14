import 'package:flutter_test/flutter_test.dart';
import 'package:wormhole/utils/code.dart';

TransferUri? parse(String link) => parseTransferUri(Uri.parse(link));

void main() {
  group('parseTransferUri', () {
    test('role=leader: whoever reads the link sends', () {
      expect(parse('wormhole-transfer:7-guitarist-revenge?role=leader'),
          (code: '7-guitarist-revenge', isLeader: true));
    });

    test('role=follower: whoever reads the link receives', () {
      expect(parse('wormhole-transfer:7-guitarist-revenge?role=follower'),
          (code: '7-guitarist-revenge', isLeader: false));
    });

    test('no role: whoever reads the link receives', () {
      expect(parse('wormhole-transfer:7-guitarist-revenge'),
          (code: '7-guitarist-revenge', isLeader: false));
    });

    test('an unknown role is rejected', () {
      expect(parse('wormhole-transfer:7-guitarist-revenge?role=boss'), isNull);
      expect(
          parse('wormhole-transfer:7-guitarist-revenge?role=LEADER'), isNull);
    });

    test('version and rendezvous are ignored', () {
      expect(
          parse('wormhole-transfer:7-guitarist-revenge?version=0'
              '&rendezvous=ws%3A%2F%2Frelay.example.org%3A4000%2Fv1'
              '&role=leader'),
          (code: '7-guitarist-revenge', isLeader: true));
    });

    test('other schemes are rejected', () {
      expect(parse('https://example.org/7-guitarist-revenge'), isNull);
      expect(parse('ShareMedia-eu.heili.wormhole:share'), isNull);
    });

    test('invalid codes are rejected', () {
      expect(parse('wormhole-transfer:guitarist-revenge?role=leader'), isNull);
      expect(parse('wormhole-transfer:?role=leader'), isNull);
      expect(parse('wormhole-transfer:7?role=leader'), isNull);
    });

    test('a query that is not valid UTF-8 is rejected, not thrown', () {
      expect(parse('wormhole-transfer:7-guitarist-revenge?role=%E0'), isNull);
      expect(parse('wormhole-transfer:7-guitarist-revenge?x=%FF&role=leader'),
          isNull);
    });
  });
}
