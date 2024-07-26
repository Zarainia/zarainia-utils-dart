import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:measured_size/measured_size.dart';

import '../merge.dart';
import '../theme.dart';

class AppbarConfiguration {
  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;
  final double? title_spacing;
  final double? elevation;
  final bool imply_leading;

  const AppbarConfiguration({
    this.leading,
    this.title,
    this.actions = const [],
    this.title_spacing,
    this.elevation,
    this.imply_leading = true,
  });

  Widget? wrap_theme(BuildContext context, Widget? child) {
    return child == null
        ? null
        : ZarainiaTheme.on_appbar_theme_provider(
            context,
            (_) => child,
            bright_icons: true,
          );
  }

  Widget? _get_leading(BuildContext context, bool imply_leading) {
    ScaffoldState? scaffold = Scaffold.maybeOf(context);
    bool has_drawer = scaffold?.hasDrawer ?? false;
    final bool has_end_drawer = scaffold?.hasEndDrawer ?? false;
    ModalRoute<dynamic>? parent_route = ModalRoute.of(context);
    bool can_pop = parent_route?.canPop ?? false;
    bool use_close_button = parent_route is PageRoute<dynamic> && parent_route.fullscreenDialog;

    if (leading != null) return leading;
    if (imply_leading) {
      if (has_drawer) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: Scaffold.of(context).openDrawer,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else if ((!has_end_drawer && can_pop) || (parent_route?.impliesAppBarDismissal ?? false)) {
        return use_close_button ? const CloseButton() : const BackButton();
      }
    }
    return null;
  }

  AppBar build(
    BuildContext context, {
    double? toolbarHeight,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    double? elevation,
    double? scrolledUnderElevation,
    bool Function(ScrollNotification) notificationPredicate = defaultScrollNotificationPredicate,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    Color? backgroundColor,
    Color? foregroundColor,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double toolbarOpacity = 1.0,
    double bottomOpacity = 1.0,
    double? leadingWidth,
    TextStyle? toolbarTextStyle,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return AppBar(
      automaticallyImplyLeading: imply_leading,
      leading: wrap_theme(
        context,
        _get_leading(context, imply_leading),
      ),
      title: wrap_theme(context, title),
      actions: actions.map((action) => wrap_theme(context, action)!).toList(),
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: this.elevation ?? elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      notificationPredicate: notificationPredicate,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      titleSpacing: title_spacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      leadingWidth: leadingWidth,
      toolbarTextStyle: toolbarTextStyle,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
    );
  }

  AppbarConfiguration copy_with({
    Widget? leading = IGNORED_WIDGET_VALUE,
    Widget? title = IGNORED_WIDGET_VALUE,
    List<Widget>? actions,
    FutureOr<double?> title_spacing = IGNORED_DOUBLE_VALUE,
    FutureOr<double?> elevation = IGNORED_DOUBLE_VALUE,
  }) {
    return AppbarConfiguration(
      leading: ignore_widget_parameter(leading, this.leading),
      title: ignore_widget_parameter(title, this.title),
      actions: actions ?? this.actions,
      title_spacing: ignore_double_parameter(title_spacing, this.title_spacing),
      elevation: ignore_double_parameter(elevation, this.elevation),
    );
  }
}

class ExpandableAppbarPage extends StatefulWidget {
  final AppbarConfiguration? appbar;
  final Widget body;
  final Widget? floating_action_button;
  final Widget? bottom_bar;

  const ExpandableAppbarPage({
    super.key,
    this.appbar,
    required this.body,
    this.floating_action_button,
    this.bottom_bar,
  });

  @override
  _ExpandableAppbarPageState createState() => _ExpandableAppbarPageState();
}

class _ExpandableAppbarPageState extends State<ExpandableAppbarPage> {
  double appbar_height = 48;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appbar != null
          ? widget.appbar
              ?.copy_with(
                  title: widget.appbar!.title != null
                      ? MeasuredSize(
                          child: widget.appbar!.title!,
                          onChange: (size) {
                            setState(() {
                              appbar_height = size.height;
                            });
                          },
                        )
                      : null)
              .build(
                context,
                toolbarHeight: appbar_height,
              )
          : null,
      body: widget.body,
      floatingActionButton: widget.floating_action_button,
      bottomNavigationBar: widget.bottom_bar,
    );
  }
}
