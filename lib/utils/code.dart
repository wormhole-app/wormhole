// regex to match code validity
final RegExp _regex = RegExp(r'^\d+-[^\s]*$');

/// Demo code for App Store review (simulates file transfer without server)
const String demoCode =
    '999763-demoooooo-mode-transfer-that-should-never-collide';

/// Check if the provided code is the demo code
bool isDemoCode(String code) {
  return code == demoCode;
}

/// validate syntax of correction code
bool isCodeValid(String code) {
  return _regex.hasMatch(code);
}

/// A `wormhole-transfer:` link: with `isLeader` (`role=leader`) whoever reads
/// it sends to `code`, otherwise they receive from it.
typedef TransferUri = ({String code, bool isLeader});

/// Parse a Wormhole transfer link, `wormhole-transfer:<code>?role=…`.
///
/// Returns null for an invalid code or an unknown role. Other URL schemes are
/// used internally on iOS (for example, the share extension's `ShareMedia-…`
/// handoff) and must not enter a transfer flow either.
TransferUri? parseTransferUri(Uri uri) {
  if (uri.scheme != 'wormhole-transfer' || !isCodeValid(uri.path)) {
    return null;
  }
  final String? role;
  try {
    role = uri.queryParameters['role'];
  } on FormatException {
    // a percent escape that is no valid UTF-8 (`?role=%E0`)
    return null;
  }
  if (role != null && role != 'leader' && role != 'follower') {
    return null;
  }
  return (code: uri.path, isLeader: role == 'leader');
}
