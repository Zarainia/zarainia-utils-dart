import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:zarainia_utils/src/constants.dart';
import 'package:zarainia_utils/src/shortcuts.dart';
import 'package:zarainia_utils/src/theme.dart';
import 'dialog.dart';

typedef StagedEditorBuilder<T> = Widget Function(
    {required bool editing,
    required Function() start_editing,
    required T value,
    required Function(T) update_value,
    required Function(List<String>) update_errors,
    VoidCallback? save,
    required VoidCallback cancel,
    required List<String> errors});

class MultiErrorManager extends StatefulWidget {
  Set<String> widget_ids;
  Widget Function(Function(String, String?) update_error) builder;
  Function(List<String>) update_errors;

  MultiErrorManager({required this.widget_ids, required this.builder, required this.update_errors});

  @override
  _MultiErrorManagerState createState() => _MultiErrorManagerState();
}

class _MultiErrorManagerState extends State<MultiErrorManager> {
  Map<String, String?> errors = {};

  void notify_update() {
    widget.update_errors(errors.values.whereNotNull().toSet().sortedBy((e) => e).toList());
  }

  @override
  void didUpdateWidget(covariant MultiErrorManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.widget_ids, oldWidget.widget_ids)) {
      Set<String> removed_ids = oldWidget.widget_ids.difference(widget.widget_ids);
      setState(() {
        for (String id in removed_ids) errors.remove(id);
      });
      notify_update();
    }
  }

  void update_error(String id, String? error) {
    setState(() {
      errors[id] = error;
    });
    notify_update();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(update_error);
  }
}

class StagedEditor<T> extends StatefulWidget {
  T initial_value;
  StagedEditorBuilder<T> editor_builder;
  Function(T) on_confirm;
  Function(T)? on_cancel;
  bool initially_editing;
  bool always_editing;

  StagedEditor({
    required this.initial_value,
    required this.editor_builder,
    required this.on_confirm,
    this.on_cancel,
    this.initially_editing = false,
    this.always_editing = false,
  });

  @override
  _StagedEditorState<T> createState() => _StagedEditorState();
}

class _StagedEditorState<T> extends State<StagedEditor<T>> {
  List<String> errors = [];
  late T value;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    value = widget.initial_value;
    editing = widget.always_editing || widget.initially_editing;
  }

  @override
  void didUpdateWidget(covariant StagedEditor<T> oldWidget) {
    if (oldWidget.initial_value != widget.initial_value && widget.initial_value != value) {
      reset_value();
    }
    super.didUpdateWidget(oldWidget);
  }

  void update_value(new_value) {
    setState(() {
      value = new_value;
    });
  }

  void reset_value() {
    update_value(widget.initial_value);
  }

  void update_errors(List<String> e) {
    setState(() {
      errors = e;
    });
  }

  void stop_editing() {
    if (!widget.always_editing)
      setState(() {
        editing = false;
      });
  }

  void cancel() {
    widget.on_cancel?.call(value);
    reset_value();
    stop_editing();
  }

  void confirm() {
    widget.on_confirm(value);
    stop_editing();
  }

  @override
  Widget build(BuildContext context) {
    return widget.editor_builder(
      editing: editing,
      start_editing: () {
        setState(() {
          editing = true;
        });
      },
      value: value,
      update_value: update_value,
      update_errors: update_errors,
      save: errors.isEmpty ? confirm : null,
      cancel: cancel,
      errors: errors,
    );
  }
}

class EditDialog<T> extends StatelessWidget {
  String title;
  T initial_value;
  Widget Function(T value, Function(T) update_value, Function(List<String>) update_errors) editor_builder;
  String confirm_button_text;
  String cancel_button_text;
  Function(T) on_confirm;
  Function(T)? on_cancel;
  BoxConstraints constraints;
  bool show_error_text;
  bool shortcuts;

  EditDialog({
    required this.title,
    required this.initial_value,
    required this.editor_builder,
    this.confirm_button_text = "Confirm",
    this.cancel_button_text = "Cancel",
    required this.on_confirm,
    this.on_cancel,
    this.constraints = const BoxConstraints(minWidth: 500, maxWidth: EDIT_DIALOG_MAX_WIDTH),
    this.show_error_text = true,
    this.shortcuts = false,
  });

  void cancel(BuildContext context, T value) {
    Navigator.of(context).pop();
    on_cancel?.call(value);
  }

  void confirm(BuildContext context, T value) {
    on_confirm(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return StagedEditor(
      always_editing: true,
      initial_value: initial_value,
      on_confirm: (value) => confirm(context, value),
      on_cancel: (value) => cancel(context, value),
      editor_builder: ({
        required bool editing,
        required Function() start_editing,
        required T value,
        required Function(T) update_value,
        required Function(List<String>) update_errors,
        VoidCallback? save,
        required VoidCallback cancel,
        required List<String> errors,
      }) {
        Widget editor = editor_builder(value, update_value, update_errors);

        return BaseMessageDialog(
          shortcuts: shortcuts ? ConfirmationDialog.DIALOG_SHORTCUTS : const {},
          actions: {
            ConfirmIntent: CallbackAction(onInvoke: (_) => save?.call()),
            CancelIntent: CallbackAction(onInvoke: (_) => cancel()),
          },
          message: title,
          content_widget: show_error_text
              ? Column(
                  children: [
                    ...errors.map((e) => Text("Error: ${e}", style: TextStyle(color: theme_colours.ERROR_TEXT_COLOUR))),
                    const SizedBox(height: 10),
                    editor,
                  ],
                  mainAxisSize: MainAxisSize.min,
                )
              : editor,
          buttons: [
            DialogButton(
              onclick: cancel,
              text: cancel_button_text,
            ),
            DialogButton(
              onclick: save,
              text: confirm_button_text,
            ),
          ],
          constraints: constraints,
        );
      },
    );
  }
}
