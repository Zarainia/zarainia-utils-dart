import 'package:flutter/material.dart';

import 'package:context_menus/context_menus.dart';

import 'package:zarainia_utils/src/theme.dart';
import 'misc.dart';

class MenuEntryItemWrapper<T> extends StatefulWidget {
  T value;
  Widget Function(BuildContext, bool) builder;
  Function(T value)? on_focus;
  Color? Function(T value)? focus_colour_getter;

  MenuEntryItemWrapper({
    required this.value,
    required this.builder,
    this.on_focus,
    this.focus_colour_getter,
  });

  @override
  _MenuEntryItemWrapperState<T> createState() => _MenuEntryItemWrapperState<T>();
}

class _MenuEntryItemWrapperState<T> extends State<MenuEntryItemWrapper<T>> {
  bool focused = false;
  FocusNode? node;

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

    return theme_colours.provider(
      builder: (context) => widget.builder(context, focused),
      theme: theme_colours.theme_name,
      primary_colour: theme_colours.PRIMARY_COLOUR,
      secondary_colour: focused ? theme_colours.ACCENT_COLOUR : theme_colours.PRIMARY_COLOUR,
      background_colour: background_colour,
    );
  }
}

class MenuItemWithIcon<T> extends StatelessWidget {
  final T option;
  final IconData? icon;
  final String name;

  const MenuItemWithIcon({required this.option, this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return MenuEntryItemWrapper(
      value: option,
      builder: (context, _) => Row(
        children: [
          if (icon != null)
            Padding(
              child: Icon(icon),
              padding: const EdgeInsets.only(right: 10),
            ),
          Text(name),
        ],
      ),
    );
  }
}

class CustomPopupMenuButton<T> extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback open_menu) builder;
  final List<PopupMenuItem<T>> Function(BuildContext context) item_builder;
  final Function(T)? on_select;

  CustomPopupMenuButton({required this.builder, required this.item_builder, this.on_select});

  @override
  _CustomPopupMenuButtonState<T> createState() => _CustomPopupMenuButtonState();
}

class _CustomPopupMenuButtonState<T> extends State<CustomPopupMenuButton<T>> {
  GlobalKey menu_key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder(context, () => (menu_key.currentState as PopupMenuButtonState).showButtonMenu()),
        SizedBox(
          child: PopupMenuButton<T>(
            key: menu_key,
            itemBuilder: widget.item_builder,
            onSelected: widget.on_select,
            child: const EmptyContainer(),
          ),
          width: 0,
          height: 0,
        ),
      ],
    );
  }
}

class AppBarOverFlowMenuOption<T> {
  final T value;
  final IconData? icon;
  final String text;
  final Function(BuildContext context) on_click;

  const AppBarOverFlowMenuOption({required this.value, this.icon, required this.text, required this.on_click});
}

class AppBarOverflowMenuButton<T> extends StatelessWidget {
  final String? tooltip;
  final List<AppBarOverFlowMenuOption<T>> options;

  const AppBarOverflowMenuButton({required this.options, this.tooltip = "Show menu"});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ZarainiaTheme.off_appbar_theme_provider(
        context,
        (context) => CustomPopupMenuButton(
            builder: (context, open_menu) => ZarainiaTheme.on_appbar_theme_provider(
                  context,
                  (context) => IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: open_menu,
                    tooltip: tooltip,
                  ),
                  bright_icons: true,
                ),
            item_builder: (context) => options
                .map(
                  (option) => PopupMenuItem(
                    value: option.value,
                    child: MenuItemWithIcon(
                      option: option.value,
                      icon: option.icon,
                      name: option.text,
                    ),
                  ),
                )
                .toList(),
            on_select: (option) => options.firstWhere((o) => o.value == option).on_click(context)),
      ),
      alignment: Alignment.centerRight,
    );
  }
}

class MaterialContextMenu extends StatelessWidget {
  final List<Widget> children;

  const MaterialContextMenu({required this.children});

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return FocusScope(
      child: Material(
        color: theme_colours.theme.colorScheme.surface,
        child: Container(
          child: Column(
            children: children,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          constraints: const BoxConstraints(minWidth: 115),
        ),
        elevation: 6,
      ),
    );
  }
}

class MaterialContextMenuButton extends StatelessWidget {
  final Widget Function(BuildContext context, bool focused) label_builder;
  final VoidCallback on_click;

  const MaterialContextMenuButton({required this.label_builder, required this.on_click});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: MenuEntryItemWrapper(
        value: label_builder,
        builder: (context, focused) => label_builder(context, focused),
      ),
      onTap: () {
        on_click();
        context.contextMenuOverlay.hide();
      },
    );
  }
}

class SimpleContextMenuButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback on_click;

  SimpleContextMenuButton({required this.label, this.icon, required this.on_click});

  @override
  Widget build(BuildContext context) {
    return MaterialContextMenuButton(
      label_builder: (context, _) => Row(
        children: [
          if (icon != null) Icon(icon, size: 20),
          if (icon != null) const SizedBox(width: 10),
          Text(label),
        ],
      ),
      on_click: on_click,
    );
  }
}
