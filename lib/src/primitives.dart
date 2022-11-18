int bool_to_int(bool value) => value ? 1 : 0;

extension ZarainiaBoolExtension on bool {
  int toInt() => bool_to_int(this);
}
