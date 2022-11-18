import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../theme.dart';

class PaddinglessSelectableText extends StatelessWidget {
  String text;
  TextStyle? style;
  TextAlign? textAlign;

  PaddinglessSelectableText(this.text, {this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
      cursorWidth: 0,
      textAlign: textAlign,
    );
  }
}

class NonTextScalingFlexibleSpaceBar extends StatefulWidget {
  /// Creates a flexible space bar.
  ///
  /// Most commonly used in the [AppBar.flexibleSpace] field.
  const NonTextScalingFlexibleSpaceBar({
    Key? key,
    this.title,
    this.background,
    this.centerTitle,
    this.titlePadding,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
  })  : assert(collapseMode != null),
        super(key: key);

  /// The primary contents of the flexible space bar when expanded.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Shown behind the [title] when expanded.
  ///
  /// Typically an [Image] widget with [Image.fit] set to [BoxFit.cover].
  final Widget? background;

  /// Whether the title should be centered.
  ///
  /// By default this property is true if the current target platform
  /// is [TargetPlatform.iOS] or [TargetPlatform.macOS], false otherwise.
  final bool? centerTitle;

  /// Collapse effect while scrolling.
  ///
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// Stretch effect while over-scrolling.
  ///
  /// Defaults to include [StretchMode.zoomBackground].
  final List<StretchMode> stretchModes;

  /// Defines how far the [title] is inset from either the widget's
  /// bottom-left or its center.
  ///
  /// Typically this property is used to adjust how far the title is
  /// is inset from the bottom-left and it is specified along with
  /// [centerTitle] false.
  ///
  /// By default the value of this property is
  /// `EdgeInsetsDirectional.only(start: 72, bottom: 16)` if the title is
  /// not centered, `EdgeInsetsDirectional.only(start: 0, bottom: 16)` otherwise.
  final EdgeInsetsGeometry? titlePadding;

  /// Wraps a widget that contains an [AppBar] to convey sizing information down
  /// to the [FlexibleSpaceBar].
  ///
  /// Used by [Scaffold] and [SliverAppBar].
  ///
  /// `toolbarOpacity` affects how transparent the text within the toolbar
  /// appears. `minExtent` sets the minimum height of the resulting
  /// [FlexibleSpaceBar] when fully collapsed. `maxExtent` sets the maximum
  /// height of the resulting [FlexibleSpaceBar] when fully expanded.
  /// `currentExtent` sets the scale of the [FlexibleSpaceBar.background] and
  /// [FlexibleSpaceBar.title] widgets of [FlexibleSpaceBar] upon
  /// initialization. `scrolledUnder` is true if the [FlexibleSpaceBar]
  /// overlaps the app's primary scrollable, false if it does not, and null
  /// if the caller has not determined as much.
  /// See also:
  ///
  ///  * [FlexibleSpaceBarSettings] which creates a settings object that can be
  ///    used to specify these settings to a [FlexibleSpaceBar].
  static Widget createSettings({
    double? toolbarOpacity,
    double? minExtent,
    double? maxExtent,
    bool? isScrolledUnder,
    required double currentExtent,
    required Widget child,
  }) {
    assert(currentExtent != null);
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity ?? 1.0,
      minExtent: minExtent ?? currentExtent,
      maxExtent: maxExtent ?? currentExtent,
      isScrolledUnder: isScrolledUnder,
      currentExtent: currentExtent,
      child: child,
    );
  }

  @override
  State<NonTextScalingFlexibleSpaceBar> createState() => _NonTextScalingFlexibleSpaceBarState();
}

