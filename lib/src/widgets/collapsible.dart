import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zarainia_utils/src/shortcuts.dart';

class OuterExpandCollapser extends StatelessWidget {
  static const Map<ShortcutActivator, Intent> SHORTCUTS = {
    SingleActivator(LogicalKeyboardKey.equal, control: true, shift: true): ExpandAllIntent(),
    SingleActivator(LogicalKeyboardKey.minus, control: true, shift: true): CollapseAllIntent(),
  };

  Widget child;

  OuterExpandCollapser({required this.child});

  @override
  Widget build(BuildContext context) {
    return DownPropagationShortcuts(
      shortcuts: SHORTCUTS,
      child: child,
      autofocus: true,
      always_invoke_up: false,
    );
  }
}

class Collapser extends StatefulWidget {
  Widget Function(BuildContext context, bool expanded, Function(bool) change_expand) builder;
  bool expand_by_default;

  Collapser({required this.builder, this.expand_by_default = false});

  @override
  _CollapserState createState() => _CollapserState();
}

class _CollapserState extends State<Collapser> with AutomaticKeepAliveClientMixin {
  static const Map<ShortcutActivator, Intent> SHORTCUTS = {
    SingleActivator(LogicalKeyboardKey.equal, control: true, alt: true): ExpandIntent(),
    SingleActivator(LogicalKeyboardKey.minus, control: true, alt: true): CollapseIntent(),
  };
  Map<Type, Action> actions = {};

  bool expanded = false;

  @override
  void initState() {
    super.initState();
    actions = {
      ExpandIntent: CallbackAction<ExpandIntent>(onInvoke: (_) => change_expand(true)),
      CollapseIntent: CallbackAction<CollapseIntent>(onInvoke: (_) => change_expand(false)),
      ExpandAllIntent: CallbackAction<ExpandAllIntent>(onInvoke: (_) => change_expand(true)),
      CollapseAllIntent: CallbackAction<CollapseAllIntent>(onInvoke: (_) => change_expand(false)),
    };
    expanded = widget.expand_by_default;
  }

  void change_expand(bool new_value) {
    if (new_value != expanded) {
      setState(() {
        expanded = new_value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DownPropagationShortcuts(
      actions: actions,
      shortcuts: SHORTCUTS,
      child: widget.builder(context, expanded, change_expand),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CardAccordionBody extends StatelessWidget {
  Widget? leading;
  Widget title;
  Widget? subtitle;
  Widget contents;
  bool expanded;
  Function(bool) change_expand;
  ShapeBorder? card_shape;
  Color? card_colour;
  Color? tile_colour;
  Color? tile_icon_colour;
  bool keep_inner_state;
  VoidCallback? get_focus;

  CardAccordionBody({
    this.leading,
    required this.title,
    this.subtitle,
    required this.contents,
    this.expanded = false,
    required this.change_expand,
    this.card_shape,
    this.card_colour,
    this.tile_colour,
    this.tile_icon_colour,
    this.keep_inner_state = false,
    this.get_focus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: leading,
            title: title,
            subtitle: subtitle,
            trailing: Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: tile_icon_colour),
            onTap: () {
              get_focus?.call();
              change_expand(!expanded);
            },
            tileColor: tile_colour,
          ),
          if (!keep_inner_state && expanded) contents else if (keep_inner_state) Offstage(child: contents, offstage: !expanded),
        ],
      ),
      clipBehavior: Clip.hardEdge, // maintain rounded border
      color: card_colour,
      shape: card_shape,
    );
  }
}

class CardAccordion extends StatefulWidget {
  Widget? leading;
  Widget title;
  Widget? subtitle;
  Widget contents;
  ShapeBorder? card_shape;
  Color? card_colour;
  Color? tile_colour;
  Color? tile_icon_colour;
  bool keep_inner_state;

  CardAccordion({
    this.leading,
    required this.title,
    this.subtitle,
    required this.contents,
    this.card_shape,
    this.card_colour,
    this.tile_colour,
    this.tile_icon_colour,
    this.keep_inner_state = false,
  });

  @override
  _CardAccordionState createState() => _CardAccordionState();
}

class _CardAccordionState extends State<CardAccordion> {
  late FocusNode focus_node;

  @override
  void initState() {
    super.initState();
    focus_node = FocusNode();
  }

  @override
  void dispose() {
    focus_node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focus_node,
      child: GestureDetector(
        child: Collapser(
          builder: (context, expanded, change_expand) {
            return CardAccordionBody(
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              contents: widget.contents,
              expanded: expanded,
              change_expand: change_expand,
              get_focus: focus_node.requestFocus,
              card_shape: widget.card_shape,
              card_colour: widget.card_colour,
              tile_colour: widget.tile_colour,
              tile_icon_colour: widget.tile_icon_colour,
              keep_inner_state: widget.keep_inner_state,
            );
          },
        ),
        onTap: () => focus_node.requestFocus(),
      ),
    );
  }
}

class CustomCardAccordion extends StatefulWidget {
  Widget? leading;
  Widget title;
  Widget? subtitle;
  Widget contents;
  bool expanded;
  Function(bool) change_expand;
  ShapeBorder? card_shape;
  Color? card_colour;
  Color? tile_colour;
  Color? tile_icon_colour;
  bool keep_inner_state;
  Map<Type, Action> actions;

  CustomCardAccordion({
    this.leading,
    required this.title,
    this.subtitle,
    required this.contents,
    this.expanded = false,
    required this.change_expand,
    this.card_shape,
    this.card_colour,
    this.tile_colour,
    this.tile_icon_colour,
    this.keep_inner_state = false,
    this.actions = const {},
  });

  @override
  _CustomCardAccordionState createState() => _CustomCardAccordionState();
}

class _CustomCardAccordionState extends State<CustomCardAccordion> {
  static const Map<ShortcutActivator, Intent> SHORTCUTS = {
    SingleActivator(LogicalKeyboardKey.equal, control: true, alt: true): ExpandIntent(),
    SingleActivator(LogicalKeyboardKey.minus, control: true, alt: true): CollapseIntent(),
  };

  late FocusNode focus_node;

  @override
  void initState() {
    super.initState();
    focus_node = FocusNode();
  }

  @override
  void dispose() {
    focus_node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DownPropagationShortcuts(
      actions: widget.actions,
      shortcuts: SHORTCUTS,
      child: Focus(
        focusNode: focus_node,
        child: GestureDetector(
          child: CardAccordionBody(
            leading: widget.leading,
            title: widget.title,
            subtitle: widget.subtitle,
            contents: widget.contents,
            expanded: widget.expanded,
            change_expand: widget.change_expand,
            get_focus: focus_node.requestFocus,
            card_shape: widget.card_shape,
            card_colour: widget.card_colour,
            tile_colour: widget.tile_colour,
            tile_icon_colour: widget.tile_icon_colour,
            keep_inner_state: widget.keep_inner_state,
          ),
          onTap: () => focus_node.requestFocus(),
        ),
      ),
    );
  }
}
