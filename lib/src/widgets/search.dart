import 'package:flutter/material.dart';
import 'package:zarainia_utils/src/exports.dart';

class SearchField extends StatelessWidget {
  final String search_string;
  final void Function(String) on_search;
  final String? hint;
  final TextStyle? style;
  final TextStyle? hint_style;
  final bool show_search_icon;

  SearchField({
    this.search_string = '',
    required this.on_search,
    this.hint = "Search",
    this.style,
    this.hint_style,
    this.show_search_icon = true,
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return StatedTextField(
      initial_text: search_string,
      on_changed: on_search,
      decoration: TextFieldBorder(
        context: context,
        hintText: hint,
        hintStyle: hint_style,
        isDense: true,
        prefixIcon: show_search_icon
            ? Icon(
                Icons.search,
                color: theme_colours.ICON_COLOUR,
              )
            : null,
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          color: theme_colours.ICON_COLOUR,
          onPressed: () => on_search(''),
          tooltip: "Clear",
        ),
      ),
      style: style,
    );
  }
}

class UpDownSwitch extends StatelessWidget {
  bool curr_value;
  Function(bool new_value) cubit_update_function;
  String label;

  UpDownSwitch({required this.curr_value, required this.label, required this.cubit_update_function});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return IconButton(
      onPressed: () => cubit_update_function(!curr_value),
      icon: Icon(curr_value ? Icons.arrow_upward : Icons.arrow_downward, color: theme_colours.ICON_COLOUR),
    );
  }
}