class _NonTextScalingFlexibleSpaceBarState extends State<NonTextScalingFlexibleSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) return widget.centerTitle!;
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.bottomCenter;
    final TextDirection textDirection = Directionality.of(context);
    assert(textDirection != null);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final FlexibleSpaceBarSettings settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
        assert(
          settings != null,
          'A FlexibleSpaceBar must be wrapped in the widget returned by FlexibleSpaceBar.createSettings().',
        );

        final List<Widget> children = <Widget>[];

        final double deltaExtent = settings.maxExtent - settings.minExtent;

        // 0.0 -> Expanded
        // 1.0 -> Collapsed to toolbar
        final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

        // background
        if (widget.background != null) {
          final double fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
          const double fadeEnd = 1.0;
          assert(fadeStart <= fadeEnd);
          // If the min and max extent are the same, the app bar cannot collapse
          // and the content should be visible, so opacity = 1.
          final double opacity = settings.maxExtent == settings.minExtent ? 1.0 : 1.0 - Interval(fadeStart, fadeEnd).transform(t);
          double height = settings.maxExtent;

          // StretchMode.zoomBackground
          if (widget.stretchModes.contains(StretchMode.zoomBackground) && constraints.maxHeight > height) {
            height = constraints.maxHeight;
          }
          children.add(Positioned(
            top: _getCollapsePadding(t, settings),
            left: 0.0,
            right: 0.0,
            height: height,
            child: Opacity(
              // IOS is relying on this semantics node to correctly traverse
              // through the app bar when it is collapsed.
              alwaysIncludeSemantics: true,
              opacity: opacity,
              child: widget.background,
            ),
          ));

          // StretchMode.blurBackground
          if (widget.stretchModes.contains(StretchMode.blurBackground) && constraints.maxHeight > settings.maxExtent) {
            final double blurAmount = (constraints.maxHeight - settings.maxExtent) / 10;
            children.add(Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: blurAmount,
                  sigmaY: blurAmount,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ));
          }
        }

        // title
        if (widget.title != null) {
          final ThemeData theme = Theme.of(context);

          Widget? title;
          switch (theme.platform) {
            case TargetPlatform.iOS:
            case TargetPlatform.macOS:
              title = widget.title;
              break;
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.linux:
            case TargetPlatform.windows:
              title = Semantics(
                namesRoute: true,
                child: widget.title,
              );
              break;
          }

          // StretchMode.fadeTitle
          if (widget.stretchModes.contains(StretchMode.fadeTitle) && constraints.maxHeight > settings.maxExtent) {
            final double stretchOpacity = 1 - (((constraints.maxHeight - settings.maxExtent) / 100).clamp(0.0, 1.0));
            title = Opacity(
              opacity: stretchOpacity,
              child: title,
            );
          }

          final double opacity = settings.toolbarOpacity;
          if (opacity > 0.0) {
            TextStyle titleStyle = theme.primaryTextTheme.headline6!;
            titleStyle = titleStyle.copyWith(
              color: titleStyle.color!.withOpacity(opacity),
            );
            final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
            final EdgeInsetsGeometry padding = widget.titlePadding ??
                EdgeInsetsDirectional.only(
                  start: effectiveCenterTitle ? 0.0 : 72.0,
                  bottom: 16.0,
                );
            final double scaleValue = Tween<double>(begin: 1.5, end: 1.0).transform(t);
            final Matrix4 scaleTransform = Matrix4.identity()..scale(scaleValue, scaleValue, 1.0);
            final Alignment titleAlignment = _getTitleAlignment(effectiveCenterTitle);
            children.add(Container(
              padding: padding,
              child: Align(
                alignment: titleAlignment,
                child: DefaultTextStyle(
                  style: titleStyle,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return Container(
                        width: constraints.maxWidth / scaleValue,
                        alignment: titleAlignment,
                        child: title,
                      );
                    },
                  ),
                ),
              ),
            ));
          }
        }

        return ClipRect(child: Stack(children: children));
      },
    );
  }
}

class CircleButton extends StatelessWidget {
  Color? background_colour;
  Color? icon_colour;
  double icon_size;
  EdgeInsets padding;
  IconData icon;
  VoidCallback onclick;
  double elevation;
  FocusNode? focus_node;

  CircleButton({required this.icon, required this.onclick, this.background_colour, this.icon_colour, this.icon_size = 24, this.padding = const EdgeInsets.all(8), this.elevation = 0, this.focus_node});

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
      // style: ElevatedButton.styleFrom(
      //   shape: CircleBorder(),
      //   primary: background_colour,
      //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //   minimumSize: Size.zero,
      //   padding: EdgeInsets.zero,
      // ),
    );
  }
}

/// NOTE ref: https://github.com/flutter/flutter/issues/71687 & https://gist.github.com/matthew-carroll/65411529a5fafa1b527a25b7130187c6
/// Same as `IntrinsicWidth` except that when this widget is instructed
/// to `computeDryLayout()`, it doesn't invoke that on its child, instead
/// it computes the child's intrinsic width.
///
/// This widget is useful in situations where the `child` does not
/// support dry layout, e.g., `TextField` as of 01/02/2021.
class DryIntrinsicWidth extends SingleChildRenderObjectWidget {
  const DryIntrinsicWidth({Key? key, Widget? child}) : super(key: key, child: child);

  @override
  RenderDryIntrinsicWidth createRenderObject(BuildContext context) => RenderDryIntrinsicWidth();
}

class RenderDryIntrinsicWidth extends RenderIntrinsicWidth {
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final width = child!.computeMinIntrinsicWidth(constraints.maxHeight);
      final height = child!.computeMinIntrinsicHeight(width);
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }
}

