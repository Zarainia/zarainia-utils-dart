import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import 'package:zarainia_utils/src/utils.dart';

class DoubleInputConvertor {
  final int decimals;

  const DoubleInputConvertor([this.decimals = 2]);

  String call(double? value) => value?.toStringAsFixed(decimals) ?? '';
}

class StringOutputConvertor {
  const StringOutputConvertor();

  String call(String text) => text;
}

class DoubleOutputConvertor {
  final double default_value;

  const DoubleOutputConvertor({required this.default_value});

  double call(String text) => text.isEmpty ? default_value : double.parse(text);
}

class NullableOutputConvertor {
  const NullableOutputConvertor();

  String? call(String text) => text.isEmpty ? null : text;
}

class NullableDoubleOutputConvertor {
  const NullableDoubleOutputConvertor();

  double? call(String text) => text.isEmpty ? null : double.parse(text);
}

class StatedTextField<T> extends StatefulWidget {
  T initial_text;
  Function(T)? on_changed;
  InputDecoration decoration;
  TextAlign text_align;
  InputValidationFunction? validator;
  Function(String?)? on_error;
  bool multiline;
  List<TextInputFormatter> input_formatters;
  String Function(T) input_convertor;
  T Function(String) output_convertor;
  bool Function(T, String)? ignore_update;
  TextInputType? input_type;
  bool expanded;
  TextStyle? style;
  bool clearable;
  Color? icon_colour;
  double cursor_width;

  String converted_text;

  static String default_input_convertor(Object? value) => value?.toString() ?? '';

  StatedTextField({
    required this.initial_text,
    this.on_changed,
    this.decoration = const InputDecoration(),
    this.text_align = TextAlign.start,
    this.validator,
    this.on_error,
    this.multiline = false,
    this.input_formatters = const [],
    this.input_convertor = default_input_convertor,
    this.ignore_update,
    T Function(String)? output_convertor,
    this.input_type,
    this.expanded = true,
    this.style,
    this.clearable = false,
    this.icon_colour,
    this.cursor_width = 2.0,
  })  : converted_text = input_convertor(initial_text),
        output_convertor = (output_convertor == null && '' is T) ? (null is T ? ((value) => (value.isEmpty ? null : value) as T) : ((value) => value as T)) : output_convertor! {
    if (multiline && input_type == null) input_type = TextInputType.multiline;
  }

  @override
  _StatedTextField<T> createState() => _StatedTextField();
}

class _StatedTextField<T> extends State<StatedTextField<T>> {
  late TextEditingController controller;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.converted_text);
    error = widget.validator?.call(widget.converted_text);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.on_error?.call(error));
  }

  @override
  void didUpdateWidget(covariant StatedTextField<T> oldWidget) {
    try {
      if (widget.converted_text != oldWidget.converted_text &&
          widget.converted_text != widget.input_convertor(widget.output_convertor(controller.text)) &&
          (widget.ignore_update == null || !widget.ignore_update!(widget.initial_text, controller.text))) {
        controller.text = widget.converted_text;
        setState(() {
          error = widget.validator?.call(widget.converted_text);
        });
        widget.on_error?.call(error);
      }
    } catch (e) {
      log("Error converting text", error: e);
    }
    super.didUpdateWidget(oldWidget);
  }

  void on_changed(String text) {
    setState(() {
      error = widget.validator?.call(text);
    });
    widget.on_error?.call(error);
    if (error == null) widget.on_changed?.call(widget.output_convertor(text));
  }

  @override
  Widget build(BuildContext context) {
    Widget textfield = TextField(
      controller: controller,
      decoration: widget.decoration.copyWith(
        errorText: toBeginningOfSentenceCase(error),
        suffixIcon: widget.clearable
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  controller.clear();
                  on_changed('');
                },
                color: widget.icon_colour,
              )
            : null,
      ),
      onChanged: on_changed,
      textAlign: widget.text_align,
      textAlignVertical: widget.clearable ? TextAlignVertical.center : TextAlignVertical.top,
      inputFormatters: widget.input_formatters,
      keyboardType: widget.input_type,
      maxLines: widget.multiline ? null : 1,
      style: widget.style,
      cursorWidth: widget.cursor_width,
    );
    if (!widget.expanded)
      return IntrinsicWidth(child: textfield);
    else
      return textfield;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
