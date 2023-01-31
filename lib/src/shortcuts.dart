import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'utils.dart';

class SaveEditIntent extends DownPropagationIntent {
  const SaveEditIntent();
}

class CancelEditIntent extends DownPropagationIntent {
  const CancelEditIntent();
}

class SavePageIntent extends DownPropagationIntent {
  const SavePageIntent();
}

class DropPageIntent extends DownPropagationIntent {
  const DropPageIntent();
}

class ExpandIntent extends DownPropagationIntent {
  const ExpandIntent();
}

class CollapseIntent extends DownPropagationIntent {
  const CollapseIntent();
}

class ExpandAllIntent extends DownPropagationIntent {
  const ExpandAllIntent();
}

class CollapseAllIntent extends DownPropagationIntent {
  const CollapseAllIntent();
}

class ConfirmIntent extends DownPropagationIntent {
  const ConfirmIntent();
}

class CancelIntent extends DownPropagationIntent {
  const CancelIntent();
}

class UndoIntent extends DownPropagationIntent {
  const UndoIntent();
}

class RedoIntent extends DownPropagationIntent {
  const RedoIntent();
}

class SaveFileIntent extends DownPropagationIntent {
  const SaveFileIntent();
}

class DownPropagationCubit extends Cubit<Set<Type>> {
  BuildContext context;
  Set<Type> shortcut_intents;
  Set<Type> combined_intents = {};
  DownPropagationCubit? parent_cubit;
  Set<DownPropagationCubit> child_cubits = {};
  bool always_invoke_up;
  StreamSubscription? parent_stream_subscription;

  DownPropagationCubit(this.context, Map<ShortcutActivator, Intent> shortcuts, Map<Type, Action<Intent>> actions, {this.always_invoke_up = true})
      : shortcut_intents = shortcuts.values.map((intent) => intent.runtimeType).toSet(),
        super({}) {
    combined_intents = actions.keys.toSet().union(shortcut_intents);
    try {
      parent_cubit = BlocProvider.of<DownPropagationCubit>(context, listen: false);
      parent_cubit!.child_cubits.add(this);
      emit_combined(parent_cubit!.state);
      parent_stream_subscription = parent_cubit!.stream.asBroadcastStream().listen((event) {
        emit_combined(event);
      });
    } catch (e) {
      emit_combined(combined_intents);
    }
  }

  void emit_combined([Set<Type> inherited_intents = const {}]) {
    emit(inherited_intents.union(combined_intents));
  }

  bool invoke_action(Intent intent) {
    Object? result = Actions.maybeInvoke(context, intent);
    return result is bool && result;
  }

  bool propagate_down(Intent intent) {
    bool invoked = false;
    for (DownPropagationCubit child in child_cubits) invoked |= child.receive_intent(intent);
    return invoked;
  }

  bool receive_intent(Intent intent) {
    bool invoked = propagate_down(intent);
    if ((always_invoke_up || !invoked) && combined_intents.contains(intent.runtimeType)) invoked |= invoke_action(intent);
    return invoked;
  }

  bool handle_shortcut(Intent intent) {
    if (!shortcut_intents.contains(intent.runtimeType)) {
      parent_cubit?.receive_intent(intent);
      return true;
    } else
      return receive_intent(intent);
  }

  @override
  Future<void> close() {
    parent_cubit?.child_cubits.remove(this);
    parent_stream_subscription?.cancel();
    return super.close();
  }
}

abstract class DownPropagationIntent extends Intent {
  const DownPropagationIntent();
}

class DownPropagationShortcuts extends StatelessWidget {
  static final ActionDispatcher dispatcher = DownPropagationActionDispatcher();

  Widget child;
  Map<Type, Action<Intent>> actions;
  Map<ShortcutActivator, Intent> shortcuts;
  bool autofocus;
  bool always_invoke_up;

  Map<Type, Action<Intent>> shortcuts_fill;

  DownPropagationShortcuts({required this.child, this.shortcuts = const {}, this.actions = const {}, this.autofocus = false, this.always_invoke_up = true})
      : shortcuts_fill = Map.fromIterable(shortcuts.values, key: (intent) => intent.runtimeType, value: (_) => CallbackAction(onInvoke: (_) {}));

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (autofocus) content = DefaultFocus(child: content);
    if (shortcuts.isNotEmpty)
      content = Shortcuts(
        shortcuts: shortcuts,
        child: content,
      );

    return Actions(
      actions: {...shortcuts_fill, ...actions},
      dispatcher: const ActionDispatcher(),
      child: BlocProvider<DownPropagationCubit>(
        create: (context) => DownPropagationCubit(context, shortcuts, actions, always_invoke_up: always_invoke_up),
        lazy: false,
        child: BlocBuilder<DownPropagationCubit, Set<Type>>(
          builder: (context, inherited_intents) {
            return Actions(
              actions: {...Map.fromIterable(inherited_intents, key: (intent) => intent.runtimeType, value: (_) => CallbackAction(onInvoke: (_) {}))},
              dispatcher: dispatcher,
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class DownPropagationActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    if (intent is! DownPropagationIntent) return super.invokeAction(action, intent, context);
    context ??= primaryFocus?.context;
    // context?.visitAncestorElements((element) {
    //   if (element.widget is DownPropagationShortcuts) {
    //     print(intent);
    //     print(element.describeOwnershipChain("shortcuts"));
    //     return false;
    //   }
    //   return true;
    // });
    return context!.read<DownPropagationCubit>().handle_shortcut(intent);
  }
}
