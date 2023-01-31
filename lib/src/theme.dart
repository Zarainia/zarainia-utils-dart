import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'colour.dart';

class ZarainiaTheme {
  Widget Function({required Widget Function(BuildContext) builder, required String theme, Color? background_colour, required Color? primary_colour, required Color? secondary_colour}) provider =
      ZarainiaThemeProvider.new;

  Color PRIMARY_COLOUR = Colors.black;
  Color WEAK_PRIMARY_COLOUR = Colors.black;
  late Brightness PRIMARY_COLOUR_BRIGHTNESS;
  Color PRIMARY_CONTRAST_COLOUR = Colors.black;

  Color ACCENT_COLOUR = Colors.black;
  Color WEAK_ACCENT_COLOUR = Colors.black;
  late Brightness ACCENT_COLOUR_BRIGHTNESS;
  Color ACCENT_CONTRAST_COLOUR = Colors.black;

  Color ADDITIONAL_COLOUR = Colors.black;

  Color ICON_ON_ACCENT_COLOUR = Colors.black;
  Color DIM_ICON_ON_ACCENT_COLOUR = Colors.black;
  Color ICON_COLOUR = Colors.black;
  Color DARK_ICON_COLOUR = Colors.black;
  Color LIGHT_ICON_COLOUR = Colors.black;
  Color ICON_ON_PRIMARY_COLOUR = Colors.black;
  Color DIM_ICON_ON_PRIMARY_COLOUR = Colors.black;
  Color DIM_ICON_COLOUR = Colors.black;
  Color ACCENT_ICON_COLOUR_LIGHT = Colors.black;
  Color ACCENT_ICON_COLOUR_DARK = Colors.black;
  Color ACCENT_ICON_COLOUR = Colors.black;
  Color PRIMARY_ICON_COLOUR_LIGHT = Colors.black;
  Color PRIMARY_ICON_COLOUR_DARK = Colors.black;
  Color PRIMARY_ICON_COLOUR = Colors.black;

  Color BASE_BACKGROUND_COLOUR = Colors.black;
  Color BASE_THEME_BACKGROUND = Colors.black;
  Color DIM_BACKGROUND = Colors.black;
  Color LESS_DIM_BACKGROUND = Colors.black;
  Color ON_PRIMARY_DIM_BACKGROUND = Colors.black;
  Color PRIMARY_TINTED_BACKGROUND = Colors.black;

  Color DIM_SHADOWED_BACKGROUND_COLOUR = Colors.black;
  Color TEXT_ON_SHADOWED_BACKGROUND_COLOUR = Colors.black;
  Color ICON_ON_SHADOWED_BACKGROUND_COLOUR = Colors.black;
  Color LIGHT_SHADOWED_BACKGROUND_COLOUR = Colors.black;
  Color DIM_LIGHT_SHADOWED_BACKGROUND_COLOUR = Colors.black;
  Color GREY_SHADOWED_BACKGROUND_COLOUR = Colors.black;

  Color DIVIDER_COLOUR = Colors.black;
  Color ON_PRIMARY_DIVIDER_COLOUR = Colors.black;
  Color BORDER_COLOUR = Colors.black;
  Color DOUBLE_STRENGTH_BORDER_COLOUR = Colors.black;
  Color DIM_BORDER_COLOUR = Colors.black;
  Color ON_PRIMARY_BORDER_COLOUR = Colors.black;
  Color ON_PRIMARY_DIM_BORDER_COLOUR = Colors.black;
  Color BRIGHTER_BORDER_COLOUR = Colors.black;
  Color ERROR_BORDER_COLOUR = Colors.black;
  Color BRIGHTER_ERROR_BORDER_COLOUR = Colors.black;

  Color BACKGROUND_CONTRAST_COLOUR = Colors.black;
  Color BASE_TEXT_COLOUR = Colors.black;
  Color DIM_TEXT_COLOUR = Colors.black;

  Color ACCENT_TEXT_COLOUR_LIGHT = Colors.black;
  Color ACCENT_TEXT_COLOUR_DARK = Colors.black;
  Color ACCENT_TEXT_COLOUR = Colors.black;
  Color TEXT_ON_ACCENT_COLOUR = Colors.black;

