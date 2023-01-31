typedef InputValidationFunction = String? Function(String? text);

abstract class InputValidator {
  final String field;

  const InputValidator({this.field = "value"});

  String get invalid_message => "Invalid ${field}";

  String? call(String? text);
}

class EmptyValidator extends InputValidator {
  final bool allow_null;
  final bool allow_empty;

  const EmptyValidator({super.field, this.allow_null = false, this.allow_empty = false});

  @override
  String get invalid_message => "${field} cannot be empty";

  @override
  String? call(String? text) {
    if ((!allow_null && text == null) || (!allow_empty && (text?.isEmpty ?? true))) return invalid_message;
    return null;
  }
}

class CompoundValidator extends InputValidator {
  final Iterable<InputValidationFunction> validators;

  const CompoundValidator({super.field, required this.validators});

  @override
  String? call(String? text) {
    for (InputValidationFunction func in validators) {
      String? result = func(text);
      if (result != null) return result;
    }
    return null;
  }
}

class FloatValidator extends InputValidator {
  final double? minimum;
  final double? maximum;
  final EmptyValidator empty_handler;

  FloatValidator({super.field = "float", this.minimum = 0, this.maximum, EmptyValidator? empty_handler}) : empty_handler = EmptyValidator(field: field, allow_null: true, allow_empty: true);

  String? call(String? text) {
    if (text == null || text.isEmpty) {
      return empty_handler(text);
    }
    try {
      double value = double.parse(text);
      if ((minimum != null && value < minimum!) || (maximum != null && value > maximum!)) return "${field} not within range";
    } on FormatException catch (_) {
      return invalid_message;
    }
    return null;
  }
}

class IntegerValidator {
  final String field;
  final int? minimum;
  final int? maximum;
  final EmptyValidator empty_handler;

  IntegerValidator({this.field = "integer", this.minimum = 0, this.maximum, EmptyValidator? empty_handler}) : empty_handler = EmptyValidator(field: field, allow_null: true, allow_empty: true);

  String? call(String? text) {
    if (text == null || text.isEmpty) {
      return empty_handler(text);
    }
    try {
      int value = int.parse(text);
      if ((minimum != null && value < minimum!) || (maximum != null && value > maximum!)) return "${field} not within range";
    } on FormatException catch (_) {
      return "Invalid ${field}";
    }
    return null;
  }
}
