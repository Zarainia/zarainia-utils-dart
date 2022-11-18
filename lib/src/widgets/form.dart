import 'dart:math';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart' hide Tuple2;
import 'package:measured_size/measured_size.dart';

import 'package:zarainia_utils/src/inkwell.dart';
import 'package:zarainia_utils/src/theme.dart';
import 'package:zarainia_utils/src/tuple.dart';

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
  ZarainiaTheme theme_colours;
  Widget Function(BuildContext, bool) builder;
  Function(T value)? on_focus;
  Color? Function(T value)? focus_colour_getter;
  bool is_first;
  bool is_last;

  OptionEntryItemWrapper({
    required this.value,
    required this.theme_colours,
    required this.builder,
    this.on_focus,
    this.focus_colour_getter,
    this.is_first = false,
    this.is_last = false,
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
    Color background_colour = focused ? (widget.focus_colour_getter?.call(widget.value) ?? widget.theme_colours.ACCENT_COLOUR) : widget.theme_colours.BASE_BACKGROUND_COLOUR;

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
                    child: widget.theme_colours.provider(
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
                      theme: widget.theme_colours.theme_name,
                      primary_colour: widget.theme_colours.PRIMARY_COLOUR,
                      secondary_colour: focused ? widget.theme_colours.ACCENT_COLOUR : widget.theme_colours.PRIMARY_COLOUR,
                      background_colour: background_colour,
                    ),
                  ),
                  color: background_colour,
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

List<DropdownMenuItem<T>> simple_menu_items<T>(BuildContext context, Iterable<Tuple2<T, String>> options) {
  return options
      .mapIndexed(
        (i, e) => DropdownMenuItem(
          value: e.element1,
          child: OptionEntryItemWrapper(
            value: e.element1,
            theme_colours: get_zarainia_theme(context),
            builder: (context, focused) => Text(e.element2),
            is_first: i == 0,
            is_last: i == options.length - 1,
          ),
        ),
      )
      .toList();
}

List<DropdownMenuItem<T>> simple_entry_menu_items<T>(BuildContext context, Iterable<MapEntry<T, String>> options) {
  return simple_menu_items(context, options.map((e) => Tuple2(e.key, e.value.toString())));
}

List<DropdownMenuItem<T>> simpler_menu_items<T>(BuildContext context, Iterable<T> options) {
  return simple_menu_items(context, options.map((e) => Tuple2(e, e.toString())));
}

List<Widget> Function(BuildContext context) simple_selected_menu_items<T>(Iterable<Tuple2<T, String>> options) {
  return (BuildContext context) => options.map((e) => Text(e.element2)).cast<Widget>().toList();
}

List<Widget> Function(BuildContext context) simple_entry_selected_menu_items<T>(Iterable<MapEntry<T, String>> options) {
  return simple_selected_menu_items(options.map((e) => Tuple2(e.key, e.value.toString())));
}

List<Widget> Function(BuildContext context) simpler_selected_menu_items<T>(Iterable<T> options) {
  return simple_selected_menu_items(options.map((e) => Tuple2(e, e.toString())));
}
