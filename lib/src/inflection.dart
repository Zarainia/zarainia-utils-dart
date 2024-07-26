import 'package:inflection2/inflection2.dart';

String auto_pluralize(String word, int count) {
  return count == 1 ? word : pluralize(word);
}

String comma_separated_list(List<String> items) {
  assert(items.isNotEmpty);
  if (items.length == 1)
    return items.first;
  else if (items.length == 2)
    return "${items.first} and ${items.last}";
  else
    return items.sublist(0, items.length - 1).map((item) => item).join(", ") + ", and " + items.last;
}
