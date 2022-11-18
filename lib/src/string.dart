bool caseless_match(String search_string, String text) {
  return text.toLowerCase().contains(search_string.toLowerCase());
}

String? empty_null(String? value) {
  if (value == null || value.trim().isNotEmpty) return value;
  return null;
}
