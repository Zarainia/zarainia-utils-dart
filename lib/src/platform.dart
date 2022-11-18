import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

enum PlatformName { WINDOWS, LINUX, WEB, ANDROID, IOS, MACOS, FUCHSIA, ERROR }

PlatformName get_platform() {
  if (kIsWeb)
    return PlatformName.WEB;
  else {
    if (Platform.isWindows) return PlatformName.WINDOWS;
    if (Platform.isLinux) return PlatformName.LINUX;
    if (Platform.isAndroid) return PlatformName.ANDROID;
    if (Platform.isIOS) return PlatformName.IOS;
    if (Platform.isMacOS) return PlatformName.MACOS;
    if (Platform.isFuchsia) return PlatformName.FUCHSIA;
  }
  return PlatformName.ERROR;
}

extension PlatformNameExtension on PlatformName {
  bool get is_web => this == PlatformName.WEB;

  bool get is_windows => this == PlatformName.WINDOWS;

  bool get is_linux => this == PlatformName.LINUX;

  bool get is_android => this == PlatformName.ANDROID;

  bool get is_ios => this == PlatformName.IOS;

  bool get is_macos => this == PlatformName.MACOS;

  bool get is_fuchsia => this == PlatformName.FUCHSIA;

  bool get is_desktop => this == PlatformName.WINDOWS || this == PlatformName.LINUX || this == PlatformName.MACOS;
}

bool is_desktop() {
  var platform = get_platform();
  return platform.is_desktop;
}
