final RegExp WHITESPACE_REGEX = RegExp(r"\s+");

bool caseless_match(String search_string, String text) {
  return text.toLowerCase().contains(search_string.toLowerCase());
}

String? empty_null(String? value) {
  if (value == null || value.trim().isNotEmpty) return value;
  return null;
}

List<String> split_whitespace(String string) {
  return string.split(WHITESPACE_REGEX);
}

extension ZarainiaStringExtension on String {
  List<String> splitWhitespace() => split_whitespace(this);
}
