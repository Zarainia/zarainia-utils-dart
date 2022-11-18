import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:inflection2/inflection2.dart';

import '../constants.dart' as constants;
import '../shortcuts.dart';
import '../string.dart';
import '../theme.dart';
import '../tree.dart';
import 'search.dart';

class CompatibleDialog extends StatelessWidget {
  Widget? title;
  Widget? content;
  double max_width;
  double max_height;
  double min_width;
  double min_height;
  bool scrollable;
  bool compress_width;

  CompatibleDialog(
      {this.title, this.content, this.max_width = double.infinity, this.max_height = double.infinity, this.min_width = 0, this.min_height = 0, this.scrollable = true, this.compress_width = false});

  static double? lerpDouble(num? a, num? b, double t) {
    if (a == b || (a?.isNaN == true) && (b?.isNaN == true)) return a?.toDouble();
    a ??= 0.0;
    b ??= 0.0;
    assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(t.isFinite, 't must be finite when interpolating between values');
    return a * (1.0 - t) + b * t;
  }

  static double _paddingScaleFactor(double textScaleFactor) {
    final double clampedTextScaleFactor = textScaleFactor.clamp(1.0, 2.0).toDouble();
    // The final padding scale factor is clamped between 1/3 and 1. For example,
    // a non-scaled padding of 24 will produce a padding between 24 and 8.
    return lerpDouble(1.0, 1.0 / 3.0, clampedTextScaleFactor - 1.0)!;
  }

  Widget build(BuildContext context) {
    var titleWidget;
    var contentWidget;
    var theme = Theme.of(context);
    final DialogTheme dialogTheme = DialogTheme.of(context);
    final double paddingScaleFactor = _paddingScaleFactor(MediaQuery.of(context).textScaleFactor);
    final TextDirection? textDirection = Directionality.maybeOf(context);
    final EdgeInsetsGeometry? titlePadding = null;
    final TextStyle? titleTextStyle = null;
    final TextStyle? contentTextStyle = null;
    final EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);
    String? label = null;

    if (title != null) {
      final EdgeInsets defaultTitlePadding = EdgeInsets.fromLTRB(24.0, 24.0, 24.0, content == null ? 20.0 : 0.0);
      final EdgeInsets effectiveTitlePadding = titlePadding?.resolve(textDirection) ?? defaultTitlePadding;
      titleWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveTitlePadding.left * paddingScaleFactor,
          right: effectiveTitlePadding.right * paddingScaleFactor,
          top: effectiveTitlePadding.top * paddingScaleFactor,
          bottom: effectiveTitlePadding.bottom,
        ),
        child: DefaultTextStyle(
          style: titleTextStyle ?? dialogTheme.titleTextStyle ?? theme.textTheme.headline6!,
          child: Semantics(
            child: title,
            namesRoute: label == null,
            container: true,
          ),
        ),
      );
    }

    if (content != null) {
      final EdgeInsets effectiveContentPadding = contentPadding.resolve(textDirection);
      contentWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveContentPadding.left * paddingScaleFactor,
          right: effectiveContentPadding.right * paddingScaleFactor,
          top: title == null ? effectiveContentPadding.top * paddingScaleFactor : effectiveContentPadding.top,
          bottom: effectiveContentPadding.bottom,
        ),
        child: DefaultTextStyle(
          style: contentTextStyle ?? dialogTheme.contentTextStyle ?? theme.textTheme.subtitle1!,
          child: Semantics(
            container: true,
            child: content!,
          ),
        ),
      );
    }

    Widget contents = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null) titleWidget!,
        if (content != null) Flexible(child: contentWidget!),
      ],
    );
    if (scrollable)
      contents = SingleChildScrollView(
        child: contents,
      );
    contents = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null || content != null)
          Flexible(
            child: contents,
          ),
      ],
    );
    if (compress_width) contents = IntrinsicWidth(child: contents);

    double window_height = MediaQuery.of(context).size.height;

    return Dialog(
      child: Container(
        child: contents,
        constraints: BoxConstraints(maxHeight: min(window_height - 100, max_height), minHeight: min_height, maxWidth: max_width, minWidth: min_width),
      ),
    );
  }
}

