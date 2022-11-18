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

  CardAccordion({this.leading, required this.title, this.subtitle, required this.contents, this.card_shape, this.card_colour, this.tile_colour, this.tile_icon_colour, this.keep_inner_state = false});

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
            return Card(
              child: Column(
                children: [
                  ListTile(
                    leading: widget.leading,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    trailing: Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: widget.tile_icon_colour),
                    onTap: () {
                      focus_node.requestFocus();
                      change_expand(!expanded);
                    },
                    tileColor: widget.tile_colour,
                  ),
                  if (!widget.keep_inner_state && expanded) widget.contents else if (widget.keep_inner_state) Offstage(child: widget.contents, offstage: !expanded),
                ],
              ),
              clipBehavior: Clip.hardEdge, // maintain rounded border
              color: widget.card_colour,
              shape: widget.card_shape,
            );
          },
        ),
        onTap: () => focus_node.requestFocus(),
      ),
    );
  }
}
