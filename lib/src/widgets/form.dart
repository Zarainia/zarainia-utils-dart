import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:intersperse/intersperse.dart';

import 'package:zarainia_utils/src/constants.dart';
import 'package:zarainia_utils/src/exports.dart';

typedef StagedEditorBuilder<T, R> = Widget Function(
    {required bool editing,
    required Function() start_editing,
    required T value,
    required Function(T) update_value,
    required Function(List<String>) update_errors,
    R Function()? save,
    required VoidCallback cancel,
    required List<String> errors});

typedef StagedEditorLayoutBuilder<T, K> = Widget Function({
  required T initial_value,
  required Widget Function(BuildContext, T, Function(T), Function(List<String>)) editor_builder,
  Widget Function(BuildContext, T)? display_builder,
  TextStyle? display_style,
  required Function(T) on_confirm,
  Function(T)? on_cancel,
  String? Function(T)? validator,
  bool initially_editing,
  bool keep_alive,
  K? restore_state_identifier,
  bool disable_saving_unchanged_value,
  bool show_error_text,
  bool error_text_on_bottom,
  Color? icon_colour,
  Color? confirm_colour,
  Color? cancel_colour,
  List<Widget> additional_display_actions,
});

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

class StagedEditor<T, K, R> extends StatefulWidget {
  T initial_value;
  List<String> initial_errors;
  StagedEditorBuilder<T, R> editor_builder;
  R Function(T) on_confirm;
  Function(T)? on_cancel;
  bool initially_editing;
  bool always_editing;
  bool keep_alive;
  K? restore_state_identifier;
  bool disable_saving_unchanged_value;
  List<String> Function(T)? validator;

  StagedEditor({
    Key? key,
    required this.initial_value,
    this.initial_errors = const [],
    required this.editor_builder,
    required this.on_confirm,
    this.on_cancel,
    this.initially_editing = false,
    this.always_editing = false,
    this.keep_alive = false,
    this.restore_state_identifier,
    this.disable_saving_unchanged_value = false,
    this.validator,
  }) : super(key: key ?? (restore_state_identifier != null ? PageStorageKey(restore_state_identifier) : null));

  @override
  _StagedEditorState<T, K, R> createState() => _StagedEditorState();
}

class _StagedEditorState<T, K, R> extends State<StagedEditor<T, K, R>> with AutomaticKeepAliveClientMixin {
  bool initialized = false;
  List<String> errors = const [];
  late T value;
  bool editing = false;

  @override
  bool get wantKeepAlive => initialized && widget.keep_alive && value != widget.initial_value;

  @override
  void initState() {
    super.initState();
    value = widget.initial_value;
    if (widget.restore_state_identifier != null) value = PageStorage.of(context).readState(context, identifier: widget.restore_state_identifier) ?? value;
    if (widget.initial_errors.isNotEmpty)
      errors = widget.initial_errors;
    else if (widget.validator != null) errors = widget.validator!(value);
    editing = widget.always_editing || widget.initially_editing;
    initialized = true;
  }

  @override
  void didUpdateWidget(covariant StagedEditor<T, K, R> oldWidget) {
    if (oldWidget.initial_value != widget.initial_value && widget.initial_value != value) reset_value();
    if (oldWidget.validator != widget.validator) {
      if (widget.validator == null)
        update_errors(const []);
      else
        update_errors(widget.validator!(value));
    }
    super.didUpdateWidget(oldWidget);
  }

  void save_value(T? val) {
    if (widget.restore_state_identifier != null) PageStorage.of(context).writeState(context, val, identifier: widget.restore_state_identifier);
  }

  void save_curr_value() => save_value(value);

  void clear_saved_value() => save_value(null);

  void update_value(T new_value) {
    setState(() {
      value = new_value;
    });
    save_curr_value();
    if (widget.validator != null) update_errors(widget.validator!(new_value));
  }

