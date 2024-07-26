import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synchronized/synchronized.dart';
import 'package:zarainia_utils/src/exports.dart';

const FutureOr<FutureOr<void> Function()?> _IGNORED_CALLBACK_VALUE = const IgnoredFuture<FutureOr<void> Function()?>();

abstract class BaseUndoAction<T, U, E> {
  final String? name;
  final FutureOr<void> Function()? callback;

  BaseUndoAction({this.name, this.callback});

  T? value;
  int progress = 0;

  FutureOr<T> do_(E info, [T? arg]);

  FutureOr<U> undo_(E info, T arg);

  Future<T> redo(E info) async {
    assert(progress == 0);
    T result = await do_(info, value);
    if (value == null) value = result;
    progress++;
    await this.callback?.call();
    return result;
  }

  Future<U> undo(E info) async {
    assert(progress == 1);
    U result = await undo_(info, value as T);
    progress--;
    await this.callback?.call();
    return result;
  }

  BaseUndoAction<T, U, E> chain(BaseUndoAction<void, void, E> next);

  BaseUndoAction<T, U, E> copy_with({String? name, FutureOr<void> Function()? callback});
}

class UndoAction<T, U, E> extends BaseUndoAction<T, U, E> {
  final FutureOr<T> Function(E info, [T? arg]) do_func;
  final FutureOr<U> Function(E info, T arg) undo_func;

  UndoAction({super.name, required this.do_func, required this.undo_func, super.callback});

  static UndoAction<T?, U?, E> typeless<T, U, E>({String? name, required FutureOr Function(E info) do_func, required FutureOr Function(E info) undo_func, VoidCallback? callback}) {
    return UndoAction<T?, U?, E>(
      name: name,
      do_func: ((info, [_]) {
        do_func(info);
      }),
      undo_func: ((info, _) {
        undo_func(info);
      }),
      callback: callback,
    );
  }

  @override
  FutureOr<T> do_(E info, [T? arg]) => do_func(info, arg);

  @override
  FutureOr<U> undo_(E info, T arg) => undo_func(info, arg);

  @override
  CombinationUndoAction<T, U, E> chain(BaseUndoAction next) {
    if (next is CombinationUndoAction) {
      return CombinationUndoAction([this, ...next._actions]);
    } else {
      return CombinationUndoAction([this, next]);
    }
  }

  @override
  UndoAction<T, U, E> copy_with({
    String? name = IGNORED_STRING_VALUE,
    FutureOr<FutureOr<void> Function()?> callback = _IGNORED_CALLBACK_VALUE,
    FutureOr<T> Function(E info, [T? arg])? do_func,
    FutureOr<U> Function(E info, T arg)? undo_func,
  }) {
    return UndoAction(
      name: ignore_string_parameter(name, this.name),
      callback: ignore_generic_parameter(callback, this.callback),
      do_func: do_func ?? this.do_func,
      undo_func: undo_func ?? this.undo_func,
    );
  }
}

class CombinationUndoAction<T, U, E> extends BaseUndoAction<T, U, E> {
  final List<BaseUndoAction> _actions;

  CombinationUndoAction(List<BaseUndoAction>? actions, {super.callback, super.name}) : _actions = actions ?? [];

  void append(BaseUndoAction action) {
    assert(progress == 0);
    _actions.add(action);
  }

  void prepend(BaseUndoAction action) {
    assert(progress == 0);
    _actions.insert(0, action);
  }

  void appendAll(Iterable<BaseUndoAction> actions) {
    assert(progress == 0);
    _actions.addAll(actions);
  }

  void prependAll(Iterable<BaseUndoAction> actions) {
    assert(progress == 0);
    _actions.insertAll(0, actions);
  }

  static Set<FutureOr<void> Function()> _get_action_callbacks(BaseUndoAction action) {
    if (action is CombinationUndoAction) {
      Set<FutureOr<void> Function()> callbacks = action._actions.expand((a) => _get_action_callbacks(a)).toSet();
      if (action.callback != null) callbacks.add(action.callback!);
      return callbacks;
    } else {
      return null_to_empty_set(action.callback);
    }
  }

