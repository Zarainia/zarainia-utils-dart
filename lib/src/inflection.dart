import 'package:inflection2/inflection2.dart';

String auto_pluralize(String word, int count) {
  return count == 1 ? word : pluralize(word);
}
