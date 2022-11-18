import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart' as constants;

final RegExp COLOUR_FORMAT_REGEX = RegExp(r"^#?[0-9a-f]{6}$");

Color colour_from_hex(String colour_code) {
  colour_code = colour_code.trim().toLowerCase();
  if (!COLOUR_FORMAT_REGEX.hasMatch(colour_code)) throw FormatException("Invalid colour code '${colour_code}'");
  String colour_int = colour_code.replaceAll('#', '0xff');
  return Color(int.parse(colour_int));
}

String hex_from_colour(Color colour) {
  return '#${colour.value.toRadixString(16)}';
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
  // int r_mean = (c1.red + c2.red) ~/ 2;
  // int r = c1.red - c2.red;
  // int g = c1.green - c2.green;
  // int b = c1.blue - c2.blue;
  // return sqrt((((512 + r_mean) * r * r) >> 8) + 4 * g * g + (((767 - r_mean) * b * b) >> 8));
}

extension ZarainiaColorExtension on Color {
  Brightness get brightness => get_colour_brightness(this);

  static Color fromHex(String colour_code) => colour_from_hex(colour_code);

  String toHex() => hex_from_colour(this);

  Color get contrasting_colour => get_constrasting_colour(this);
}

extension ZarainiaBrightnessExtension on Brightness {
  Brightness get inverse => this == Brightness.light ? Brightness.dark : Brightness.light;
}
