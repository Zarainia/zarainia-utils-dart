import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:zarainia_utils/src/exports.dart';

class Hasher {
  final IList<Object?> fields;

  const Hasher(this.fields);

  int hash() => Object.hashAll(fields);

  Hasher add(Object? field) => Hasher(fields.add(field));

  Hasher add_all(Iterable<Object?> f) => Hasher(fields.addAll(fields));

  @override
  int get hashCode => Object.hashAll(["Hasher", ...fields]);

  @override
  bool operator ==(Object other) => other is Hasher && fields == other.fields;

  @override
  String toString() => "Hasher(${fields})";
}

abstract class Hashable {
  const Hashable();

  Hasher get hasher;

  @override
  int get hashCode => hasher.hash();
}

abstract class Serializable extends Hashable {
  static int json_hashcode(Serializable o) => Object.hashAll(o.to_json().entries);

  static bool json_shallow_compare(Serializable o, Object other) {
    if (other is! Serializable || other.runtimeType != o.runtimeType) return false;

    Map<String, dynamic> json = o.to_json();
    Map<String, dynamic> other_json = other.to_json();
    for (MapEntry<String, dynamic> entry in json.entries) {
      if (other_json[entry.key] != entry.value) return false;
    }
    for (MapEntry<String, dynamic> entry in other_json.entries) {
      if (json[entry.key] != entry.value) return false;
    }
    return true;
  }

  const Serializable();

  Map<String, dynamic> to_json();

  @override
  Hasher get hasher => Hasher(to_json().entries.map((e) => ITuple2(e.key, e.value)).cast<Object?>().toIList());

  @override
  bool operator ==(Object other) => json_shallow_compare(this, other);

  @override
  String toString() => "${runtimeType}(${to_json().map((key, value) => MapEntry(key, value is Uint8List ? "${value.lengthInBytes} bytes" : value)).toString()})";
}
