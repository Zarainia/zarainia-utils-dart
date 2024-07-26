import 'dart:math';

import 'package:collection/collection.dart' hide Tuple2;
import 'package:flutter/material.dart';
import 'package:measured_size/measured_size.dart';
import 'package:zarainia_utils/src/exports.dart';

class LabeledCheckbox extends StatelessWidget {
  bool value;
  Function(bool?) on_changed;
  String label;
  MaterialTapTargetSize? materialTapTargetSize;
  double? checkbox_width;
  double? checkbox_height;
  TextStyle? label_style;
  double label_spacing;
  FocusNode? focus_node;

  LabeledCheckbox(
      {required this.value,
      required this.on_changed,
      required this.label,
      this.materialTapTargetSize,
      this.checkbox_width,
      this.checkbox_height,
      this.label_style,
      this.label_spacing = 0,
      this.focus_node});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          SizedBox(
            child: Checkbox(
              value: value,
              onChanged: on_changed,
              materialTapTargetSize: materialTapTargetSize,
              focusNode: focus_node,
            ),
            width: checkbox_width,
            height: checkbox_height,
          ),
          SizedBox(width: label_spacing),
          Text(
            label,
            style: label_style,
          ),
        ],
      ),
      onTap: () => on_changed(!value),
    );
  }
}

class LabeledSwitch extends StatelessWidget {
  bool value;
  Function(bool?)? on_changed;
  String label;
  MaterialTapTargetSize? materialTapTargetSize;
  TextStyle? label_style;
  double label_spacing;
  FocusNode? focus_node;

  LabeledSwitch({
    required this.value,
    required this.on_changed,
    required this.label,
    this.materialTapTargetSize,
    this.label_style,
    this.label_spacing = 0,
    this.focus_node,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: on_changed,
            materialTapTargetSize: materialTapTargetSize,
            focusNode: focus_node,
          ),
          SizedBox(width: label_spacing),
          Text(
            label,
            style: label_style,
          ),
          SizedBox(width: 10)
        ],
      ),
      onTap: on_changed == null ? null : () => on_changed!.call(!value),
    );
  }
}

class OptionEntryItemWrapper<T> extends StatefulWidget {
  T value;
  Widget Function(BuildContext, bool) builder;
  Function(T value)? on_focus;
  Color? Function(T value)? focus_colour_getter;
  bool is_first;
  bool is_last;
  bool add_shadow;

  OptionEntryItemWrapper({
    required this.value,
    required this.builder,
    this.on_focus,
    this.focus_colour_getter,
    this.is_first = false,
    this.is_last = false,
    this.add_shadow = false,
  });

  @override
  _OptionEntryItemWrapperState<T> createState() => _OptionEntryItemWrapperState<T>();
}

class _OptionEntryItemWrapperState<T> extends State<OptionEntryItemWrapper<T>> {
  static const double DEFAULT_DROPDOWN_PADDING = 16;
  static const double TOP_AND_BOTTOM_PADDING = 8;

  bool focused = false;
  FocusNode? node;
  double content_height = 0;

