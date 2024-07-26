import 'dart:collection';
import 'dart:math';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inflection2/inflection2.dart';
import 'package:zarainia_utils/src/exports.dart';

import '../constants.dart' as constants;

Future show_dialog({required BuildContext context, required Widget Function(BuildContext context) builder}) {
  OriginalZarainiaTheme? outer_theme = get_original_theme(context, watch: false);
  return showDialog(
    context: outer_theme?.original_context ?? context,
    builder: builder,
  );
}

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

    return ZarainiaTheme.off_appbar_theme_provider(
      context,
      (context) => ContextMenuOverlay(
        child: Dialog(
          child: Container(
            child: contents,
            constraints: BoxConstraints(maxHeight: min(window_height - 100, max_height), minHeight: min_height, maxWidth: max_width, minWidth: min_width),
          ),
        ),
      ),
    );
  }
}

class PositionedCloseButton extends StatelessWidget {
  final bool invert_background;

  const PositionedCloseButton({this.invert_background = false});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Positioned(
      child: invert_background
          ? Container(
              child: const CloseButton(color: Colors.white),
              decoration: ShapeDecoration(color: theme_colours.CLOSE_ICON_BUTTON_COLOUR, shape: const CircleBorder()),
            )
          : const CloseButton(),
      top: 10,
      right: 10,
    );
  }
}

class DialogButton extends StatelessWidget {
  String text;
  VoidCallback? onclick;
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
  String? message;
  Widget? message_widget;
  String? contents;
  Widget? content_widget;
  Map<ShortcutActivator, Intent>? shortcuts;
  Map<Type, Action<Intent>>? actions;
  List<Widget> buttons;
  BoxConstraints constraints;
  bool close_button;