class DialogCloseButton extends StatelessWidget {
  DialogCloseButton();

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Positioned(
      child: Container(
        child: CloseButton(
          color: Colors.white,
        ),
        decoration: ShapeDecoration(color: theme_colours.CLOSE_ICON_BUTTON_COLOUR, shape: CircleBorder()),
      ),
      top: 10,
      right: 10,
    );
  }
}

class DialogButton extends StatelessWidget {
  String text;
  VoidCallback onclick;
  FocusNode? focus_node;

  DialogButton({required this.text, required this.onclick, this.focus_node});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onclick,
      focusNode: focus_node,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 15, color: get_zarainia_theme(context).ACCENT_TEXT_COLOUR),
      ),
    );
  }
}

class BaseMessageDialog extends StatelessWidget {
  String message;
  String? contents;
  Map<ShortcutActivator, Intent>? shortcuts;
  Map<Type, Action<Intent>>? actions;
  List<Widget> buttons;

  BaseMessageDialog({required this.message, required this.buttons, this.contents, this.shortcuts, this.actions});

  @override
  Widget build(BuildContext context) {
    var width_constraints = BoxConstraints(maxWidth: constants.EDIT_DIALOG_MAX_WIDTH);

    Widget dialog = AlertDialog(
      title: ConstrainedBox(
        child: Text(message),
        constraints: width_constraints,
      ),
      content: contents != null
          ? ConstrainedBox(
              child: Text(contents!),
              constraints: width_constraints,
            )
          : null,
      actions: buttons,
      actionsPadding: EdgeInsets.only(right: 10, bottom: 10),
    );

    if (shortcuts != null || actions != null)
      return DownPropagationShortcuts(
        shortcuts: shortcuts ?? {},
        actions: actions ?? {},
        autofocus: true,
        child: dialog,
      );
    return dialog;
  }
}

class ConfirmationDialog extends StatelessWidget {
  static const Map<ShortcutActivator, Intent> DIALOG_SHORTCUTS = {
    SingleActivator(LogicalKeyboardKey.enter): ConfirmIntent(),
    SingleActivator(LogicalKeyboardKey.escape): CancelIntent(),
  };

  String message;
  String? contents;
  String confirm_button_text;
  String cancel_button_text;
  VoidCallback on_confirm;
  VoidCallback? on_cancel;

  ConfirmationDialog({required this.message, this.contents, this.confirm_button_text = "Confirm", this.cancel_button_text = "Cancel", required this.on_confirm, this.on_cancel});

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
    on_cancel?.call();
  }

  void confirm(BuildContext context) {
    on_confirm();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BaseMessageDialog(
      shortcuts: DIALOG_SHORTCUTS,
      actions: {
        ConfirmIntent: CallbackAction(onInvoke: (_) => confirm(context)),
        CancelIntent: CallbackAction(onInvoke: (_) => cancel(context)),
      },
      message: message,
      contents: contents,
      buttons: [
        DialogButton(
          onclick: () => cancel(context),
          text: cancel_button_text,
        ),
        DialogButton(
          onclick: () => confirm(context),
          text: confirm_button_text,
        ),
      ],
    );
  }
}

class ChoiceDialog extends StatelessWidget {
  String message;
  String? contents;
  LinkedHashMap<String, VoidCallback> buttons;
  String cancel_button_text;
  VoidCallback? on_cancel;

