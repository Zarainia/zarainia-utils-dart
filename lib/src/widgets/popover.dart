import 'dart:math';

import 'package:flutter/material.dart';

import 'package:popover/popover.dart';

import 'package:zarainia_utils/src/theme.dart';

class PopoverButton extends StatelessWidget {
  Widget Function(BuildContext context, VoidCallback onclick) clickable_builder;
  Widget overlay_contents;

  PopoverButton({required this.clickable_builder, required this.overlay_contents});

  @override
  Widget build(BuildContext context) {
    return clickable_builder(context, () {
      showPopover(
        context: context,
        bodyBuilder: (context) => overlay_contents,
        backgroundColor: get_themedata(context).dialogBackgroundColor,
      );
    });
  }
}

class PopoverContentsWrapper extends StatelessWidget {
  Widget header;
  Widget body;

  PopoverContentsWrapper({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    double device_width = MediaQuery.of(context).size.width;
    double max_width = min(device_width - 20, 420);

    return Container(
      child: Column(
        children: [
          header,
          Flexible(child: Material(child: body, color: Colors.transparent)),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
      ),
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(maxWidth: max_width),
    );
  }
}

class PopoverHeader extends StatelessWidget {
  String title;

  PopoverHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text(title, style: theme_colours.POPUP_HEADER_STYLE),
    );
  }
}
