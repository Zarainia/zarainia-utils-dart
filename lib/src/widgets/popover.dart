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
        bodyBuilder: (context) => ZarainiaTheme.off_appbar_theme_provider(context, (context) => overlay_contents),
        backgroundColor: (get_original_theme(context, watch: false)?.original_theme.theme ?? get_themedata(context)).dialogBackgroundColor,
      );
    });
  }
}

class PopoverContentsWrapper extends StatelessWidget {
  final Widget header;
  final Widget body;

  const PopoverContentsWrapper({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    double device_width = MediaQuery.of(context).size.width;
    double max_width = min(device_width - 20, 420);

    return Container(
      child: Column(
        children: [
          header,
          Flexible(
            child: Material(
              child: MediaQuery.removePadding(
                context: context,
                child: body,
                removeTop: true,
              ),
              color: Colors.transparent,
            ),
          ),
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
  final String title;

  const PopoverHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Text(title, style: theme_colours.POPUP_HEADER_STYLE),
    );
  }
}
