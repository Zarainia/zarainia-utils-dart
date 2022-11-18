import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'utils.dart';

abstract class Freezable {
  freeze();
}

class Updatable<T> {
  T? curr_value;
  Stream<T?> future_values;
  bool frozen = false;

  CompositeSubscription subscription = CompositeSubscription();

  Updatable({required this.curr_value, required this.future_values}) {
    assert(future_values.isBroadcast);
    subscription.add(future_values.listen((event) {
      curr_value = event;
    }));
  }

  void dispose() {
    subscription.cancel();
  }

  void always_apply(Function(T) func) {
    subscription.add(future_values.listen((value) {
      if (value != null) func(value);
    }));
    if (curr_value != null) func(curr_value!);
  }

  Widget builder(Widget Function(T) builder, {Widget? null_display, bool allow_null = false}) {
    return StreamBuilder<T?>(
      initialData: curr_value,
      stream: future_values,
      builder: (context, snapshot) {
        if (null is T || curr_value != null)
          return builder(curr_value as T);
        else if (builder is Widget Function(T?) && allow_null)
          return builder(curr_value);
        else {
          if (null_display == null) log("updatable value is null: ${this}");
          return null_display ?? EmptyContainer();
        }
      },
    );
  }

  Widget display({String Function(T)? display_converter, TextStyle? style, bool selectable = false}) {
    return builder((T value) {
      String display_text = display_converter?.call(value) ?? value.toString();
      if (selectable)
        return PaddinglessSelectableText(display_text, style: style);
      else
        return Text(display_text, style: style);
    });
  }

  static bool freeze_content(var object) {
    // TODO: add copying
    if (object is Freezable) {
      object.freeze();
      return true;
    }
    return false;
  }

  void freeze() {
    subscription.cancel();
    future_values = Stream.empty();
    if (curr_value is Iterable) {
      for (var value in (curr_value as Iterable)) {
        freeze_content(value);
      }
    } else
      freeze_content(curr_value);
    frozen = true;
  }

  @override
  String toString() {
    return "Updatable(${curr_value}: ${future_values})";
  }

  Updatable<T2> map<T2>(T2? Function(T?) convertor) {
    return from_map(curr_value, future_values, convertor);
  }

  static Updatable<T2> from_map<T1, T2>(T1 curr_value, Stream<T1> stream, T2? Function(T1) convertor) {
    return Updatable(curr_value: convertor(curr_value), future_values: stream.map(convertor).asBroadcastStream());
  }

  static Updatable<T> from_value<T>(T value) {
    return Updatable(curr_value: value, future_values: Stream.empty());
  }

  static Updatable<T2> combine_list<T1, T2>(Iterable<Updatable<T1>?>? updatables, T2? Function(Iterable<T1?>) convertor) {
    return Updatable(
      curr_value: convertor(updatables?.map((updatable) => updatable?.curr_value) ?? []),
      future_values: CombineLatestStream(updatables?.map((updatable) => updatable?.future_values ?? Stream.fromIterable(<T1?>[])) ?? <Stream<T1?>>[], convertor).asBroadcastStream(),
    );
  }

  static Updatable<O> combine2<T1, T2, O>(Updatable<T1> updatable1, Updatable<T2> updatable2, O? Function(T1?, T2?) convertor) {
    return Updatable(
      curr_value: convertor(updatable1.curr_value, updatable2.curr_value),
      future_values: Rx.combineLatest2(updatable1.future_values, updatable2.future_values, convertor).asBroadcastStream(),
    );
  }

  static Updatable<O> combine3<T1, T2, T3, O>(Updatable<T1> updatable1, Updatable<T2> updatable2, Updatable<T3> updatable3, O? Function(T1?, T2?, T3?) convertor) {
    return Updatable(
      curr_value: convertor(updatable1.curr_value, updatable2.curr_value, updatable3.curr_value),
      future_values: Rx.combineLatest3(updatable1.future_values, updatable2.future_values, updatable3.future_values, convertor).asBroadcastStream(),
    );
  }

  static Updatable<T> flatten<T>(Updatable<Updatable<T>> updatable) {
    return Updatable(
        curr_value: updatable.curr_value?.curr_value,
        future_values: updatable.future_values.map((event) => event?.future_values).startWith(updatable.curr_value?.future_values).whereType<Stream<T?>>().flatten());
  }

  static Updatable<Map<K, List<T>>> group_by<T, K>(Updatable<Iterable<T>> list, Updatable<K> Function(T) grouper) {
    return list.map((list) {
      Iterable<Updatable<MapEntry<K?, T>>> keys = (list ?? const []).map((value) => grouper(value).map((key) => MapEntry(key, value)));

      return keys.combine((entries) {
        DefaultMap<K, List<T>> map = DefaultMap(() => []);
        for (MapEntry<K?, T>? value in entries) {
          if (value != null && value.key != null) {
            map[value.key].add(value.value);
          }
        }
        return map;
      });
    }).flatten();
  }
}

extension NullableUpdatableExtension<T> on Updatable<T>? {
  Widget builder(Widget Function(T?) builder, {Widget? null_display}) {
    if (this == null) {
      return null_display ?? builder(null);
    }
    return this!.builder(builder, null_display: null_display, allow_null: true);
  }
}

extension IterableUpdatableExtension<T> on Iterable<Updatable<T>?> {
  Updatable<T2> combine<T2>(T2? Function(Iterable<T?>) convertor) => Updatable.combine_list(this, convertor);
}

extension IterableExtension<T> on Iterable<T> {
  Updatable<T?> firstUpdatableWhereOrNull(Updatable<bool> Function(T e) query) {
    Iterable<Updatable<Tuple2<bool?, T>>> results = map((e) => query(e).map((result) => Tuple2(result, e)));
    return Updatable.combine_list(results, (Iterable<Tuple2<bool?, T>?> results) => results.firstWhereOrNull((element) => element?.element1 ?? false)?.element2);
  }

  Updatable<Iterable<T>> whereUpdatable(Updatable<bool> Function(T e) query) {
    Iterable<Updatable<Tuple2<bool?, T>>> results = map((e) => query(e).map((result) => Tuple2(result, e)));
    return Updatable.combine_list(results, (Iterable<Tuple2<bool?, T>?> results) => results.where((result) => result?.element1 ?? false).whereNotNull().map((e) => e.element2));
  }
}

extension UpdatableUpdatableExtension<T> on Updatable<Updatable<T>> {
  Updatable<T> flatten() => Updatable.flatten(this);
}