  ChoiceDialog({required this.message, this.contents, required this.buttons, this.cancel_button_text = "Cancel", this.on_cancel}) : assert(buttons.isNotEmpty);

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
    on_cancel?.call();
  }

  void confirm_default(BuildContext context) {
    buttons.values.first();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BaseMessageDialog(
      shortcuts: ConfirmationDialog.DIALOG_SHORTCUTS,
      actions: {
        ConfirmIntent: CallbackAction(onInvoke: (_) => confirm_default(context)),
        CancelIntent: CallbackAction(onInvoke: (_) => cancel(context)),
      },
      message: message,
      contents: contents,
      buttons: [
            DialogButton(
              onclick: () => cancel(context),
              text: cancel_button_text,
            ),
          ] +
          buttons.entries
              .map(
                (button) => DialogButton(
                  text: button.key,
                  onclick: () {
                    Navigator.of(context).pop();
                    button.value();
                  },
                ),
              )
              .toList()
              .reversed
              .toList(),
    );
  }
}

class MessageDialog extends StatelessWidget {
  static const Map<ShortcutActivator, Intent> DIALOG_SHORTCUTS = {
    SingleActivator(LogicalKeyboardKey.enter): ConfirmIntent(),
    SingleActivator(LogicalKeyboardKey.escape): ConfirmIntent(),
  };

  String message;
  String? contents;
  String button_text;
  VoidCallback? on_confirm;

  MessageDialog({required this.message, this.contents, this.button_text = "OK", this.on_confirm});

  void confirm(BuildContext context) {
    Navigator.of(context).pop();
    on_confirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BaseMessageDialog(
      shortcuts: DIALOG_SHORTCUTS,
      actions: {
        ConfirmIntent: CallbackAction(onInvoke: (_) => confirm(context)),
      },
      message: message,
      contents: contents,
      buttons: [
        DialogButton(
          onclick: () => confirm(context),
          text: button_text,
        ),
      ],
    );
  }
}

class SearchableSelectList<T> extends StatefulWidget {
  final List<T> all_items;
  final Widget Function(BuildContext context, T item, bool selected, VoidCallback on_click, VoidCallback direct_select) item_builder;
  final bool Function(String search_string, T item) filter_function;
  final Function(BuildContext context, Set<T> selected_items)? confirm_callback;
  final bool multiselect;
  final Set<T> initial_selections;
  final String item_name;
  final String items_name;
  final bool tree_view;
  final int Function(T)? get_id;
  final Set<int> Function(T)? get_parent_ids;
  final bool trim_top;

  List<TreeNode<T>> tree_items;

  SearchableSelectList({
    required this.all_items,
    required this.item_builder,
    required this.filter_function,
    this.multiselect = false,
    this.confirm_callback,
    initial_selections,
    this.item_name = "item",
    this.items_name = "items",
    this.tree_view = false,
    this.get_id,
    this.get_parent_ids,
    this.trim_top = true,
  })  : this.initial_selections = initial_selections ?? [],
        this.tree_items = tree_view ? build_tree(list: all_items, get_id: get_id!, get_parent_ids: get_parent_ids!) : all_items.map((e) => TreeNode(e)).toList() {
    if (tree_view) {
      tree_items.removeWhere((e) => get_id!(e.entry) < 0);
      while (tree_items.length == 1) tree_items = tree_items[0].children;
      try {
        tree_items.insert(0, TreeNode(all_items.firstWhere((e) => get_id!(e) < 0)));
      } on StateError catch (_) {}
    }
  }

  @override
  _SearchableSelectListState<T> createState() => _SearchableSelectListState<T>();
}

class _SearchableSelectListState<T> extends State<SearchableSelectList<T>> {
  List<TreeNode<T>> parent_stack = [];
  List<TreeNode<T>> visible_items = [];
  List<TreeNode<T>> filtered_items = [];
  Set<T> selected_items = {};
  late TextEditingController search_controller;

  @override
  void initState() {
    super.initState();
    visible_items = widget.tree_items;
    filtered_items = visible_items;
    selected_items = widget.initial_selections;
    search_controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant SearchableSelectList<T> oldWidget) {
    if (oldWidget.initial_selections != widget.initial_selections) selected_items = widget.initial_selections;
    if (oldWidget.tree_items != widget.tree_items) {
      setState(() {
        parent_stack = [];
        visible_items = widget.tree_items;
        filtered_items = visible_items;
      });
    }
  }

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  void go_to_root() {
    setState(() {
      parent_stack = [];
      visible_items = widget.tree_items;
    });
  }

