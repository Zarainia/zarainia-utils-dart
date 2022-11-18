import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/theme.dart';

InputDecoration TextFieldBorder({
  required BuildContext context,
  String? hintText,
  String? labelText,
  bool? alignLabelWithHint,
  Widget? prefix,
  Widget? prefixIcon,
  Widget? suffix,
  Widget? suffixIcon,
  EdgeInsets? contentPadding,
  bool? isDense,
  Color? enabled_colour,
  Color? focused_colour,
  FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.always,
}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);
  return InputDecoration(
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: enabled_colour ?? theme_colours.BORDER_COLOUR, width: 1)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: focused_colour ?? theme_colours.ACCENT_COLOUR, width: 1)),
    hintText: hintText,
    labelText: labelText,
    alignLabelWithHint: alignLabelWithHint,
    prefix: prefix,
    prefixIcon: prefixIcon,
    suffix: suffix,
    suffixIcon: suffixIcon,
    contentPadding: contentPadding,
    isDense: isDense,
    floatingLabelBehavior: floatingLabelBehavior,
  );
}

InputDecoration TextFieldUnderline({
  required BuildContext context,
  String? hintText,
  String? labelText,
  bool? alignLabelWithHint,
  Widget? prefix,
  Widget? prefixIcon,
  Widget? suffix,
  Widget? suffixIcon,
  EdgeInsets? contentPadding,
  bool? isDense,
  Color? enabled_colour,
  Color? focused_colour,
  FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);
  return InputDecoration(
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: enabled_colour ?? theme_colours.BORDER_COLOUR, width: 1)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focused_colour ?? theme_colours.ACCENT_COLOUR, width: 1)),
    hintText: hintText,
    labelText: labelText,
    alignLabelWithHint: alignLabelWithHint,
    prefix: prefix,
    prefixIcon: prefixIcon,
    suffix: suffix,
    suffixIcon: suffixIcon,
    contentPadding: contentPadding,
    isDense: isDense,
    floatingLabelBehavior: floatingLabelBehavior,
  );
}

InputDecoration SmallFieldDecoration(BuildContext context, {String? hint, bool dense = true, bool show_error_text = true}) {
  return InputDecoration(hintText: hint, isDense: dense, errorStyle: !show_error_text ? TextStyle(height: 0.001, color: Colors.transparent) : null);
}

InputDecoration MultilineFieldDecoration(BuildContext context, {String? hint, bool dense = true, bool show_error_text = true}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);

  return InputDecoration(
    hintText: hint,
    isDense: dense,
    border: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.BORDER_COLOUR)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.ACCENT_COLOUR)),
    errorStyle: !show_error_text ? TextStyle(height: 0.001) : null,
  );
}