/// NOTE ref: https://github.com/flutter/flutter/issues/71687 & https://gist.github.com/matthew-carroll/65411529a5fafa1b527a25b7130187c6
/// Same as `IntrinsicHeight` except that when this widget is instructed
/// to `computeDryLayout()`, it doesn't invoke that on its child, instead
/// it computes the child's intrinsic height.
///
/// This widget is useful in situations where the `child` does not
/// support dry layout, e.g., `TextField` as of 01/02/2021.
class DryIntrinsicHeight extends SingleChildRenderObjectWidget {
  const DryIntrinsicHeight({Key? key, Widget? child}) : super(key: key, child: child);

  @override
  RenderDryIntrinsicHeight createRenderObject(BuildContext context) => RenderDryIntrinsicHeight();
}

class RenderDryIntrinsicHeight extends RenderIntrinsicHeight {
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final height = child!.computeMinIntrinsicHeight(constraints.maxWidth);
      final width = child!.computeMinIntrinsicWidth(height);
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }
}

/// [SliverPinnedHeader] keeps its child pinned to the leading edge of the viewport.
class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}

class RenderSliverPinnedHeader extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    BoxConstraints child_constraints = constraints.asBoxConstraints();
    double remaining_space = constraints.remainingPaintExtent - constraints.overlap;
    if (constraints.overlap > 0) child_constraints = child_constraints.copyWith(maxHeight: remaining_space);
    child!.layout(child_constraints, parentUsesSize: true);

    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final paintedChildExtent = math.min(
      childExtent,
      constraints.remainingPaintExtent - constraints.overlap,
    );
    geometry = SliverGeometry(
      paintExtent: paintedChildExtent,
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: childExtent,
      paintOrigin: constraints.overlap,
      scrollExtent: childExtent,
      layoutExtent: math.max(0.0, paintedChildExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedChildExtent < childExtent,
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return 0;
  }
}

class EmptyContainer extends StatelessWidget {
  const EmptyContainer();

  @override
  Widget build(BuildContext context) {
    return Container(width: 0, height: 0);
  }
}

class ListSubheader extends StatelessWidget {
  bool first;
  String text;
  bool indent_to_icon;

  ListSubheader({required this.text, this.indent_to_icon = false, this.first = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent_to_icon ? 72 : 16, top: first ? 6 : 16, bottom: 16, right: 16),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: get_zarainia_theme(context).DIM_TEXT_COLOUR),
      ),
    );
  }
}

class ListSubheaderTile extends StatelessWidget {
  String text;
  Color? colour;

  ListSubheaderTile({required this.text, this.colour});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return ZarainiaThemeProvider(
      theme: theme_colours.theme_name,
      primary_colour: theme_colours.PRIMARY_COLOUR,
      secondary_colour: theme_colours.ACCENT_COLOUR,
      background_colour: colour,
      builder: (context) {
        return Column(
          children: [
            Container(
              child: Text(
                text,
                style: TextStyle(fontSize: 14),
              ),
              color: colour,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            const Divider()
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        );
      },
    );
  }
}

class LinkText extends StatelessWidget {
  String text;
  VoidCallback onclick;

  LinkText({required this.text, required this.onclick});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return InkWell(child: Text(text, style: theme_colours.LINK_STYLE), onTap: onclick);
  }
}

class LinkOnTop extends StatelessWidget {
  Widget child;
  String url;

  LinkOnTop({required this.child, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launcher.launch(url),
            ),
          ),
        ),
      ],
    );
  }
}

class DefaultFocusCubit extends Cubit<FocusNode?> {
  BuildContext context;
  FocusNode focus_node;
  DefaultFocusCubit? parent_cubit;
  Set<DefaultFocusCubit> child_cubits = {};

  DefaultFocusCubit(this.context, this.focus_node) : super(null) {
    try {
      parent_cubit = BlocProvider.of<DefaultFocusCubit>(context, listen: false);
      parent_cubit!.child_cubits.add(this);
    } catch (_) {}
  }

  void default_focus(FocusScopeNode scope) {
    if (child_cubits.isEmpty) {
      if (scope.focusedChild == null) focus_node.requestFocus();
    } else {
      log("tried to default_focus when not the bottommost default focus");
    }
    emit(scope.focusedChild);
  }

  @override
  Future<void> close() {
    parent_cubit?.child_cubits.remove(this);
    return super.close();
  }
}

class DefaultFocus extends StatefulWidget {
  Widget child;

  DefaultFocus({required this.child});

  @override
  _DefaultFocusState createState() => _DefaultFocusState();
}