  Set<FutureOr<void> Function()> get unique_callbacks => _actions.expand((action) => _get_action_callbacks(action)).toSet();

  Future do_unique_callbacks() async {
    for (FutureOr<void> Function() callback in unique_callbacks) await callback();
  }

  @override
  FutureOr<T> do_(E info, [T? arg]) async {
    T? result;
    for (BaseUndoAction action in _actions) {
      Object action_result = await (action.copy_with(callback: null)
            ..progress = progress
            ..value = value)
          .redo(info);
      if (action_result is T) result = action_result as T;
    }
    await do_unique_callbacks();
    return result as T;
  }

  @override
  FutureOr<U> undo_(E info, T? arg) async {
    U? result;
    for (BaseUndoAction action in _actions.reversed) {
      Object action_result = await (action.copy_with(callback: null)
            ..progress = progress
            ..value = value)
          .undo(info);
      if (action_result is U) result = action_result as U;
    }
    await do_unique_callbacks();
    return result as U;
  }

  @override
  CombinationUndoAction<T, U, E> chain(BaseUndoAction next) {
    if (next is CombinationUndoAction)
      return copy_with(actions: [..._actions, ...next._actions]);
    else
      return copy_with(actions: [..._actions, next]);
  }

  CombinationUndoAction<T, U, E> copy_with({
    String? name = IGNORED_STRING_VALUE,
    FutureOr<FutureOr<void> Function()?> callback = _IGNORED_CALLBACK_VALUE,
    List<BaseUndoAction>? actions,
  }) =>
      CombinationUndoAction<T, U, E>(
        actions ?? _actions,
        name: ignore_string_parameter(name, this.name),
        callback: ignore_generic_parameter(callback, this.callback),
      );
}

class UndoState<E> {
  final List<BaseUndoAction<dynamic, dynamic, E>> actions;
  final int position;

  const UndoState({List<BaseUndoAction<dynamic, dynamic, E>>? actions, this.position = 0}) : actions = actions ?? const [];

  UndoState<E> with_added_action(BaseUndoAction<dynamic, dynamic, E> action) {
    return UndoState(actions: actions.sublist(0, position) + [action], position: position + 1);
  }

  UndoState<E> with_position_change(int change) {
    int new_position = position + change;
    assert(new_position <= actions.length && new_position >= 0);
    return UndoState(actions: actions, position: new_position);
  }

  bool get can_redo => position < actions.length;

  bool get can_undo => actions.isNotEmpty && position > 0;

  bool get has_changes => can_undo;

  BaseUndoAction<dynamic, dynamic, E> get next_action => actions[position];

  BaseUndoAction<dynamic, dynamic, E> get prev_action => actions[position - 1];
}

class SimpleUndoCubit extends Cubit<UndoState<void>> {
  final Lock lock = Lock();

  SimpleUndoCubit() : super(const UndoState());

  Future<T> add_action<T>(BaseUndoAction<T, dynamic, void> action) async {
    return await lock.synchronized(() async {
      T result = await action.redo(null);
      emit(state.with_added_action(action));
      log("do ${action.name}");
      return result;
    });
  }

  Future<dynamic> undo() async {
    if (!state.can_undo) return;

    return await lock.synchronized(() async {
      BaseUndoAction<dynamic, dynamic, void> action = state.prev_action;
      dynamic result = await action.undo(null);
      emit(state.with_position_change(-1));
      log("undo ${action.name}");
      return result;
    });
  }

  Future<dynamic> redo() async {
    if (!state.can_redo) return;

    return await lock.synchronized(() async {
      BaseUndoAction<dynamic, dynamic, void> action = state.next_action;
      dynamic result = await action.redo(null);
      emit(state.with_position_change(1));
      log("redo ${action.name}");
      return result;
    });
  }

  void reset() {
    emit(const UndoState());
  }
}
