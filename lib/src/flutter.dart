String fix_tabs(String text, {int indent_size = 4}) {
  return text.replaceAll('\t', ' ' * indent_size);
}
