import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/utils.dart';

String pad_text(String text, int amount) => ' ' * amount + text + ' ' * amount;

Widget highlight_text(BuildContext context, List<Match> matches, String text, {String? search_using, bool selectable = false, TextStyle? base_style, TextStyle? highlight_style, int pad_sides = 0}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);
  text = pad_text(text, pad_sides);

  int curr_ind = 0;
  List<TextSpan> highlighted_spans = [];
  for (Match match in matches) {
    highlighted_spans.add(TextSpan(text: text.substring(curr_ind, match.start)));
    highlighted_spans.add(TextSpan(text: text.substring(match.start, match.end), style: highlight_style ?? theme_colours.SEARCH_HIGHLIGHT_STYLE));
    curr_ind = match.end;
  }
  highlighted_spans.add(TextSpan(text: text.substring(curr_ind, text.length)));

  TextSpan span = TextSpan(children: highlighted_spans, style: base_style);
  if (selectable)
    return SelectableText.rich(span, cursorWidth: 0);
  else
    return Text.rich(span);
}