  void do_search(String search_string) {
    List<TreeNode<T>> new_items = search_string.isEmpty ? visible_items : visible_items.where((item) => widget.filter_function(search_string, item.entry)).toList();
    if (new_items.isEmpty && visible_items.isNotEmpty) {
      new_items = widget.all_items.where((item) => widget.filter_function(search_string, item)).map((e) => TreeNode(e)).toList();
      go_to_root();
    }
    setState(() {
      filtered_items = new_items;
    });
  }

  void return_single_selection(T item) {
    widget.confirm_callback?.call(context, {item});
    Navigator.of(context).pop();
  }

  void handle_select(T item) {
    if (widget.multiselect) {
      if (selected_items.contains(item))
        setState(() {
          selected_items.remove(item);
        });
      else
        setState(() {
          selected_items.add(item);
        });
    } else {
      return_single_selection(item);
    }
  }

  void enter_node(TreeNode<T> node) {
    setState(() {
      parent_stack.add(node);
      visible_items = node.children;
    });
    do_search(search_controller.text);
  }

  void exit_node() {
    setState(() {
      parent_stack.removeLast();
      if (parent_stack.isEmpty)
        visible_items = widget.tree_items;
      else
        visible_items = parent_stack.last.children;
    });
    do_search(search_controller.text);
  }