  Color PRIMARY_TEXT_COLOUR_LIGHT = Colors.black;
  Color PRIMARY_TEXT_COLOUR_DARK = Colors.black;
  Color PRIMARY_TEXT_COLOUR = Colors.black;
  Color TEXT_ON_PRIMARY_COLOUR = Colors.black;
  Color DIM_TEXT_ON_PRIMARY_COLOUR = Colors.black;

  Color ERROR_TEXT_COLOUR = Colors.black;

  Color SUBMIT_ICON_COLOUR = Colors.black;
  Color CANCEL_ICON_COLOUR = Colors.black;
  Color ADD_BUTTON_COLOUR = Colors.black;

  TextStyle NORMAL_STYLE = const TextStyle();
  TextStyle TITLE_STYLE = const TextStyle();
  TextStyle SUBTITLE_STYLE = const TextStyle();
  TextStyle PROPERTY_LABEL_STYLE = const TextStyle();
  TextStyle PROPERTY_VALUE_STYLE = const TextStyle();
  TextStyle SMALL_HEADER_STYLE = const TextStyle();
  TextStyle SMALLER_HEADER_STYLE = const TextStyle();
  Color LINK_TEXT_COLOUR = Colors.black;
  TextStyle LINK_STYLE = const TextStyle();

  TextStyle POPUP_HEADER_STYLE = const TextStyle();
  TextStyle SEARCH_HIGHLIGHT_STYLE = const TextStyle();
  TextStyle SEARCH_SELECTED_HIGHLIGHT_STYLE = const TextStyle();
  TextStyle STRIKETHROUGH_STYLE = const TextStyle();
  TextStyle LIST_STRIKETHROUGH_STYLE = const TextStyle();
  TextStyle HEADER_STRIKETHROUGH_STYLE = const TextStyle();
  TextStyle CHIP_STRIKETHROUGH_STYLE = const TextStyle();

  TextStyle DEFAULT_INPUT_HINT_STYLE = const TextStyle();
  MaterialStateTextStyle DEFAULT_INPUT_LABEL_STYLE = MaterialStateTextStyle.resolveWith((states) => const TextStyle());
  MaterialStateTextStyle DEFAULT_INPUT_FLOATING_LABEL_STYLE = MaterialStateTextStyle.resolveWith((states) => const TextStyle());

