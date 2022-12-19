import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/theme.dart';

const TextStyle HIDDEN_ERROR_STYLE = TextStyle(height: 0.001, color: Colors.transparent);

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
  String? errorText,
  bool show_error_text = true,
  Color? error_colour,
}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);
  return InputDecoration(
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: enabled_colour ?? theme_colours.BORDER_COLOUR, width: 1)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: focused_colour ?? theme_colours.ACCENT_COLOUR, width: 1)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: error_colour ?? theme_colours.ERROR_BORDER_COLOUR, width: 1)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: error_colour ?? theme_colours.BRIGHTER_ERROR_BORDER_COLOUR, width: 1)),
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
    errorText: errorText,
    errorStyle: show_error_text ? TextStyle(color: theme_colours.ERROR_TEXT_COLOUR) : HIDDEN_ERROR_STYLE,
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
  String? errorText,
  bool show_error_text = true,
  Color? error_colour,
}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);
  return InputDecoration(
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: enabled_colour ?? theme_colours.BORDER_COLOUR, width: 1)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focused_colour ?? theme_colours.ACCENT_COLOUR, width: 1)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: error_colour ?? theme_colours.ERROR_BORDER_COLOUR, width: 1)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: error_colour ?? theme_colours.ERROR_BORDER_COLOUR, width: 1)),
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
    errorText: errorText,
    errorStyle: show_error_text ? TextStyle(color: theme_colours.ERROR_TEXT_COLOUR) : HIDDEN_ERROR_STYLE,
  );
}

InputDecoration SmallFieldDecoration(BuildContext context, {String? hint, bool dense = true, bool show_error_text = true}) {
  return InputDecoration(
    hintText: hint,
    isDense: dense,
    errorStyle: !show_error_text ? HIDDEN_ERROR_STYLE : null,
  );
}

InputDecoration MultilineFieldDecoration(BuildContext context, {String? hint, bool dense = true, bool show_error_text = true}) {
  ZarainiaTheme theme_colours = get_zarainia_theme(context);

  return InputDecoration(
    hintText: hint,
    isDense: dense,
    border: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.BORDER_COLOUR)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.ACCENT_COLOUR)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.ERROR_BORDER_COLOUR)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: theme_colours.ERROR_BORDER_COLOUR)),
    errorStyle: !show_error_text ? HIDDEN_ERROR_STYLE : null,
  );
}
