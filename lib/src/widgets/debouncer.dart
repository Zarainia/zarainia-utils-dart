import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer<T> extends StatefulWidget {
  final T value;
  final FutureOr<void> Function(T value) on_change;
  final Widget Function(BuildContext context, T value, void Function(T) on_change) builder;
  final int period_ms;

  const Debouncer({
    super.key,
    required this.value,
    required this.on_change,
    required this.builder,
    this.period_ms = 500,
  });

  @override
  _DebouncerState<T> createState() => _DebouncerState<T>();
}

class _DebouncerState<T> extends State<Debouncer<T>> {
  Timer? timer;
  Set<int> pending_updates = {};

  late T curr_value;

  @override
  void initState() {
    curr_value = widget.value;
    super.initState();
  }

  void execute(T new_value) {
    setState(() {
      curr_value = new_value;
    });
    timer?.cancel();
    timer = Timer(Duration(milliseconds: widget.period_ms), () {
      timer = null;
      FutureOr<void> result = widget.on_change(new_value);
      Future<void> pending_update = result is Future ? result : Future.value();
      pending_updates.add(pending_update.hashCode);
      pending_update.then((_) => pending_updates.remove(pending_update.hashCode));
    });
  }

  @override
  void didUpdateWidget(covariant Debouncer<T> oldWidget) {
    if (oldWidget.value != widget.value && widget.value != curr_value && timer == null && pending_updates.length == 0) {
      setState(() {
        curr_value = widget.value;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, curr_value, execute);
  }
}