  Color SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.black, null, 0.7)!;
  Color SHADOWED_BACKGROUND_TEXT_COLOUR = Colors.white;
  Color CLOSE_ICON_BUTTON_COLOUR = Color.lerp(Colors.black, null, 0.7)!;

  double MARKDOWN_LIST_INITIAL_INDENT = 30;
  double MARKDOWN_LIST_INDENT_FACTOR = 40;
  double MARKDOWN_LIST_POST_INDENT = 10;
  double MARKDOWN_LIST_WIDGET_HEIGHT = 25;
  double MARKDOWN_LIST_BOTTOM_PADDING = 10;
  double MARKDOWN_NUMBER_MAX_HEIGHT = 40;
  double MARKDOWN_CHECKBOX_SIZE_FACTOR = 0.75;

  String EMOJI_FONT = "NotoEmoji";
  String MONOSPACE_FONT = "DejaVuSansMono";
  String DELNIIT_FONT = "TimesNewDelniit";

  late Gradient ATTACHMENT_BACKGROUND_GRADIENT;

  Map<String, TextStyle> MARKDOWN_HIGHLIGHTING_THEME = {};

  List<Shadow> ICON_SHADOW = [];
  Color SHADOW_COLOUR = Colors.black;

  List<Color> CHART_PALETTE = [];

  String theme_name;
  late ThemeData theme;
  bool is_dark;
  TargetPlatform platform;
  MaterialLocalizations localizations;
  late Typography typography;
  late TextTheme text_theme;
  late SystemUiOverlayStyle overlay_style;

  TextTheme get_localized_script_category() {
    switch (localizations.scriptCategory) {
      case ScriptCategory.dense:
        return typography.dense;
      case ScriptCategory.tall:
        return typography.tall;
      default:
        return typography.englishLike;
    }
  }

  ZarainiaTheme({
    required this.theme_name,
    Color? background_colour,
    Color? primary_colour,
    Color? secondary_colour,
    required this.platform,
    required this.localizations,
    required Color default_primary_colour,
    required Color default_accent_colour,
    required Color default_additional_colour,
  }) : is_dark = background_colour != null ? background_colour.brightness == Brightness.dark : theme_name == "dark" {
    ThemeData default_theme = is_dark ? ThemeData.dark() : ThemeData.light();
    double accent_contrast_ratio = is_dark ? 4 : 3;

    BASE_THEME_BACKGROUND = default_theme.canvasColor;
    BASE_BACKGROUND_COLOUR = background_colour ?? BASE_THEME_BACKGROUND;

    ADDITIONAL_COLOUR = default_additional_colour;

    PRIMARY_COLOUR = primary_colour ?? default_primary_colour;
    WEAK_PRIMARY_COLOUR = weaken_colour(PRIMARY_COLOUR);
    PRIMARY_COLOUR_BRIGHTNESS = get_colour_brightness(PRIMARY_COLOUR);
    PRIMARY_CONTRAST_COLOUR = get_constrasting_colour(PRIMARY_COLOUR);

    ACCENT_COLOUR = secondary_colour ?? default_accent_colour;
    WEAK_ACCENT_COLOUR = weaken_colour(ACCENT_COLOUR);
    ACCENT_COLOUR_BRIGHTNESS = get_colour_brightness(ACCENT_COLOUR);
    ACCENT_CONTRAST_COLOUR = get_constrasting_colour(ACCENT_COLOUR);

    LIGHT_ICON_COLOUR = Color.lerp(Colors.white, null, 0.4)!;
    DARK_ICON_COLOUR = Color.lerp(Colors.black, null, 0.5)!;
    ICON_COLOUR = is_dark ? LIGHT_ICON_COLOUR : DARK_ICON_COLOUR;
    DIM_ICON_COLOUR = is_dark ? Color.lerp(Colors.white, null, 0.7)! : Color.lerp(Colors.black, null, 0.8)!;
    ICON_ON_ACCENT_COLOUR = make_icon_colour(ACCENT_COLOUR);
    DIM_ICON_ON_ACCENT_COLOUR = make_icon_colour(ACCENT_COLOUR, dim: true);
    ICON_ON_PRIMARY_COLOUR = make_icon_colour(PRIMARY_COLOUR);
    DIM_ICON_ON_PRIMARY_COLOUR = make_icon_colour(PRIMARY_COLOUR, dim: true);
    ACCENT_ICON_COLOUR_LIGHT = make_text_colour(ACCENT_COLOUR, Brightness.light);
    ACCENT_ICON_COLOUR_DARK = make_text_colour(ACCENT_COLOUR, Brightness.dark);
    ACCENT_ICON_COLOUR = is_dark ? ACCENT_ICON_COLOUR_LIGHT : ACCENT_ICON_COLOUR_DARK;
    if (secondary_colour != null && colour_contrast_ratio(ACCENT_COLOUR, BASE_BACKGROUND_COLOUR) > accent_contrast_ratio) ACCENT_ICON_COLOUR = ACCENT_COLOUR;
    PRIMARY_ICON_COLOUR_LIGHT = make_text_colour(PRIMARY_COLOUR, Brightness.light);
    PRIMARY_ICON_COLOUR_DARK = make_text_colour(PRIMARY_COLOUR, Brightness.dark);
    PRIMARY_ICON_COLOUR = is_dark ? PRIMARY_ICON_COLOUR_LIGHT : PRIMARY_ICON_COLOUR_DARK;
    if (primary_colour != null && colour_contrast_ratio(PRIMARY_COLOUR, BASE_BACKGROUND_COLOUR) > accent_contrast_ratio) PRIMARY_ICON_COLOUR = PRIMARY_COLOUR;

    DIM_BACKGROUND = is_dark ? Color.lerp(Colors.white, null, 0.9)! : Color.lerp(Colors.black, null, 0.95)!;
    LESS_DIM_BACKGROUND = is_dark ? Color.lerp(Colors.white, null, 0.8)! : Color.lerp(Colors.black, null, 0.8)!;
    ON_PRIMARY_DIM_BACKGROUND = Color.lerp(PRIMARY_CONTRAST_COLOUR, null, 0.8)!;

    SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.black, null, 0.7)!;
    DIM_SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.black, null, 0.9)!;
    TEXT_ON_SHADOWED_BACKGROUND_COLOUR = Colors.white;
    ICON_ON_SHADOWED_BACKGROUND_COLOUR = make_icon_colour(Colors.black);
    LIGHT_SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.white, null, 0.7)!;
    DIM_LIGHT_SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.white, null, 0.7)!;
    GREY_SHADOWED_BACKGROUND_COLOUR = Color.lerp(Colors.grey, null, 0.5)!;
    PRIMARY_TINTED_BACKGROUND = Color.alphaBlend(DIM_BACKGROUND, BASE_BACKGROUND_COLOUR);
    if (background_colour != null) PRIMARY_TINTED_BACKGROUND = Color.lerp(BASE_BACKGROUND_COLOUR, BASE_THEME_BACKGROUND, 0.5)!;

    BACKGROUND_CONTRAST_COLOUR = get_constrasting_colour(BASE_BACKGROUND_COLOUR);
    BASE_TEXT_COLOUR = default_theme.textTheme.bodyText1!.color!;
    DIM_TEXT_COLOUR = dim_text_colour(BASE_TEXT_COLOUR);
    ACCENT_TEXT_COLOUR_LIGHT = make_text_colour(ACCENT_COLOUR, Brightness.light);
    ACCENT_TEXT_COLOUR_DARK = make_text_colour(ACCENT_COLOUR, Brightness.dark);
    ACCENT_TEXT_COLOUR = is_dark ? ACCENT_TEXT_COLOUR_LIGHT : ACCENT_TEXT_COLOUR_DARK;
    if (secondary_colour != null && colour_contrast_ratio(ACCENT_COLOUR, BASE_BACKGROUND_COLOUR) > accent_contrast_ratio) ACCENT_TEXT_COLOUR = ACCENT_COLOUR;
    TEXT_ON_ACCENT_COLOUR = ACCENT_CONTRAST_COLOUR;

    DIVIDER_COLOUR = is_dark ? Color.lerp(Colors.white, null, 0.5)! : Color.lerp(Colors.black, null, 0.5)!;
    ON_PRIMARY_DIVIDER_COLOUR = Color.lerp(PRIMARY_CONTRAST_COLOUR, null, 0.5)!;
    BORDER_COLOUR = DIVIDER_COLOUR;
    DOUBLE_STRENGTH_BORDER_COLOUR = Color.lerp(BASE_TEXT_COLOUR, null, 0.7)!;
    BRIGHTER_BORDER_COLOUR = Color.lerp(BASE_TEXT_COLOUR, null, 0.5)!;
    DIM_BORDER_COLOUR = Color.lerp(BASE_TEXT_COLOUR, null, 0.8)!;
    ON_PRIMARY_BORDER_COLOUR = ON_PRIMARY_DIVIDER_COLOUR;
    ON_PRIMARY_DIM_BORDER_COLOUR = Color.lerp(PRIMARY_CONTRAST_COLOUR, null, 0.7)!;
    ERROR_BORDER_COLOUR = Colors.red;
    if (colour_distance(ERROR_BORDER_COLOUR, BASE_BACKGROUND_COLOUR) < 250 && colour_distance(Colors.yellow, BASE_BACKGROUND_COLOUR) > 100) ERROR_BORDER_COLOUR = Colors.yellow;
    BRIGHTER_ERROR_BORDER_COLOUR = Color.lerp(ERROR_BORDER_COLOUR, BASE_TEXT_COLOUR, 0.3)!;
    ERROR_BORDER_COLOUR = Color.lerp(ERROR_BORDER_COLOUR, null, 0.3)!;

    PRIMARY_TEXT_COLOUR_LIGHT = make_text_colour(PRIMARY_COLOUR, Brightness.light);
    PRIMARY_TEXT_COLOUR_DARK = make_text_colour(PRIMARY_COLOUR, Brightness.dark);
    PRIMARY_TEXT_COLOUR = is_dark ? PRIMARY_TEXT_COLOUR_LIGHT : PRIMARY_TEXT_COLOUR_DARK;
    if (primary_colour != null && colour_contrast_ratio(PRIMARY_COLOUR, BASE_BACKGROUND_COLOUR) > accent_contrast_ratio) PRIMARY_TEXT_COLOUR = PRIMARY_COLOUR;
    TEXT_ON_PRIMARY_COLOUR = PRIMARY_CONTRAST_COLOUR;
    DIM_TEXT_ON_PRIMARY_COLOUR = dim_text_colour(TEXT_ON_PRIMARY_COLOUR);

    // if (colour_distance(ERROR_TEXT_COLOUR, BASE_BACKGROUND_COLOUR) < 150) ERROR_TEXT_COLOUR = Color.lerp(ERROR_TEXT_COLOUR, BASE_TEXT_COLOUR, 0.5)!;
    ERROR_TEXT_COLOUR = BRIGHTER_ERROR_BORDER_COLOUR;

    CLOSE_ICON_BUTTON_COLOUR = SHADOWED_BACKGROUND_COLOUR;

    SUBMIT_ICON_COLOUR = Colors.green;
    if (colour_distance(SUBMIT_ICON_COLOUR, BASE_BACKGROUND_COLOUR) < 100) SUBMIT_ICON_COLOUR = ICON_COLOUR;
    CANCEL_ICON_COLOUR = Colors.red;
    if (colour_distance(CANCEL_ICON_COLOUR, BASE_BACKGROUND_COLOUR) < 100) CANCEL_ICON_COLOUR = ICON_COLOUR;
    ADD_BUTTON_COLOUR = ACCENT_COLOUR;

    SHADOW_COLOUR = is_dark ? Color.lerp(Colors.white, null, 0.9)! : Color.lerp(Colors.black, null, 0.7)!;
    ICON_SHADOW = [BoxShadow(blurRadius: 2, color: SHADOW_COLOUR)];

    ATTACHMENT_BACKGROUND_GRADIENT = RadialGradient(center: Alignment(-1, -1), radius: 1.5, colors: [Colors.black, Colors.grey, Colors.black]);

    typography = Typography.material2021(platform: platform);
    TextTheme locale_theme = get_localized_script_category();
    text_theme = locale_theme.merge(is_dark ? typography.white : typography.black);
    text_theme = text_theme.copyWith(bodyText1: text_theme.bodyText1!.copyWith(fontSize: 16), bodyText2: text_theme.bodyText2!.copyWith(fontSize: 16));

    POPUP_HEADER_STYLE = text_theme.headline5!;

    NORMAL_STYLE = text_theme.bodyText1!;
    // TITLE_STYLE = text_theme.headline3!;
    TITLE_STYLE = text_theme.bodyText1!.copyWith(fontSize: 20);
    SUBTITLE_STYLE = text_theme.subtitle1!.copyWith(fontSize: 12, color: BASE_TEXT_COLOUR);
    PROPERTY_VALUE_STYLE = text_theme.subtitle1!.copyWith(fontWeight: FontWeight.normal);
    PROPERTY_LABEL_STYLE = PROPERTY_VALUE_STYLE.copyWith(fontWeight: FontWeight.bold);
    SMALL_HEADER_STYLE = text_theme.headline5!.copyWith(fontSize: 28);
    SMALLER_HEADER_STYLE = text_theme.headline6!.copyWith(fontSize: 19);
    LINK_TEXT_COLOUR = is_dark ? Colors.blue[300]! : Colors.blue;
    LINK_STYLE = NORMAL_STYLE.copyWith(decoration: TextDecoration.underline, color: LINK_TEXT_COLOUR);

    SEARCH_HIGHLIGHT_STYLE = TextStyle(backgroundColor: Color.lerp(PRIMARY_COLOUR, null, 0.6));
    // Paint _paint = Paint()
    //   ..color = Colors.blue
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 2.0;
    SEARCH_SELECTED_HIGHLIGHT_STYLE = TextStyle(backgroundColor: Color.lerp(Colors.red, null, 0.65));
    // SEARCH_SELECTED_HIGHLIGHT_STYLE = TextStyle(background: _paint);
    STRIKETHROUGH_STYLE = TextStyle(decoration: TextDecoration.lineThrough);
    LIST_STRIKETHROUGH_STYLE = TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Color.lerp(PRIMARY_COLOUR, null, 0.4));
    HEADER_STRIKETHROUGH_STYLE = TITLE_STYLE.copyWith(decoration: TextDecoration.lineThrough, decorationThickness: 2);
    CHIP_STRIKETHROUGH_STYLE = PROPERTY_VALUE_STYLE.copyWith(decoration: TextDecoration.lineThrough, color: DIM_TEXT_COLOUR);

    DEFAULT_INPUT_HINT_STYLE = text_theme.subtitle1!.copyWith(color: default_theme.hintColor);
    DEFAULT_INPUT_LABEL_STYLE = MaterialStateTextStyle.resolveWith((states) {
      TextStyle base_style = text_theme.subtitle1!;
      Color colour;
      if (states.contains(MaterialState.error))
        colour = ERROR_TEXT_COLOUR;
      else if (states.contains(MaterialState.disabled))
        colour = default_theme.disabledColor;
      else if (states.contains(MaterialState.focused))
        colour = ACCENT_TEXT_COLOUR;
      else
        colour = default_theme.hintColor;
      return base_style.copyWith(color: colour);
    });

    DEFAULT_INPUT_FLOATING_LABEL_STYLE = MaterialStateTextStyle.resolveWith((states) {
      TextStyle base_style = text_theme.subtitle1!;
      Color colour;
      if (states.contains(MaterialState.error))
        colour = ERROR_TEXT_COLOUR;
      else if (states.contains(MaterialState.disabled))
        colour = default_theme.disabledColor;
      else
        colour = ACCENT_TEXT_COLOUR;
      return base_style.copyWith(color: colour);
    });

    // MARKDOWN_BASE_TEXT_COLOUR = BASE_TEXT_COLOUR;
    // MARKDOWN_QUOTE_TEXT_COLOUR = is_dark ? Colors.blue[100]! : Colors.blue[800]!;
    // MARKDOWN_LINE_COLOUR = BRIGHTER_BORDER_COLOUR;
    // MARKDOWN_CODE_BACKGROUND_COLOUR = DIM_BACKGROUND;
    // MARKDOWN_CODE_TEXT_COLOUR = is_dark ? Colors.red[200]! : Colors.red[700]!;
    // MARKDOWN_CODE_BLOCK_BACKGROUND_COLOUR = is_dark ? Color.lerp(BASE_BACKGROUND_COLOUR, Colors.black, 0.1)! : Color.lerp(BASE_BACKGROUND_COLOUR, Colors.black, 0.07)!;
    // MARKDOWN_LINK_TEXT_COLOUR = is_dark ? Colors.blue[300]! : Colors.blue;
    //
    // MARKDOWN_CHECKBOX_COLOUR = ACCENT_COLOUR;
    // MARKDOWN_DIVIDER_COLOUR = DIVIDER_COLOUR;
    // MARKDOWN_BORDER_COLOUR = BORDER_COLOUR;
    // MARKDOWN_FOCUSED_BORDER_COLOUR = BRIGHTER_BORDER_COLOUR;
    // MARKDOWN_ADD_BUTTON_COLOUR = Colors.green;
    // MARKDOWN_ADD_BUTTON_TEXT_COLOUR = Colors.white;
    // MARKDOWN_REMOVE_BUTTON_COLOUR = Colors.red;
    // MARKDOWN_REMOVE_BUTTON_TEXT_COLOUR = Colors.white;
    // MARKDOWN_QUOTE_BORDER_COLOUR = Colors.blue;
    // MARKDOWN_QUOTE_BACKGROUND_COLOUR = Color.lerp(Colors.blue, null, 0.8)!;
    // MARKDOWN_DIALOG_BUTTON_TEXT_COLOUR = ACCENT_TEXT_COLOUR;
    // MARKDOWN_TOP_BAR_BACKGROUND_COLOUR = is_dark ? Color.lerp(Colors.black, Colors.white, 0.17)! : Color.lerp(Colors.white, Colors.black, 0.17)!;
    // MARKDOWN_TOP_BAR_TEXT_COLOUR = is_dark ? Colors.white : Colors.black;
    //
    // MARKDOWN_HIGHLIGHTING_THEME = is_dark ? {...dark_highlighting_theme.atomOneDarkReasonableTheme} : {...light_highlighting_theme.atomOneLightTheme};
    // // MARKDOWN_CODE_BLOCK_BACKGROUND_COLOUR = MARKDOWN_HIGHLIGHTING_THEME['root']!.backgroundColor!;
    // MARKDOWN_HIGHLIGHTING_THEME['root'] = TextStyle(color: MARKDOWN_HIGHLIGHTING_THEME['root']!.color, backgroundColor: Colors.transparent);

    ButtonStyle primary_text_button_theme = TextButton.styleFrom(
      foregroundColor: ACCENT_TEXT_COLOUR,
      textStyle: TextStyle(color: ACCENT_TEXT_COLOUR),
      minimumSize: Size.zero,
    );
    ButtonStyle primary_outlined_button_theme = OutlinedButton.styleFrom(
      foregroundColor: ACCENT_TEXT_COLOUR,
      textStyle: TextStyle(color: ACCENT_TEXT_COLOUR),
      minimumSize: Size.zero,
      side: BorderSide(width: 1, color: BORDER_COLOUR),
    );
    ButtonStyle primary_elevated_button_theme = ElevatedButton.styleFrom(
      backgroundColor: ACCENT_COLOUR,
      minimumSize: Size.zero,
      foregroundColor: ACCENT_CONTRAST_COLOUR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    SHADOW_COLOUR = Color.lerp(Colors.black, null, 0.3)!;
    ICON_SHADOW = [
      BoxShadow(blurRadius: 5, spreadRadius: 2, offset: Offset(1, 2), color: SHADOW_COLOUR, blurStyle: BlurStyle.outer),
    ];

    CHART_PALETTE = [
      ACCENT_COLOUR,
      Colors.greenAccent,
      PRIMARY_COLOUR,
      Colors.amberAccent,
      Colors.orange,
      Colors.deepOrange,
      Colors.pink,
      Colors.deepPurpleAccent,
      Colors.blue,
    ];

    theme = ThemeData(
      brightness: is_dark ? Brightness.dark : Brightness.light,
      canvasColor: BASE_BACKGROUND_COLOUR,
      primaryColor: PRIMARY_COLOUR,
      focusColor: ACCENT_COLOUR,
      toggleableActiveColor: ACCENT_COLOUR,
      hoverColor: DIM_BACKGROUND,
      colorScheme: default_theme.colorScheme.copyWith(
        primary: PRIMARY_COLOUR,
        onPrimary: PRIMARY_CONTRAST_COLOUR,
        primaryContainer: WEAK_PRIMARY_COLOUR,
        secondary: ACCENT_COLOUR,
        onSecondary: ACCENT_CONTRAST_COLOUR,
        secondaryContainer: WEAK_ACCENT_COLOUR,
        tertiary: ADDITIONAL_COLOUR,
        onTertiary: ADDITIONAL_COLOUR.contrasting_colour,
        surface: BASE_BACKGROUND_COLOUR,
        error: ERROR_TEXT_COLOUR,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: ACCENT_COLOUR, selectionColor: WEAK_ACCENT_COLOUR, selectionHandleColor: ACCENT_COLOUR),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ACCENT_COLOUR)),
        prefixStyle: TextStyle(color: ACCENT_TEXT_COLOUR),
        suffixStyle: TextStyle(color: ACCENT_TEXT_COLOUR),
        floatingLabelStyle: TextStyle(color: ACCENT_TEXT_COLOUR),
        errorStyle: TextStyle(color: ERROR_TEXT_COLOUR),
      ),
      sliderTheme: SliderThemeData.fromPrimaryColors(
        primaryColor: PRIMARY_COLOUR,
        primaryColorDark: PRIMARY_COLOUR,
        primaryColorLight: PRIMARY_COLOUR,
        valueIndicatorTextStyle: TextStyle(),
      ),
      // sliderTheme: SliderThemeData(activeTrackColor: ACCENT_COLOUR, activeTickMarkColor: ACCENT_COLOUR, thumbColor: ACCENT_COLOUR, overlayColor: DIM_ACCENT_COLOUR),
      textButtonTheme: TextButtonThemeData(style: primary_text_button_theme),
      outlinedButtonTheme: OutlinedButtonThemeData(style: primary_outlined_button_theme),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primary_elevated_button_theme),
      snackBarTheme: SnackBarThemeData(backgroundColor: BASE_BACKGROUND_COLOUR, actionTextColor: ACCENT_TEXT_COLOUR, contentTextStyle: TextStyle(color: BASE_TEXT_COLOUR)),
      dividerTheme: DividerThemeData(color: DIVIDER_COLOUR, thickness: 0, space: 0, indent: 0, endIndent: 0),
      appBarTheme: AppBarTheme(backgroundColor: PRIMARY_COLOUR, foregroundColor: PRIMARY_CONTRAST_COLOUR),
      textTheme: text_theme,
      chipTheme: ChipThemeData(backgroundColor: PRIMARY_COLOUR, brightness: PRIMARY_COLOUR_BRIGHTNESS),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: PRIMARY_COLOUR, foregroundColor: PRIMARY_CONTRAST_COLOUR),
      iconTheme: IconThemeData(color: ICON_COLOUR),
    );

    overlay_style = SystemUiOverlayStyle(statusBarColor: PRIMARY_COLOUR, statusBarBrightness: PRIMARY_COLOUR_BRIGHTNESS);
  }

  Color dim_colour(Color original) {
    var _curr_colour = HSLColor.fromColor(original);
    return Color.lerp(_curr_colour.withSaturation(_curr_colour.saturation * 0.6).toColor(), is_dark ? Colors.black : Colors.white, 0.3)!;
  }

  Color weaken_colour(Color original) {
    return Color.lerp(original, null, 0.7)!;
  }

  static Color make_text_colour(Color colour, Brightness brightness) {
    if (brightness == Brightness.light)
      return Color.lerp(colour, Colors.white, 0.6)!;
    else
      return Color.lerp(colour, Colors.black, 0.4)!;
  }

  Color make_text_colour_strong(Color colour) {
    if (colour_contrast_ratio(colour, BASE_BACKGROUND_COLOUR) > 3) return colour;
    return make_text_colour(colour, BASE_TEXT_COLOUR.brightness);
  }

  static Color dim_text_colour(Color original) {
    return Color.lerp(original, null, original.brightness == Brightness.light ? 0.4 : 0.5)!;
  }

  static Color make_icon_colour(Color background, {bool dim = false}) {
    if (dim)
      return Color.lerp(background.contrasting_colour, null, background.brightness == Brightness.dark ? 0.7 : 0.8)!;
    else
      return Color.lerp(background.contrasting_colour, null, background.brightness == Brightness.dark ? 0.4 : 0.6)!;
  }

  static Widget on_appbar_theme_provider(BuildContext context, Widget Function(BuildContext context) child_builder, {Color? appbar_colour, bool bright_icons = false}) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return theme_colours.provider(
      builder: (context) {
        ZarainiaTheme theme_colours = get_zarainia_theme(context);
        Widget child = child_builder(context);
        if (bright_icons)
          child = Theme(
            data: theme_colours.theme.copyWith(
              iconTheme: IconThemeData(color: theme_colours.BACKGROUND_CONTRAST_COLOUR),
            ),
            child: child,
          );
        return child;
      },
      theme: theme_colours.theme_name,
      background_colour: appbar_colour ?? theme_colours.PRIMARY_COLOUR,
      primary_colour: theme_colours.ACCENT_COLOUR,
      secondary_colour: theme_colours.ACCENT_COLOUR,
    );
  }

  static Widget off_appbar_theme_provider(BuildContext context, Widget Function(BuildContext context) child_builder) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return theme_colours.provider(
      builder: child_builder,
      theme: theme_colours.theme_name,
      primary_colour: theme_colours.BASE_BACKGROUND_COLOUR,
      secondary_colour: theme_colours.ACCENT_COLOUR,
    );
  }
}

class ZarainiaThemeProvider extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  String theme;
  Color? background_colour;
  Color? primary_colour;
  Color? secondary_colour;

  ZarainiaThemeProvider({
    required this.builder,
    required this.theme,
    this.background_colour,
    required this.primary_colour,
    required this.secondary_colour,
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = ZarainiaTheme(
      theme_name: theme,
      background_colour: background_colour,
      primary_colour: primary_colour,
      secondary_colour: secondary_colour,
      platform: Theme.of(context).platform,
      localizations: DefaultMaterialLocalizations(),
      default_primary_colour: Colors.blueGrey[500]!,
      default_accent_colour: Colors.deepOrangeAccent[400]!,
      default_additional_colour: Colors.blueGrey[500]!,
    );
    return Theme(
      data: theme_colours.theme,
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(color: theme_colours.BASE_TEXT_COLOUR),
        child: Provider<ZarainiaTheme>.value(
          value: theme_colours,
          builder: (context, widget) => builder(context),
        ),
      ),
    );
  }
}

ThemeData get_themedata(BuildContext context) {
  return Theme.of(context);
}

ZarainiaTheme get_zarainia_theme(BuildContext context) {
  return context.watch<ZarainiaTheme>();
}
