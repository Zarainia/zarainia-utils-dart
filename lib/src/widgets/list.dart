import 'package:flutter/material.dart';

import 'package:zarainia_utils/src/exports.dart';

class EditListRow extends StatelessWidget {
  final VoidCallback? on_edit;
  final VoidCallback? on_select;
  final VoidCallback? on_delete;
  final Widget? leading;
  final Widget title;
  final List<Widget> actions;
  final bool force_edit_button;

  const EditListRow({
    this.leading,
    required this.title,
    this.on_edit,
    this.on_select,
    this.on_delete,
    this.actions = const [],
    this.force_edit_button = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      trailing: Row(
        children: [
          if (on_select != null || force_edit_button)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: on_edit,
              tooltip: "Edit",
            ),
          ...actions,
          if (on_delete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: on_delete,
              tooltip: "Delete",
            )
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      onTap: on_select == null
          ? (force_edit_button ? null : on_edit)
          : () {
              Navigator.of(context).pop();
              on_select!();
            },
    );
  }
}

class ListTileNumber extends StatelessWidget {
  final String number;
  final String suffix;

  const ListTileNumber({required this.number, this.suffix = '.'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Text("${number}${suffix}", textAlign: TextAlign.right),
      width: 25,
    );
  }
}

class ListTileRadioButton extends StatelessWidget {
  final bool checked;
  final Function(bool) on_change;
  final bool select_multiple;
  final String? tooltip;

  const ListTileRadioButton({
    required this.checked,
    required this.on_change,
    this.select_multiple = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (select_multiple)
      return Checkbox(value: checked, onChanged: (value) => on_change(value!));
    else
      return Radio(value: true, groupValue: checked, onChanged: (value) => on_change(value!));
  }
}

class ListEndAddButton extends StatelessWidget {
  final VoidCallback on_click;
  final String tooltip;

  const ListEndAddButton({required this.on_click, this.tooltip = "Add"});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Padding(
      child: Tooltip(
        child: OutlinedButton(
          child: Icon(Icons.add, color: theme_colours.ICON_COLOUR),
          onPressed: on_click,
        ),
        message: tooltip,
      ),
      padding: const EdgeInsets.only(top: 20),
    );
  }
}
