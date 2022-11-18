import 'dart:async';

import 'package:flutter/cupertino.dart';

Future<T2> apply_to_future<T1, T2>(Future<T1> value, T2 Function(T1) func) async {
  return func(await value);
}

extension ZarainiaFutureExtension<T> on Future<T> {
  Future apply<T2>(T2 Function(T) func) => apply_to_future(this, func);

  Widget builder(Widget Function(BuildContext context, AsyncSnapshot<T> snapshot) _builder) {
    return FutureBuilder<T>(future: this, builder: _builder);
  }
}

Future<List<T>> where_future<T>(Iterable<T> iterable, FutureOr<bool> Function(T) future_test) async {
  List<T> results = [];
  for (T element in iterable) {
    if (await future_test(element)) results.add(element);
  }
  return results;
}

extension ZarainiaIterableExtension<T> on Iterable<T> {
  Future<List<T>> whereFuture(FutureOr<bool> Function(T) future_test) {
    return where_future(this, future_test);
  }
}