class _DefaultFocusState extends State<DefaultFocus> {
  late FocusNode node;
  late DefaultFocusCubit focus_cubit;
  FocusScopeNode? scope;

  void focus_listener() {
    if (mounted) focus_cubit.default_focus(scope!);
  }

  @override
  void initState() {
    super.initState();
    node = FocusNode();
    focus_cubit = DefaultFocusCubit(context, node);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope?.removeListener(focus_listener);
    scope = FocusScope.of(context);
    scope?.addListener(focus_listener);
  }

  @override
  void dispose() {
    scope?.removeListener(focus_listener);
    node.dispose();
    focus_cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DefaultFocusCubit>(
      create: (_) => focus_cubit,
      child: Focus(focusNode: node, child: widget.child),
    );
  }
}

class HideKeepSpace extends StatelessWidget {
  Widget child;

  HideKeepSpace({required this.child});

  @override
  Widget build(BuildContext context) {
    return Visibility(child: child, visible: false, maintainSize: true, maintainAnimation: true, maintainState: true);
  }
}

class IconAndText extends StatelessWidget {
  IconData? icon;
  Widget Function(Color? icon_colour, double icon_size)? icon_builder;
  String? text;
  TextStyle? style;
  Color? icon_colour;
  double? icon_size;
  bool top_padding;
  MainAxisAlignment alignment;

  IconAndText({this.icon, this.icon_builder, required this.text, this.icon_colour, this.style, this.icon_size, this.top_padding = true, this.alignment = MainAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);
    if (style == null) style = theme_colours.PROPERTY_VALUE_STYLE;
    Color? icon_colour = this.icon_colour ?? theme_colours.ICON_COLOUR;
    double font_size = style!.fontSize ?? theme_colours.PROPERTY_VALUE_STYLE.fontSize!;
    double icon_size = this.icon_size ?? font_size;
    if (this.icon?.fontFamily?.toLowerCase().contains("fontawesome") ?? false) icon_size = icon_size * 0.8;

    Widget? icon;
    if (this.icon != null || icon_builder != null)
      icon = Padding(
        child: icon_builder?.call(icon_colour, icon_size) ?? Icon(this.icon, color: icon_colour, size: icon_size),
        padding: EdgeInsets.only(right: style!.fontSize != null ? style!.fontSize! / 2 : 10, top: top_padding ? (style!.fontSize != null ? (style!.fontSize! / 7) : 2) : 0),
      );

    return Row(
      children: [
        if (icon != null) icon,
        Text(text?.toString() ?? '', style: style),
        if (icon != null && alignment == MainAxisAlignment.center) HideKeepSpace(child: icon),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: alignment,
    );
  }
}

class SimplerChip extends StatelessWidget {
  Widget label;
  Widget? avatar;
  VoidCallback? onclick;
  VoidCallback? delete_func;

  SimplerChip({
    required this.label,
    this.avatar,
    this.onclick,
    this.delete_func,
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    Widget contents = ConstrainedBox(
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            child: label,
            margin: EdgeInsets.only(left: avatar == null ? 10 : 36, right: delete_func == null ? 10 : 30, top: 4, bottom: 4),
          ),
          if (avatar != null)
            Positioned(
              child: Container(
                child: avatar,
                margin: EdgeInsets.symmetric(vertical: 3),
                alignment: Alignment.center,
                height: 29,
                width: 21,
              ),
              left: 6,
              top: 0,
              bottom: 0,
              width: 21,
            ),
          if (delete_func != null)
            Positioned(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: delete_func!,
                iconSize: 18,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              right: 6,
              width: 21,
              top: 0,
              bottom: 0,
            )
        ],
      ),
      constraints: BoxConstraints(minHeight: 24),
    );

    if (onclick != null) contents = InkWell(child: contents, onTap: onclick);

    return Material(
      child: contents,
      color: theme_colours.BASE_BACKGROUND_COLOUR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      elevation: 8,
      clipBehavior: Clip.hardEdge,
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final double stroke_width;
  final double max_height;
  final double max_width;

  const LoadingIndicator({this.stroke_width = 20, this.max_height = 200, this.max_width = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: AspectRatio(
          child: CircularProgressIndicator(strokeWidth: stroke_width),
          aspectRatio: 1,
        ),
        constraints: BoxConstraints(maxHeight: max_height, maxWidth: max_width),
      ),
    );
  }
}

class ClickToCopy extends StatelessWidget {
  String text;
  Widget child;

  ClickToCopy({required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: child,
      onTap: () => Clipboard.setData(ClipboardData(text: text)),
    );
  }
}