  void reset_value() {
    update_value(widget.initial_value);
    clear_saved_value();
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
    clear_saved_value();
    widget.on_cancel?.call(value);
    reset_value();
    stop_editing();
  }

  R confirm() {
    clear_saved_value();
    R result = widget.on_confirm(value);
    stop_editing();
    return result;
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
      save: errors.isEmpty && (!widget.disable_saving_unchanged_value || value != widget.initial_value) ? confirm : null,
      cancel: cancel,
      errors: errors,
    );
  }
}

class StagedEditorErrorDisplay extends StatelessWidget {
  final List<String> errors;

  const StagedEditorErrorDisplay({required this.errors});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Column(
      children: errors
          .map(
            (e) => Text("Error: ${e}", style: TextStyle(color: theme_colours.ERROR_TEXT_COLOUR)),
          )
          .toList(),
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class EditDialog<T> extends StatelessWidget {
  String? title;
  Widget? title_widget;
  Widget Function(T value)? title_builder;
  T initial_value;
  List<String> initial_errors;
  Widget Function(T value, Function(T) update_value, Function(List<String>) update_errors) editor_builder;
  String confirm_button_text;
  String cancel_button_text;
  Function(T) on_confirm;
  Function(T)? on_cancel;
  BoxConstraints constraints;
  bool show_error_text;
  bool shortcuts;
  List<String> Function(T)? validator;

  EditDialog({
    this.title,
    this.title_widget,
    this.title_builder,
    required this.initial_value,
    this.initial_errors = const [],
    required this.editor_builder,
    this.confirm_button_text = "Confirm",
    this.cancel_button_text = "Cancel",
    required this.on_confirm,
    this.on_cancel,
    this.constraints = const BoxConstraints(minWidth: 500, maxWidth: EDIT_DIALOG_MAX_WIDTH),
    this.show_error_text = true,
    this.shortcuts = false,
    this.validator,
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
    return StagedEditor(
      always_editing: true,
      initial_value: initial_value,
      initial_errors: initial_errors,
      on_confirm: (value) => confirm(context, value),
      on_cancel: (value) => cancel(context, value),
      validator: validator,
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
          message_widget: title_builder?.call(value) ?? title_widget,
          content_widget: show_error_text
              ? Column(
                  children: [
                    if (errors.isNotEmpty)
                      Padding(
                        child: StagedEditorErrorDisplay(errors: errors),
                        padding: const EdgeInsets.only(bottom: 10),
                      ),
                    Flexible(child: editor),
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

class _InlineEditorIcon extends StatelessWidget {
  final IconData icon;
  final Color? colour;
  final VoidCallback? on_click;
  final String? tooltip;

  _InlineEditorIcon({required this.icon, this.colour, this.on_click, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 18,
      color: colour,
      onPressed: on_click,
      tooltip: tooltip,
    );
  }
}

class InlineStagedEditor<T, K> extends StatelessWidget {
  final T initial_value;
  final Widget Function(BuildContext context, T value, Function(T) on_change, Function(List<String>) update_errors) editor_builder;
  final Widget Function(BuildContext context, T value)? display_builder;
  final TextStyle? display_style;
  final Function(T) on_confirm;
  final Function(T)? on_cancel;
  final bool initially_editing;
  final bool keep_alive;
  final K? restore_state_identifier;
  final bool disable_saving_unchanged_value;
  final String? Function(T)? validator;
  final bool show_error_text;
  final bool error_text_on_bottom;
  final Color? icon_colour;
  final Color? confirm_colour;
  final Color? cancel_colour;
  final List<Widget> additional_display_actions;

  const InlineStagedEditor({
    required this.initial_value,
    required this.editor_builder,
    this.display_builder,
    this.display_style,
    required this.on_confirm,
    this.on_cancel,
    this.validator,
    this.initially_editing = false,
    this.keep_alive = false,
    this.restore_state_identifier,
    this.disable_saving_unchanged_value = false,
    this.show_error_text = false,
    this.error_text_on_bottom = false,
    this.icon_colour,
    this.confirm_colour,
    this.cancel_colour,
    this.additional_display_actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return StagedEditor(
      initial_value: initial_value,
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
        Widget editor = Row(
          children: [
            Flexible(
              child: editing ? editor_builder(context, value, update_value, update_errors) : display_builder?.call(context, value) ?? Text(value.toString(), style: display_style),
            ),
            if (!editing)
              _InlineEditorIcon(
                icon: Icons.edit,
                colour: icon_colour,
                on_click: start_editing,
                tooltip: "Edit",
              ),
            if (!editing) ...additional_display_actions,
            if (editing)
              _InlineEditorIcon(
                icon: Icons.close,
                colour: cancel_colour ?? icon_colour,
                on_click: cancel,
                tooltip: "Cancel",
              ),
            if (editing)
              _InlineEditorIcon(
                icon: Icons.check,
                colour: confirm_colour ?? icon_colour,
                on_click: save,
                tooltip: "Save",
              ),
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
        );

        return show_error_text && editing
            ? Column(
                children: error_text_on_bottom
                    ? [
                        Flexible(child: editor),
                        if (errors.isNotEmpty)
                          Padding(
                            child: StagedEditorErrorDisplay(errors: errors),
                            padding: const EdgeInsets.only(top: 10),
                          ),
                      ]
                    : [
                        if (errors.isNotEmpty)
                          Padding(
                            child: StagedEditorErrorDisplay(errors: errors),
                            padding: const EdgeInsets.only(bottom: 10),
                          ),
                        Flexible(child: editor),
                      ],
                mainAxisSize: MainAxisSize.min,
              )
            : editor;
      },
      on_confirm: on_confirm,
      on_cancel: on_cancel,
      initially_editing: initially_editing,
      keep_alive: keep_alive,
      restore_state_identifier: restore_state_identifier,
      disable_saving_unchanged_value: disable_saving_unchanged_value,
      validator: validator == null ? null : (T value) => null_to_empty_list(validator!(value)),
    );
  }
}

class _ListTileEditorIcon extends StatelessWidget {
  final IconData icon;
  final Color? colour;
  final VoidCallback? on_click;
  final String? tooltip;

  _ListTileEditorIcon({required this.icon, this.colour, this.on_click, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: colour,
      onPressed: on_click,
      tooltip: tooltip,
    );
  }
}

class ListTileStagedEditor<T, K> extends StatelessWidget {
  final T initial_value;
  final Widget Function(BuildContext context, T value, Function(T) on_change, Function(List<String>) update_errors) editor_builder;
  final Widget Function(BuildContext context, T value)? display_builder;
  final TextStyle? display_style;
  final Function(T) on_confirm;
  final Function(T)? on_cancel;
  final bool initially_editing;
  final bool keep_alive;
  final K? restore_state_identifier;
  final bool disable_saving_unchanged_value;
  final String? Function(T)? validator;
  final bool show_error_text;
  final bool error_text_on_bottom;
  final Color? icon_colour;
  final Color? confirm_colour;
  final Color? cancel_colour;
  final List<Widget> additional_display_actions;
  final Widget? leading;

  const ListTileStagedEditor({
    required this.initial_value,
    required this.editor_builder,
    this.display_builder,
    this.display_style,
    required this.on_confirm,
    this.on_cancel,
    this.validator,
    this.initially_editing = false,
    this.keep_alive = false,
    this.restore_state_identifier,
    this.disable_saving_unchanged_value = false,
    this.show_error_text = false,
    this.error_text_on_bottom = true,
    this.icon_colour,
    this.confirm_colour,
    this.cancel_colour,
    this.additional_display_actions = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return StagedEditor(
      initial_value: initial_value,
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
        Widget editor = editing ? editor_builder(context, value, update_value, update_errors) : display_builder?.call(context, value) ?? Text(value.toString(), style: display_style);

        return ListTile(
          leading: leading,
          title: show_error_text && editing
              ? Column(
                  children: error_text_on_bottom
                      ? [
                          Flexible(child: editor),
                          if (errors.isNotEmpty)
                            Padding(
                              child: StagedEditorErrorDisplay(errors: errors),
                              padding: const EdgeInsets.only(top: 10),
                            ),
                        ]
                      : [
                          if (errors.isNotEmpty)
                            Padding(
                              child: StagedEditorErrorDisplay(errors: errors),
                              padding: const EdgeInsets.only(bottom: 10),
                            ),
                          Flexible(child: editor),
                        ],
                  mainAxisSize: MainAxisSize.min,
                )
              : editor,
          trailing: Row(
            children: [
              if (!editing)
                _ListTileEditorIcon(
                  icon: Icons.edit,
                  colour: icon_colour,
                  on_click: start_editing,
                  tooltip: "Edit",
                ),
              if (!editing) ...additional_display_actions,
              if (editing)
                _ListTileEditorIcon(
                  icon: Icons.close,
                  colour: cancel_colour ?? icon_colour,
                  on_click: cancel,
                  tooltip: "Cancel",
                ),
              if (editing)
                _ListTileEditorIcon(
                  icon: Icons.check,
                  colour: confirm_colour ?? icon_colour,
                  on_click: save,
                  tooltip: "Save",
                ),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        );
      },
      on_confirm: on_confirm,
      on_cancel: on_cancel,
      initially_editing: initially_editing,
      keep_alive: keep_alive,
      restore_state_identifier: restore_state_identifier,
      disable_saving_unchanged_value: disable_saving_unchanged_value,
      validator: validator == null ? null : (T value) => null_to_empty_list(validator!(value)),
    );
  }

  static StagedEditorLayoutBuilder<T, K> with_custom_args<T, K>({
    Widget? leading,
  }) {
    return ({
      required T initial_value,
      required Widget Function(BuildContext, T, Function(T), Function(List<String>)) editor_builder,
      Widget Function(BuildContext, T)? display_builder,
      TextStyle? display_style,
      required Function(T) on_confirm,
      Function(T)? on_cancel,
      String? Function(T)? validator,
      bool initially_editing = false,
      bool keep_alive = false,
      K? restore_state_identifier,
      bool disable_saving_unchanged_value = false,
      bool show_error_text = false,
      bool error_text_on_bottom = true,
      Color? icon_colour,
      Color? confirm_colour,
      Color? cancel_colour,
      List<Widget> additional_display_actions = const [],
    }) =>
        ListTileStagedEditor(
          initial_value: initial_value,
          editor_builder: editor_builder,
          display_builder: display_builder,
          display_style: display_style,
          on_confirm: on_confirm,
          on_cancel: on_cancel,
          validator: validator,
          initially_editing: initially_editing,
          restore_state_identifier: restore_state_identifier,
          disable_saving_unchanged_value: disable_saving_unchanged_value,
          show_error_text: show_error_text,
          error_text_on_bottom: error_text_on_bottom,
          icon_colour: icon_colour,
          confirm_colour: confirm_colour,
          cancel_colour: cancel_colour,
          additional_display_actions: additional_display_actions,
          leading: leading,
        );
  }
}

class _StackedEditorIcon extends StatelessWidget {
  final IconData icon;
  final Color? colour;
  final VoidCallback? on_click;
  final String? tooltip;

  _StackedEditorIcon({required this.icon, this.colour, this.on_click, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: colour,
      onPressed: on_click,
      tooltip: tooltip,
    );
  }
}

class StackedStagedEditor<T, K> extends StatelessWidget {
  final T initial_value;
  final Widget Function(BuildContext context, T value, Function(T) on_change, Function(List<String>) update_errors) editor_builder;
  final Widget Function(BuildContext context, T value)? display_builder;
  final TextStyle? display_style;
  final Function(T) on_confirm;
  final Function(T)? on_cancel;
  final bool initially_editing;
  final bool keep_alive;
  final K? restore_state_identifier;
  final bool disable_saving_unchanged_value;
  final String? Function(T)? validator;
  final bool show_error_text;
  final bool error_text_on_bottom;
  final Color? icon_colour;
  final Color? confirm_colour;
  final Color? cancel_colour;
  final double min_width;
  final List<Widget> additional_display_actions;

  const StackedStagedEditor({
    required this.initial_value,
    required this.editor_builder,
    this.display_builder,
    this.display_style,
    required this.on_confirm,
    this.on_cancel,
    this.validator,
    this.initially_editing = false,
    this.keep_alive = false,
    this.restore_state_identifier,
    this.disable_saving_unchanged_value = false,
    this.show_error_text = false,
    this.error_text_on_bottom = false,
    this.icon_colour,
    this.confirm_colour,
    this.cancel_colour,
    this.min_width = 300,
    this.additional_display_actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return StagedEditor(
      initial_value: initial_value,
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
        Widget editor = Column(
          children: [
            ConstrainedBox(
              child: editing
                  ? editor_builder(context, value, update_value, update_errors)
                  : Tooltip(
                      child: InkWell(
                        child: display_builder?.call(context, value) ??
                            Padding(
                              child: Text(value.toString(), style: display_style),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                        onTap: start_editing,
                      ),
                      message: "Edit",
                    ),
              constraints: BoxConstraints(minWidth: min_width),
            ),
            if (editing)
              Row(
                children: [
                  _StackedEditorIcon(
                    icon: Icons.close,
                    colour: cancel_colour ?? icon_colour,
                    on_click: cancel,
                    tooltip: "Cancel",
                  ),
                  _StackedEditorIcon(
                    icon: Icons.check,
                    colour: confirm_colour ?? icon_colour,
                    on_click: save,
                    tooltip: "Save",
                  ),
                ],
              )
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        );

        return show_error_text && editing
            ? Column(
                children: error_text_on_bottom
                    ? [
                        editor,
                        if (errors.isNotEmpty)
                          Padding(
                            child: StagedEditorErrorDisplay(errors: errors),
                            padding: const EdgeInsets.only(top: 10),
                          ),
                      ]
                    : [
                        if (errors.isNotEmpty)
                          Padding(
                            child: StagedEditorErrorDisplay(errors: errors),
                            padding: const EdgeInsets.only(bottom: 10),
                          ),
                        editor,
                      ],
                mainAxisSize: MainAxisSize.min,
              )
            : editor;
      },
      on_confirm: on_confirm,
      on_cancel: on_cancel,
      initially_editing: initially_editing,
      keep_alive: keep_alive,
      restore_state_identifier: restore_state_identifier,
      disable_saving_unchanged_value: disable_saving_unchanged_value,
      validator: validator == null ? null : (T value) => null_to_empty_list(validator!(value)),
    );
  }
}

class StagedTextEditor<T> extends StatelessWidget {
  final T initial_text;
  final InputDecoration decoration;
  final TextStyle? style;
  final TextStyle? display_style;
  final Widget Function(BuildContext context, T value)? display_builder;
  final TextAlign text_align;
  final InputValidationFunction? validator;
  final bool show_error;
  final List<TextInputFormatter> input_formatters;
  final String Function(T) input_convertor;
  final T Function(String)? output_convertor;
  final bool multiline;
  final StagedEditorLayoutBuilder<T, dynamic>? layout_builder;
  final TextInputType? input_type;
  final bool expanded;
  final bool clearable;
  final Color? icon_colour;
  final double cursor_width;
  final Function(T) on_confirm;
  final Function(T)? on_cancel;
  final bool initially_editing;
  final List<Widget> additional_display_actions;

  const StagedTextEditor({
    required this.initial_text,
    this.decoration = const InputDecoration(),
    this.style,
    this.display_style,
    this.display_builder,
    this.text_align = TextAlign.start,
    this.validator,
    this.show_error = true,
    this.input_formatters = const [],
    this.input_convertor = StatedTextField.default_input_convertor,
    this.output_convertor,
    this.multiline = false,
    this.layout_builder,
    this.input_type,
    this.expanded = false,
    this.clearable = false,
    this.icon_colour,
    this.cursor_width = 2.0,
    required this.on_confirm,
    this.on_cancel,
    this.initially_editing = false,
    this.additional_display_actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    StagedEditorLayoutBuilder<T, dynamic> builder = layout_builder ?? (multiline ? StackedStagedEditor.new : InlineStagedEditor.new);

    return builder(
      initial_value: initial_text,
      editor_builder: (context, value, on_change, update_errors) => StatedTextField(
        initial_text: initial_text,
        on_changed: on_change,
        decoration: decoration.copyWith(errorStyle: HIDDEN_ERROR_STYLE),
        style: style,
        text_align: text_align,
        validator: validator,
        always_update: true,
        input_formatters: input_formatters,
        input_convertor: input_convertor,
        output_convertor: output_convertor,
        multiline: multiline,
        input_type: input_type,
        expanded: expanded,
        clearable: clearable,
        icon_colour: icon_colour,
        cursor_width: cursor_width,
        on_error: (error) => update_errors(null_to_empty_list(error)),
      ),
      display_builder: display_builder ??
          (context, text) => Padding(
                child: (text == null || (text is String && text.isEmpty))
                    ? Text(
                        "empty",
                        style: (display_style ?? style ?? const TextStyle()).copyWith(color: theme_colours.DIM_TEXT_COLOUR, fontStyle: FontStyle.italic),
                      )
                    : Text(text.toString(), style: display_style ?? style),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
      icon_colour: icon_colour,
      on_confirm: on_confirm,
      on_cancel: on_cancel,
      initially_editing: initially_editing,
      show_error_text: show_error,
      error_text_on_bottom: true,
      additional_display_actions: additional_display_actions,
    );
  }
}

class EditSection extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Widget? title_trailing;
  final List<Widget> editors;
  final bool smaller;

  const EditSection({this.icon, required this.title, this.title_trailing, required this.editors, this.smaller = false});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Column(
      children: [
        Row(
          children: [
            IconAndText(icon: icon, text: title, style: smaller ? theme_colours.SMALLER_HEADER_STYLE : theme_colours.SMALL_HEADER_STYLE),
            if (title_trailing != null) title_trailing!,
          ],
          mainAxisSize: MainAxisSize.min,
        ),
        const SizedBox(height: 10),
        ...intersperse(const SizedBox(height: 10), editors),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class Staged extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback hide_new_entry) editor_builder;
  final Widget Function(BuildContext context, VoidCallback show_new_entry) display_builder;

  const Staged({required this.editor_builder, required this.display_builder});

  @override
  _StagedState createState() => _StagedState();
}

class _StagedState extends State<Staged> {
  bool new_entry_showing = false;

  @override
  Widget build(BuildContext context) {
    if (new_entry_showing)
      return widget.editor_builder(context, () {
        setState(() {
          new_entry_showing = false;
        });
      });
    else
      return widget.display_builder(
        context,
        () {
          setState(() {
            new_entry_showing = true;
          });
        },
      );
  }
}

class ListEndEditor extends StatelessWidget {
  final Widget Function(BuildContext context, VoidCallback hide_new_entry) builder;
  final String tooltip;

  const ListEndEditor({super.key = const Key("new_value"), required this.builder, this.tooltip = "Add"});

  @override
  Widget build(BuildContext context) {
    return Staged(
      editor_builder: builder,
      display_builder: (context, start_editing) => ListEndAddButton(
        on_click: start_editing,
        tooltip: tooltip,
      ),
    );
  }
}
