// regex to match code validity
final RegExp _regex = RegExp(r'^\d+-[^\s]*$');

/// validate syntax of correction code
bool isCodeValid(String code) {
  return _regex.hasMatch(code);
}
