T2? null_arg<T1, T2>(T1? value, T2 Function(T1) func) {
  return value != null ? func(value) : null;
}

int compare_null<T>(T? a, T? b, int Function(T, T) compare, {bool to_end = false, Function()? default_comparator}) {
  int null_result = default_comparator != null ? 0 : (to_end ? 1 : -1);

  int result;
  if (a == null)
    result = null_result;
  else if (b == null)
    result = -null_result;
  else
    result = compare(a, b);

  if (default_comparator != null && result == 0)
    return default_comparator();
  else
    return result;
}

int nullable_comparable<T extends Comparable>(T? a, T? b, {bool to_end = false, Function()? default_comparator}) {
  return compare_null<T>(a, b, (x, y) => x.compareTo(y), to_end: to_end, default_comparator: default_comparator);
}