  void focus_listener() {
    if (mounted && node != null) {
      setState(() {
        focused = node!.hasFocus;
      });
      if (focused) widget.on_focus?.call(widget.value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    node?.removeListener(focus_listener);
    node = Focus.of(context);
    node?.addListener(focus_listener);
  }

  @override
  void dispose() {
    node?.removeListener(focus_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    Color background_colour = focused ? (widget.focus_colour_getter?.call(widget.value) ?? theme_colours.ACCENT_COLOUR) : theme_colours.BASE_BACKGROUND_COLOUR;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double max_height = constraints.maxHeight;
      if (max_height > 100) max_height = max(kMinInteractiveDimension, content_height);

      return ConstrainedBox(
        child: Stack(
          children: [
            Positioned(
              child: Container(
                child: Material(
                  child: FakeInkWell(
                    child: theme_colours.provider(
                      builder: (context) => Padding(
                        child: SizedBox.expand(
                          child: Align(
                            child: MeasuredSize(
                              child: widget.builder(context, focused),
                              onChange: (size) {
                                setState(() {
                                  content_height = size.height + TOP_AND_BOTTOM_PADDING * 2;
                                });
                              },
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      theme: theme_colours.theme_name,
                      primary_colour: theme_colours.PRIMARY_COLOUR,
                      secondary_colour: focused ? theme_colours.ACCENT_COLOUR : theme_colours.PRIMARY_COLOUR,
                      background_colour: background_colour,
                    ),
                  ),
                  color: background_colour,
                  elevation: widget.add_shadow ? 8 : 0,
                ),
                color: background_colour,
              ),
              left: -DEFAULT_DROPDOWN_PADDING,
              right: -DEFAULT_DROPDOWN_PADDING,
              top: 0,
              bottom: 0,
            ),
          ],
          clipBehavior: Clip.none,
        ),
        constraints: BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: max_height),
      );
    });
  }
}

List<DropdownMenuItem<T>> simple_menu_items<T>(BuildContext context, Iterable<Tuple2<T, String>> options, {TextStyle? style, Color? focus_colour}) {
  return options
      .mapIndexed(
        (i, e) => DropdownMenuItem(
          value: e.element1,
          child: OptionEntryItemWrapper(
            value: e.element1,
            builder: (context, focused) => Text(e.element2, style: style),
            is_first: i == 0,
            is_last: i == options.length - 1,
            focus_colour_getter: focus_colour != null ? (_) => focus_colour : null,
          ),
        ),
      )
      .toList();
}

List<DropdownMenuItem<T>> simple_entry_menu_items<T>(BuildContext context, Iterable<MapEntry<T, String>> options, {TextStyle? style, Color? focus_colour}) {
  return simple_menu_items(context, options.map((e) => Tuple2(e.key, e.value.toString())), style: style, focus_colour: focus_colour);
}

List<DropdownMenuItem<T>> simpler_menu_items<T>(BuildContext context, Iterable<T> options, {TextStyle? style, Color? focus_colour}) {
  return simple_menu_items(context, options.map((e) => Tuple2(e, e.toString())), style: style, focus_colour: focus_colour);
}

List<Widget> Function(BuildContext context) simple_selected_menu_items<T>(Iterable<Tuple2<T, String>> options, {TextStyle? style}) {
  return (BuildContext context) => options.map((e) => Text(e.element2, style: style)).cast<Widget>().toList();
}

List<Widget> Function(BuildContext context) simple_entry_selected_menu_items<T>(Iterable<MapEntry<T, String>> options, {TextStyle? style}) {
  return simple_selected_menu_items(options.map((e) => Tuple2(e.key, e.value.toString())), style: style);
}

List<Widget> Function(BuildContext context) simpler_selected_menu_items<T>(Iterable<T> options, {TextStyle? style}) {
  return simple_selected_menu_items(options.map((e) => Tuple2(e, e.toString())), style: style);
}

class _IncrementButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback on_click;

  const _IncrementButton({required this.icon, required this.on_click});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: on_click,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.all(2),
    );
  }
}

class TextFieldIncrementButtons<T extends num> extends StatelessWidget {
  final T curr_value;
  final Function(T) on_changed;
  final T increment;

  const TextFieldIncrementButtons({required this.curr_value, required this.on_changed, T? increment}) : increment = increment ?? (T == int ? 1 : 1.0) as T;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _IncrementButton(icon: Icons.add, on_click: () => on_changed((curr_value + increment) as T)),
        _IncrementButton(icon: Icons.remove, on_click: () => on_changed((curr_value - increment) as T)),
      ],
    );
  }
}

class ToggleButtonRow<T> extends StatelessWidget {
  final String? label;
  final T curr_value;
  final List<T> all_values;
  final Widget Function(BuildContext context, T values) label_builder;
  final Function(T) on_change;

  const ToggleButtonRow({this.label, required this.curr_value, required this.all_values, required this.label_builder, required this.on_change});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    return Row(
      children: [
        if (label != null)
          Padding(
            child: Text("${label}:", style: theme_colours.DEFAULT_LIST_TILE_STYLE),
            padding: const EdgeInsets.only(right: 20),
          ),
        ToggleButtons(
          children: all_values
              .map(
                (value) => Padding(
                  child: label_builder(context, value),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              )
              .toList(),
          isSelected: all_values.map((value) => value == curr_value).toList(),
          onPressed: (i) => on_change(all_values[i]),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

class DropdownBooleanInput extends StatelessWidget {
  final bool value;
  final Function(bool) on_change;
  final TextStyle? style;
  final InputDecoration? decoration;
  final bool expanded;

  const DropdownBooleanInput({required this.value, required this.on_change, this.style, this.decoration, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    List<bool> options = [true, false];

    return DropdownButtonFormField<bool>(
      value: value,
      items: simpler_menu_items(context, options),
      selectedItemBuilder: simpler_selected_menu_items(options),
      onChanged: (bool? value) => on_change(value!),
      style: style,
      decoration: decoration,
      focusColor: Colors.transparent,
      isExpanded: expanded,
    );
  }
}
