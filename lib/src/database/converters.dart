bool db_to_bool(int value) => value == 1;

DateTime db_to_datetime(String value) => DateTime.parse(value);

String datetime_to_db(DateTime value) => value.toIso8601String();

bool db_string_to_bool(String? value) => value! == "true";

int db_string_to_int(String? value) => int.parse(value!);

double db_string_to_double(String? value) => double.parse(value!);

double? db_string_to_nullable_double(String? value) => value != null && value != "null" ? double.parse(value) : null;
