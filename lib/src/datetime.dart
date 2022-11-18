import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

String get_curr_datetime() {
  return DateTime.now().toUtc().toIso8601String();
}

String format_datetime(DateTime datetime) {
  return DateFormat("yyyy-MM-dd HH:mm:ss").format(datetime.toLocal());
}

String format_date(DateTime datetime) {
  return DateFormat("yyyy-MM-dd").format(datetime.toLocal());
}

String format_date_range(DateTimeRange datetime_range) {
  return "${format_date(datetime_range.start)} - ${format_date(datetime_range.end)}";
}

String format_datetime_range(DateTimeRange datetime_range) {
  return "${format_datetime(datetime_range.start)} - ${format_datetime(datetime_range.end)}";
}

String format_datetime_string(String datetime) {
  return format_datetime(DateTime.parse(datetime));
}

DateTime parse_to_date_only(String datetime_string) {
  var datetime = DateTime.parse(datetime_string);
  return DateTime.utc(datetime.year, datetime.month, datetime.day);
}
