import 'package:flutter/material.dart';

import 'package:inflection2/inflection2.dart';
import 'package:intl/intl.dart';

import 'package:zarainia_utils/src/theme.dart';
import 'dialog.dart';

class MultiFilterRow<T> extends StatelessWidget {
  Set<T> curr_list;
  Function(Set<T> new_list) cubit_update_function;
  String label;
  Widget dialog;
  String item_name;
  String item_name_plural;

  MultiFilterRow({required this.curr_list, required this.label, required this.dialog, required this.cubit_update_function, this.item_name = "item", String? item_name_plural})
      : item_name_plural = item_name_plural ?? pluralize(item_name);

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return ListTile(
      title: Row(
        children: [
          Text(label),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(":"),
          ),
          Expanded(
            child: Text(
              "${curr_list.length} ${curr_list.length != 1 ? item_name_plural : item_name} selected",
              style: TextStyle(color: theme_colours.ACCENT_TEXT_COLOUR),
            ),
          ),
        ],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return dialog;
          },
        );
      },
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: theme_colours.ICON_COLOUR,
        ),
        onPressed: () {
          cubit_update_function({});
        },
      ),
    );
  }
}

class TextSwitchIndicator extends StatelessWidget {
  String text;

  TextSwitchIndicator({required this.text});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    return Container(
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: theme_colours.ACCENT_TEXT_COLOUR),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: theme_colours.ACCENT_TEXT_COLOUR),
      ),
      padding: EdgeInsets.all(5),
    );
  }
}

class TriStateSwitch extends StatelessWidget {
  bool? curr_value;
  Function(bool? new_value) cubit_update_function;
  String label;
  String true_label;
  String false_label;
  String? both_label;

  TriStateSwitch({required this.curr_value, required this.label, this.true_label = "true", this.false_label = "false", this.both_label = "both", required this.cubit_update_function});

  @override
  Widget build(BuildContext context) {
    Widget true_indicator = TextSwitchIndicator(text: true_label);
    Widget false_indicator = TextSwitchIndicator(text: false_label);

    Widget indicator;
    if (curr_value == null) {
      if (both_label != null)
        indicator = TextSwitchIndicator(text: both_label!);
      else
        indicator = Row(children: [true_indicator, false_indicator], mainAxisSize: MainAxisSize.min);
    } else {
      if (curr_value!)
        indicator = true_indicator;
      else
        indicator = false_indicator;
    }

    return ListTile(
      title: Text(label),
      onTap: () {
        if (curr_value == null)
          curr_value = true;
        else if (!curr_value!)
          curr_value = null;
        else
          curr_value = false;
        cubit_update_function(curr_value);
      },
      trailing: indicator,
    );
  }
}

class MultiFilterSimpleSelectDialog<T> extends StatelessWidget {
  Set<T> curr_selections;
  List<T> all_options;
  Function(Set<T>) confirm_callback;
  String label;
  String item_name;
  String? item_name_plural;
  String Function(T)? display_convertor;

  MultiFilterSimpleSelectDialog({
    required this.item_name,
    required this.curr_selections,
    required this.all_options,
    required this.confirm_callback,
    String? label,
    this.item_name_plural,
    this.display_convertor,
  }) : label = label ?? toBeginningOfSentenceCase(item_name_plural ?? pluralize(item_name))!;

  @override
  Widget build(BuildContext context) {
    return MultiFilterRow<T>(
      curr_list: curr_selections,
      label: label,
      dialog: SimpleSelectDialog(
        item_name: item_name,
        item_name_plural: item_name_plural,
        all_options: all_options,
        display_convertor: display_convertor,
        multi_select: true,
        confirm_callback: (_, Set<T> new_set) => confirm_callback(new_set),
        initial_selections: curr_selections,
      ),
      cubit_update_function: confirm_callback,
      item_name: item_name,
      item_name_plural: item_name_plural,
    );
  }
}

class MultiFilterEntrySelectDialog<IDType> extends StatelessWidget {
  Widget Function({
    required Function(Set<IDType>) confirm_selections,
    required Set<IDType> initial_selections,
    bool multi_select,
    bool add_null,
    String item_name,
    String? item_name_plural,
  }) dialog_builder;
  Set<IDType> curr_selections;
  Function(Set<IDType>) confirm_selections;
  String label;
  String item_name;
  String? item_name_plural;
  String Function(IDType)? display_convertor;
  bool add_null;

  MultiFilterEntrySelectDialog({
    required this.dialog_builder,
    required this.item_name,
    required this.curr_selections,
    required this.confirm_selections,
    String? label,
    this.item_name_plural,
    this.display_convertor,
    this.add_null = true,
  }) : label = label ?? toBeginningOfSentenceCase(item_name_plural ?? pluralize(item_name))!;

  @override
  Widget build(BuildContext context) {
    return MultiFilterRow<IDType>(
      curr_list: curr_selections,
      label: label,
      dialog: dialog_builder(
        multi_select: true,
        confirm_selections: confirm_selections,
        initial_selections: curr_selections,
        add_null: add_null,
        item_name: item_name,
        item_name_plural: item_name_plural,
      ),
      cubit_update_function: confirm_selections,
      item_name: item_name,
      item_name_plural: item_name_plural,
    );
  }
}