  BaseMessageDialog({
    this.message,
    this.message_widget,
    required this.buttons,
    this.contents,
    this.content_widget,
    this.shortcuts,
    this.actions,
    this.constraints = const BoxConstraints(maxWidth: constants.ALERT_DIALOG_MAX_WIDTH),
    this.close_button = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialog = ZarainiaTheme.off_appbar_theme_provider(
      context,
      (context) => ContextMenuOverlay(
        child: AlertDialog(
          title: ConstrainedBox(
            child: message_widget ?? Text(message!),
            constraints: constraints.widthConstraints(),
          ),
          content: content_widget != null || contents != null
              ? ConstrainedBox(
                  child: content_widget ?? Text(contents!),
                  constraints: constraints,
                )
              : null,
          actions: buttons,
          actionsPadding: EdgeInsets.only(right: 10, bottom: 10),
        ),
      ),
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
    Navigator.of(context).pop(false);
    on_cancel?.call();
  }

  void confirm(BuildContext context) {
    on_confirm();
    Navigator.of(context).pop(true);
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
    Navigator.of(context).pop(false);
    on_cancel?.call();
  }

  void confirm_default(BuildContext context) {
    buttons.values.first();
    Navigator.of(context).pop(true);
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
                    Navigator.of(context).pop(true);
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
  final bool Function(T item) can_select;

  List<TreeNode<T>> tree_items;

  SearchableSelectList({
    required this.all_items,
    required this.item_builder,
    required this.filter_function,
    this.multiselect = false,
    this.confirm_callback,
    Iterable<T>? initial_selections,
    this.item_name = "item",
    this.items_name = "items",
    this.tree_view = false,
    this.get_id,
    this.get_parent_ids,
    this.trim_top = true,
    bool Function(T item)? can_select,
  })  : this.initial_selections = initial_selections != null ? {...initial_selections} : {},
        this.tree_items = tree_view ? build_tree(list: all_items, get_id: get_id!, get_parent_ids: get_parent_ids!) : all_items.map((e) => TreeNode(e)).toList(),
        can_select = can_select ?? ((_) => true) {
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
  String search_string = '';

  @override
  void initState() {
    super.initState();
    visible_items = widget.tree_items;
    filtered_items = visible_items;
    selected_items = widget.initial_selections;
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
    Navigator.of(context).pop(true);
  }

  void handle_select(T item) {
    if (widget.can_select(item)) {
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
  }

  void enter_node(TreeNode<T> node) {
    setState(() {
      parent_stack.add(node);
      visible_items = node.children;
    });
    do_search(search_string);
  }

  void exit_node() {
    setState(() {
      parent_stack.removeLast();
      if (parent_stack.isEmpty)
        visible_items = widget.tree_items;
      else
        visible_items = parent_stack.last.children;
    });
    do_search(search_string);
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

    VoidCallback cancel = () => Navigator.of(context).pop(false);
    VoidCallback confirm = () {
      widget.confirm_callback?.call(context, selected_items);
      Navigator.of(context).pop(true);
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
            search_string: search_string,
            on_search: do_search,
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
            )
          else if (widget.tree_view && parent_stack.isNotEmpty)
            Row(
              children: [
                DialogButton(
                  text: "Go up",
                  onclick: exit_node,
                ),
                if (widget.can_select(parent_stack.last.entry))
                  DialogButton(
                    text: "Confirm",
                    onclick: () => return_single_selection(parent_stack.last.entry),
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
  IconData? icon;

  SimpleSelectDialog({
    Key? key,
    this.filter_function,
    required this.item_name,
    String? item_name_plural,
    required this.all_options,
    this.onclick,
    this.multi_select = false,
    this.confirm_callback,
    Set<T>? initial_selections,
    String Function(T)? display_convertor,
    this.icon,
  })  : initial_selections = initial_selections ?? {},
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
              leading: multi_select
                  ? IconButton(
                      icon: Icon(icon ?? (selected ? Icons.check_box : Icons.check_box_outline_blank)),
                      color: theme_colours.ACCENT_COLOUR,
                      onPressed: select_item,
                    )
                  : Icon(icon),
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

class EntrySelectDialog<IDType, T> extends StatelessWidget {
  final String item_name;
  final String item_name_plural;
  final List<IDType> all_options;
  final Set<IDType> initial_selections;
  final T Function(IDType) get_entry;
  final Function(T)? onclick;
  final Function(BuildContext, Set<IDType>)? confirm_callback;
  final bool Function(String, T)? filter_function;
  final String Function(T)? display_convertor;
  final Widget Function(BuildContext context, T item, bool selected)? label_builder;
  final IconData? icon;
  final Widget Function(BuildContext context, T item, bool selected)? icon_builder;
  final Color? Function(BuildContext context, T item, bool selected)? get_icon_colour;
  final Color? Function(BuildContext context, T item, bool selected)? get_tile_colour;
  final bool multi_select;

  EntrySelectDialog({
    super.key,
    required this.item_name,
    String? item_name_plural,
    required this.all_options,
    Set<IDType>? initial_selections,
    required this.get_entry,
    this.onclick,
    this.confirm_callback,
    this.filter_function,
    String Function(T)? display_convertor,
    this.label_builder,
    this.icon,
    this.icon_builder,
    this.get_icon_colour,
    this.get_tile_colour,
    this.multi_select = false,
  })  : initial_selections = initial_selections ?? {},
        item_name_plural = item_name_plural ?? pluralize(item_name),
        display_convertor = display_convertor ?? ((T value) => value.toString());

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    return CompatibleDialog(
      title: Text("Select ${multi_select ? item_name_plural : item_name}"),
      content: Container(
        child: SearchableSelectList<IDType>(
          all_items: all_options,
          item_builder: (BuildContext context, IDType id, bool selected, VoidCallback default_onclick, VoidCallback select_item) {
            T entry = get_entry(id);

            return ListTile(
              title: label_builder?.call(context, entry, selected) ?? Text(display_convertor!(entry)),
              leading: multi_select
                  ? IconButton(
                      icon: icon_builder?.call(context, entry, selected) ?? Icon(icon ?? (selected ? Icons.check_box : Icons.check_box_outline_blank)),
                      color: get_icon_colour?.call(context, entry, selected) ?? theme_colours.ACCENT_COLOUR,
                      onPressed: select_item,
                    )
                  : icon_builder?.call(context, entry, selected) ?? Icon(icon),
              onTap: () {
                onclick?.call(entry);
                default_onclick();
              },
              tileColor: get_tile_colour?.call(context, entry, selected) ?? (selected ? theme_colours.WEAK_ACCENT_COLOUR : null),
            );
          },
          filter_function: filter_function != null
              ? ((String search_string, IDType id) => filter_function!(search_string, get_entry(id)))
              : (String search_string, IDType id) => caseless_match(search_string, display_convertor!(get_entry(id))),
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

class AddNullEntrySelectDialog<IDType, T> extends StatelessWidget {
  final String item_name;
  final String item_name_plural;
  final List<IDType?> all_options;
  final Set<IDType?> initial_selections;
  final T Function(IDType) get_entry;
  final Function(T?)? onclick;
  final Function(BuildContext, Set<IDType?>)? confirm_callback;
  final bool? Function(String, T?)? filter_function;
  final String Function(T?) display_convertor;
  final Widget Function(BuildContext context, T item, bool selected)? label_builder;
  final IconData? icon;
  final Widget Function(BuildContext context, T item, bool selected)? icon_builder;
  final Color Function(BuildContext context, T? item, bool selected)? get_icon_colour;
  final Color Function(BuildContext context, T? item, bool selected)? get_tile_colour;
  final String null_text;
  final Widget Function(BuildContext context, bool selected)? null_label_builder;
  final Function(BuildContext context, bool selected)? null_icon_builder;
  final bool multi_select;

  AddNullEntrySelectDialog({
    super.key,
    required this.item_name,
    String? item_name_plural,
    required this.all_options,
    Set<IDType?>? initial_selections,
    required this.get_entry,
    this.onclick,
    this.confirm_callback,
    this.filter_function,
    String? Function(T?)? display_convertor,
    this.label_builder,
    this.icon,
    this.icon_builder,
    this.get_icon_colour,
    this.get_tile_colour,
    this.null_text = "none",
    this.null_label_builder,
    this.null_icon_builder,
    this.multi_select = false,
  })  : initial_selections = initial_selections ?? {},
        item_name_plural = item_name_plural ?? pluralize(item_name),
        display_convertor = ((T? value) => display_convertor?.call(value) ?? value?.toString() ?? null_text);

  @override
  Widget build(BuildContext context) {
    return EntrySelectDialog<IDType?, T?>(
      item_name: item_name,
      item_name_plural: item_name_plural,
      all_options: all_options,
      initial_selections: initial_selections,
      get_entry: (id) => id == null ? null : get_entry(id),
      onclick: onclick,
      confirm_callback: confirm_callback,
      filter_function: filter_function == null
          ? null
          : (search_string, entry) {
              bool? matches = filter_function!(search_string, entry);
              if (entry != null)
                return matches!;
              else
                return matches ?? caseless_match(search_string, display_convertor(entry));
            },
      display_convertor: display_convertor,
      label_builder: (context, entry, selected) => (entry == null ? null_label_builder?.call(context, selected) : label_builder?.call(context, entry, selected)) ?? Text(display_convertor(entry)),
      icon: icon,
      icon_builder: (context, entry, selected) {
        return (entry == null ? null_icon_builder?.call(context, selected) : icon_builder?.call(context, entry, selected)) ?? multi_select
            ? Icon(icon ?? (selected ? Icons.check_box : Icons.check_box_outline_blank))
            : Icon(icon);
      },
      get_icon_colour: get_icon_colour,
      get_tile_colour: get_tile_colour,
      multi_select: multi_select,
    );
  }
}

class ButtonlessDialog extends StatelessWidget {
  List<Widget> stack_widgets;
  double min_width;
  double max_width;
  double min_height;
  double max_height;

  ButtonlessDialog({required this.stack_widgets, this.max_width = constants.ALERT_DIALOG_MAX_WIDTH, this.max_height = double.infinity, this.min_width = 0, this.min_height = 0});

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
      child: ZarainiaTheme.off_appbar_theme_provider(
        context,
        (context) => ContextMenuOverlay(
          child: Dialog(
            child: Container(
              child: Stack(
                children: stack_widgets + const [PositionedCloseButton()],
                alignment: Alignment.center,
              ),
              constraints: BoxConstraints(
                maxHeight: max_height,
                minHeight: min_height,
                maxWidth: max_width,
                minWidth: min_width,
              ),
            ),
          ),
        ),
      ),
      // autofocus: true,
    );
  }
}

class HeaderedButtonlessDialog extends StatelessWidget {
  final String? title;
  final Widget? title_widget;
  final BoxConstraints? constraints;
  final Widget child;
  final bool scrollable;

  const HeaderedButtonlessDialog({
    this.title,
    this.title_widget,
    required this.child,
    this.constraints,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    Widget created_title = title_widget ?? Text(title!, style: theme_colours.POPUP_HEADER_STYLE);

    return ButtonlessDialog(
      stack_widgets: [
        Container(
          child: scrollable
              ? ListView(
                  children: [
                    created_title,
                    const SizedBox(height: 20),
                    child,
                  ],
                  shrinkWrap: true,
                )
              : Column(
                  children: [
                    created_title,
                    const SizedBox(height: 20),
                    Flexible(child: child),
                  ],
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 30),
        ),
      ],
      min_width: constraints?.minWidth ?? 0,
      max_width: constraints?.maxWidth ?? constants.ALERT_DIALOG_MAX_WIDTH,
      min_height: constraints?.minHeight ?? 0,
      max_height: constraints?.maxHeight ?? double.infinity,
    );
  }
}

class FixDialogListView extends StatelessWidget {
  final Widget child;

  const FixDialogListView({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: child, width: double.maxFinite);
  }
}

class DiscardFileConfirmationDialog extends StatelessWidget {
  final VoidCallback on_confirm;

  const DiscardFileConfirmationDialog({required this.on_confirm});

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      message: "Discard changes?",
      contents: "You have unsaved changes. Are you sure you want to discard them?",
      confirm_button_text: "Discard",
      on_confirm: on_confirm,
    );
  }
}
