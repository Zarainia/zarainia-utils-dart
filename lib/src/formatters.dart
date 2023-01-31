import 'package:flutter/services.dart';

class RegexInputFormatter implements TextInputFormatter {
  final RegExp regex;

  RegexInputFormatter(this.regex);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue old_value, TextEditingValue new_value) {
    final old_valid = _is_valid(old_value.text);
    final new_valid = _is_valid(new_value.text);
    if (old_valid && !new_valid) {
      return old_value;
    }
    return new_value;
  }

  bool _is_valid(String value) {
    try {
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old_value, TextEditingValue new_value) {
    return TextEditingValue(
      text: new_value.text.toUpperCase(),
      selection: new_value.selection,
    );
  }
}

class FloatInputFormatter extends RegexInputFormatter {
  FloatInputFormatter(int? max_decimals) : super(RegExp(r"^(\d+(\.\d" + (max_decimals != null ? "{0,${max_decimals}}" : "+") + r")?)?$"));
}
