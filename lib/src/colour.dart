import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart' as constants;

final RegExp COLOUR_FORMAT_REGEX = RegExp(r"^#?([0-9a-f]{6}|[0-9a-f]{8})$");

Color colour_from_hex(String colour_code) {
  colour_code = colour_code.trim().toLowerCase();
  String colour_int;
  Match? match = COLOUR_FORMAT_REGEX.firstMatch(colour_code);
  if (match != null && match[1] != null) {
    colour_int = match[1]!;
  } else {
    throw FormatException("Invalid colour code '${colour_code}'");
  }
  colour_int = '0x' + ('f' * (8 - colour_int.length)) + colour_int;
  return Color(int.parse(colour_int));
}

String hex_from_colour(Color colour) {
  List<int> components = [colour.alpha, colour.red, colour.green, colour.blue];
  var hex = '#';
  for (int value in components) {
    hex += value.toRadixString(16).padLeft(2, '0');
  }
  return hex;
}

Brightness get_colour_brightness(Color colour) {
  final double relativeLuminance = colour.computeLuminance();
  if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > constants.BRIGHTNESS_THRESHOLD) return Brightness.light;
  return Brightness.dark;
}

Color get_constrasting_colour(Color colour) {
  return get_colour_brightness(colour) == Brightness.light ? Colors.black : Colors.white;
}

double colour_contrast_ratio(Color c1, Color c2) {
  double l1 = c1.computeLuminance();
  double l2 = c2.computeLuminance();
  if (l1 > l2)
    return (l1 + 0.05) / (l2 + 0.05);
  else
    return (l2 + 0.05) / (l1 + 0.05);
}

double colour_distance(Color c1, Color c2) {
  return sqrt((c2.red - c1.red) * (c2.red - c1.red) + (c2.blue - c1.blue) * (c2.blue - c1.blue) + (c2.green - c1.green) * (c2.green - c1.green));
}

extension ZarainiaColorExtension on Color {
  Brightness get brightness => get_colour_brightness(this);

  static Color fromHex(String colour_code) => colour_from_hex(colour_code);

  String toHex() => hex_from_colour(this);

  Color get contrasting_colour => get_constrasting_colour(this);

  Color invert() => Color.fromRGBO(255 - red, 255 - green, 255 - blue, opacity);
}

extension ZarainiaBrightnessExtension on Brightness {
  Brightness get inverse => this == Brightness.light ? Brightness.dark : Brightness.light;
}
