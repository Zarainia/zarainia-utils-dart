import 'package:flutter/material.dart';

import './misc.dart';

class CircleButton extends StatelessWidget {
  Color? background_colour;
  Color? icon_colour;
  double icon_size;
  EdgeInsets padding;
  IconData icon;
  VoidCallback onclick;
  double elevation;
  FocusNode? focus_node;

  CircleButton(
      {required this.icon, required this.onclick, this.background_colour, this.icon_colour, this.icon_size = 24, this.padding = const EdgeInsets.all(8), this.elevation = 0, this.focus_node});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Padding(
          child: Icon(icon, size: icon_size, color: icon_colour),
          padding: padding,
        ),
        onTap: onclick,
        focusNode: focus_node,
        customBorder: const CircleBorder(),
      ),
      elevation: elevation,
      shape: const CircleBorder(),
      color: background_colour,
    );
  }
}

class PaddingLessIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? on_click;
  final Color? colour;
  final double? icon_size;
  final String? tooltip;
  final EdgeInsets padding;

  const PaddingLessIconButton({
    required this.icon,
    this.on_click,
    this.colour,
    this.icon_size,
    this.tooltip,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: on_click,
      color: colour,
      iconSize: icon_size,
      visualDensity: MINIMUM_VISUAL_DENSITY,
      constraints: const BoxConstraints(),
      padding: padding,
      tooltip: tooltip,
    );
  }
}

class PaddedOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? on_click;

  const PaddedOutlinedButton({required this.child, this.on_click});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Padding(
        child: child,
        padding: const EdgeInsets.symmetric(vertical: 7),
      ),
      onPressed: on_click,
    );
  }
}

class PaddedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? on_click;

  const PaddedElevatedButton({required this.child, this.on_click});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Padding(
        child: child,
        padding: const EdgeInsets.symmetric(vertical: 7),
      ),
      onPressed: on_click,
    );
  }
}
