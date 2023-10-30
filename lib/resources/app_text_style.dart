import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multiscreen/multiscreen.dart';

const FONT_FAMILY = 'manrope';

enum TextWeight {
  extrabold,
  highbold,
  bold,
  semibold,
  medium,
  regular,
  light,
  thin,
}

enum TextSize {
  /// 50
  logo_large,

  /// 36
  intro,

  /// 32
  title_large,

  /// 30
  title_medium_bigger_than,

  /// 26
  title_medium_high,

  /// 24
  title_medium,

  /// 20
  title_small,

  /// 20
  body_large,

  /// 18
  body_medium,

  /// 16
  body_small,

  /// 13
  body_very_small,

  /// 16
  caption_large,

  /// 14
  caption_medium,

  /// 12
  caption_small,

  /// 11
  caption_very_small,

  /// 10
  copy_right_text,

  /// 24
  button_large,

  ///16
  button_medium,

  //9
  bottom_navigation
}

/// a type of Text style.
class AppTextStyle {
  static const LINE_HEIGHT_MULTI_LINE = 1.3;

  static TextStyle from({
    Color color,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    double decorationThickness,
    FontStyle fontStyle,
    TextBaseline textBaseline,
    List<String> fontFamilyFallback,
    double letterSpacing,
    double wordSpacing,
    double height = 1,
    Locale locale,
    Paint background,
    Paint foreground,
    List<Shadow> shadows,
    List<FontFeature> fontFeatures,
    TextWeight weight,
    TextSize size,
  }) {
    FontWeight fontWeight = FontWeight.w500;

    switch (weight) {
      case TextWeight.extrabold:
        fontWeight = FontWeight.w900;
        break;
      case TextWeight.highbold:
        fontWeight = FontWeight.w800;
        break;
      case TextWeight.bold:
        fontWeight = FontWeight.w700;
        break;
      case TextWeight.semibold:
        fontWeight = FontWeight.w600;
        break;
      case TextWeight.medium:
        fontWeight = FontWeight.w500;
        break;
      case TextWeight.regular:
        fontWeight = FontWeight.w400;
        break;
      case TextWeight.light:
        fontWeight = FontWeight.w300;
        break;
      case TextWeight.thin:
        fontWeight = FontWeight.w200;
        break;
    }

    double fontSize = 20;

    switch (size) {
      case TextSize.logo_large:
        fontSize = 50;
        break;
      case TextSize.intro:
        fontSize = 36;
        break;
      case TextSize.title_large:
        fontSize = 32;
        break;
      case TextSize.title_medium_bigger_than:
        fontSize = 30;
        break;
      case TextSize.title_medium:
        fontSize = 24;
        break;
      case TextSize.title_small:
        fontSize = 20;
        break;
      case TextSize.body_large:
        fontSize = 20;
        break;
      case TextSize.body_medium:
        fontSize = 18;
        break;
      case TextSize.body_small:
        fontSize = 16;
        break;
      case TextSize.body_very_small:
        fontSize = 13;
        break;
      case TextSize.caption_large:
        fontSize = 16;
        break;
      case TextSize.caption_medium:
        fontSize = 14;
        break;
      case TextSize.button_large:
        fontSize = 24;
        break;
      case TextSize.button_medium:
        fontSize = 16;
        break;
      case TextSize.caption_small:
        fontSize = 12;
        break;
      case TextSize.caption_very_small:
        fontSize = 11;
        break;
      case TextSize.copy_right_text:
        fontSize = 10;
        break;
      case TextSize.bottom_navigation:
        fontSize = 9;
        break;
    }

    fontSize = resize(fontSize);

    return TextStyle(
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      fontFamily: FONT_FAMILY,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      locale: locale,
      background: background,
      foreground: foreground,
      shadows: shadows,
      fontFeatures: fontFeatures,
    );
  }
}
