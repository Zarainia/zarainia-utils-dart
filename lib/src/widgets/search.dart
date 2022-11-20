import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/theme.dart';
import 'form_style.dart';

class SearchField extends StatefulWidget {
  Function(String) on_search;
  String? hint;
  TextStyle? style;
  bool show_search_icon;
  TextEditingController? controller;

  SearchField({
    required this.on_search,
    this.hint = "Search",
    this.style,
    this.show_search_icon = true,
    this.controller,
  });

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return TextField(
      controller: controller,
      onChanged: widget.on_search,
      decoration: TextFieldBorder(
        context: context,
        hintText: widget.hint,
        isDense: true,
        prefixIcon: widget.show_search_icon
            ? Icon(
                Icons.search,
                color: theme_colours.ICON_COLOUR,
              )
            : null,
        suffixIcon: IconButton(
          icon: Icon(Icons.close),
          color: theme_colours.ICON_COLOUR,
          onPressed: () {
            controller.text = "";
            widget.on_search("");
          },
          tooltip: "Clear",
        ),
      ),
      // decoration: InputDecoration(hintText: widget.hint, border: InputBorder.none, focusedBorder: InputBorder.none),
      style: widget.style?.copyWith(fontSize: 20),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
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
