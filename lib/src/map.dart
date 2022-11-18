import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';

class DefaultMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map = LinkedHashMap();
  final V Function() _default;

  DefaultMap(this._default);

  @override
  V operator [](Object? key) => _map.putIfAbsent(key as K, _default);

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);

  static DefaultMap<K, V> from_map<K, V>(V Function() _default, Map<K, V> map) {
    DefaultMap<K, V> default_map = DefaultMap(_default);
    map.forEach((key, value) {
      default_map[key] = value;
    });
    return default_map;
  }
}

class InvertibleMap<K> implements Map<K, K> {
  final Map<K, K> _map;

  const InvertibleMap([Map<K, K>? map]) : _map = map != null ? map : const {};

  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  void addAll(Map<K, K> other) {
    _map.addAll(other);
  }

  void clear() {
    _map.clear();
  }

  K putIfAbsent(K key, K ifAbsent()) => _map.putIfAbsent(key, ifAbsent);

  bool containsKey(Object? key) => _map.containsKey(key);

  bool containsValue(Object? value) => _map.containsValue(value);

  void forEach(void action(K key, K value)) {
    _map.forEach(action);
  }

  bool get isEmpty => _map.isEmpty;

  bool get isNotEmpty => _map.isNotEmpty;

  int get length => _map.length;

  Iterable<K> get keys => _map.keys.followedBy(_map.values);

  String toString() => _map.toString();

  Iterable<K> get values => _map.values.followedBy(_map.keys);

  Iterable<MapEntry<K, K>> get entries => _map.entries;

  void addEntries(Iterable<MapEntry<K, K>> entries) {
    _map.addEntries(entries);
  }

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> transform(K key, K value)) => _map.map<K2, V2>(transform);

  K update(K key, K update(K value), {K Function()? ifAbsent}) => _map.update(key, update, ifAbsent: ifAbsent);

  void updateAll(K update(K key, K value)) {
    _map.updateAll(update);
  }

  void removeWhere(bool test(K key, K value)) {
    _map.removeWhere(test);
  }

  @override
  K? operator [](Object? key) => _map[key as K] ?? _map.entries.firstWhereOrNull((entry) => entry.value == key)?.key;

  @override
  void operator []=(K key, K value) => _map[key] = value;

  @override
  K? remove(Object? key) => _map.remove(key);
}

dynamic deepcopy_json(dynamic v) {
  return json.decode(json.encode(v));
}

Map<String, T> deepcopy_json_map<T>(Map<String, T> m) {
  return (deepcopy_json(m) as Map).cast<String, T>();
}

List<T> deepcopy_json_list<T>(List<T> l) {
  return (deepcopy_json(l) as List).cast<T>();
}