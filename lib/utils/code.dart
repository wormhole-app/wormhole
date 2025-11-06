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