  void handle_click(TreeNode<T> node) {
    if (widget.tree_view) {
      if (!widget.multiselect) {
        if (node.children.isEmpty) return_single_selection(node.entry);
        enter_node(node);
      } else {
        if (node.children.isEmpty)
          handle_select(node.entry);
        else
          enter_node(node);
      }
    } else {
      handle_select(node.entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    VoidCallback cancel = () => Navigator.of(context).pop();
    VoidCallback confirm = () {
      widget.confirm_callback?.call(context, selected_items);
      Navigator.of(context).pop();
    };

    return DownPropagationShortcuts(
      shortcuts: ConfirmationDialog.DIALOG_SHORTCUTS,
      actions: {
        ConfirmIntent: CallbackAction(onInvoke: (_) => confirm()),
        CancelIntent: CallbackAction(onInvoke: (_) => cancel()),
      },
      autofocus: true,
      child: Column(
        children: [
          SearchField(
            on_search: do_search,
            controller: search_controller,
          ),
          SizedBox(height: 15),
          if (filtered_items.isEmpty)
            Text("No ${widget.items_name}")
          else if (widget.multiselect)
            Text("${selected_items.length} ${selected_items.length == 1 ? widget.item_name : widget.items_name} selected", style: TextStyle(color: theme_colours.ACCENT_TEXT_COLOUR)),
          SizedBox(height: 5),
          Flexible(
            child: Material(
              // because of https://github.com/flutter/flutter/issues/86584
              child: ConstrainedBox(
                child: ListView.builder(
                  itemCount: filtered_items.length,
                  itemBuilder: (context, index) {
                    return widget.item_builder(
                      context,
                      filtered_items[index].entry,
                      selected_items.contains(filtered_items[index].entry),
                      () => handle_click(filtered_items[index]),
                      () => handle_select(filtered_items[index].entry),
                    );
                  },
                  shrinkWrap: true,
                ),
                constraints: BoxConstraints(maxHeight: constants.SEARCH_SELECT_DIALOG_MAX_HEIGHT),
              ),
              elevation: 0,
              color: Colors.transparent,
            ),
          ),
          SizedBox(height: 10),
          if (widget.multiselect)
            Row(
              children: [
                if (selected_items.isNotEmpty)
                  DialogButton(
                    text: "Clear",
                    onclick: () {
                      setState(() {
                        selected_items = {};
                      });
                    },
                  ),
                if (selected_items.length < widget.all_items.length) SizedBox(width: 10),
                if (selected_items.length < widget.all_items.length)
                  DialogButton(
                    text: "Select all",
                    onclick: () {
                      setState(() {
                        selected_items.addAll(filtered_items.map((e) => e.entry));
                      });
                    },
                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          if (widget.multiselect) SizedBox(height: 10),
          if (widget.multiselect)
            Row(
              children: [
                if (parent_stack.isNotEmpty)
                  DialogButton(
                    text: "Go up",
                    onclick: exit_node,
                  ),
                if (parent_stack.isNotEmpty) SizedBox(width: 10),
                DialogButton(
                  text: "Cancel",
                  onclick: cancel,
                ),
                SizedBox(width: 10),
                DialogButton(
                  text: "Confirm",
                  onclick: confirm,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

class SimpleSelectDialog<T> extends StatelessWidget {
  List<T> all_options;
  Function(T)? onclick;
  bool multi_select;
  Function(BuildContext, Set<T>)? confirm_callback;
  Set<T> initial_selections;
  String item_name;
  String item_name_plural;
  bool Function(String, T)? filter_function;
  String Function(T) display_convertor;

  SimpleSelectDialog(
      {Key? key,
      this.filter_function,
      required this.item_name,
      String? item_name_plural,
      required this.all_options,
      this.onclick,
      this.multi_select = false,
      this.confirm_callback,
      Set<T>? initial_selections,
      String Function(T)? display_convertor})
      : initial_selections = initial_selections ?? {},
        item_name_plural = item_name_plural ?? pluralize(item_name),
        display_convertor = display_convertor ?? ((T value) => value?.toString() ?? "none"),
        super(key: key) {}

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    return CompatibleDialog(
      title: Text("Select ${multi_select ? item_name_plural : item_name}"),
      content: Container(
        child: SearchableSelectList<T>(
          all_items: all_options,
          item_builder: (BuildContext context, T item, bool selected, VoidCallback default_onclick, VoidCallback select_item) {
            return ListTile(
              title: Text(display_convertor(item)),
              leading: IconButton(
                icon: Icon(selected ? Icons.check_box : Icons.check_box_outline_blank),
                color: theme_colours.ACCENT_COLOUR,
                onPressed: select_item,
              ),
              onTap: () {
                onclick?.call(item);
                default_onclick();
              },
              tileColor: selected ? theme_colours.WEAK_ACCENT_COLOUR : null,
            );
          },
          filter_function: filter_function ?? (String search_string, T item) => caseless_match(search_string, display_convertor(item)),
          multiselect: multi_select,
          confirm_callback: confirm_callback,
          initial_selections: initial_selections,
          item_name: item_name,
          items_name: item_name_plural,
        ),
      ),
      max_width: constants.SEARCH_SELECT_DIALOG_MAX_WIDTH,
      scrollable: false,
    );
  }
}

class ButtonlessDialog extends StatelessWidget {
  List<Widget> stack_widgets;
  double min_width;
  double max_width;
  double min_height;
  double max_height;

  ButtonlessDialog({required this.stack_widgets, this.max_width = constants.EDIT_DIALOG_MAX_WIDTH, this.max_height = double.infinity, this.min_width = 0, this.min_height = 0});

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(onKey: (_, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }),
      child: Dialog(
        child: Container(
          child: Stack(
            children: stack_widgets + [DialogCloseButton()],
            alignment: Alignment.center,
          ),
          constraints: BoxConstraints(maxHeight: max_height, minHeight: min_height, maxWidth: max_width, minWidth: min_width),
        ),
      ),
      // autofocus: true,
    );
  }
}

class HeaderedButtonlessDialog extends StatelessWidget {
  String title;
  BoxConstraints constraints;
  Widget child;

  HeaderedButtonlessDialog({required this.title, required this.child, this.constraints = const BoxConstraints(minWidth: 400, maxWidth: 1000)});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return ButtonlessDialog(stack_widgets: [
      Container(
        child: ListView(
          children: [
            Text(
              title,
              style: theme_colours.POPUP_HEADER_STYLE,
            ),
            const SizedBox(height: 20),
            child,
          ],
          shrinkWrap: true,
        ),
        constraints: constraints,
        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 30),
      ),
    ]);
  }
}
