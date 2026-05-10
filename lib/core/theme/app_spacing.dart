import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // ─── Base scale (4pt grid) ────────────────────────────────────────────────
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 56.0;
  static const double xl7 = 64.0;
  static const double xl8 = 80.0;
  static const double xl9 = 96.0;
  static const double xl10 = 128.0;

  // ─── Named semantic spacing ───────────────────────────────────────────────
  static const double pagePadding = lg;
  static const double pageHPadding = lg;
  static const double sectionSpacing = xl3;
  static const double cardPadding = lg;
  static const double cardInnerSpacing = md;
  static const double listItemSpacing = sm;
  static const double chipSpacing = sm;
  static const double iconSpacing = sm;
  static const double buttonHeight = 52.0;
  static const double buttonSmallHeight = 40.0;
  static const double buttonRadius = 14.0;
  static const double cardRadius = 20.0;
  static const double cardSmallRadius = 14.0;
  static const double dialogRadius = 24.0;
  static const double chipRadius = 100.0;
  static const double inputRadius = 14.0;
  static const double bottomSheetRadius = 28.0;
  static const double avatarSize = 44.0;
  static const double avatarSmallSize = 32.0;
  static const double iconSize = 24.0;
  static const double iconSmallSize = 18.0;
  static const double iconLargeSize = 32.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 60.0;
  static const double fabSize = 56.0;

  // ─── EdgeInsets helpers ───────────────────────────────────────────────────
  static const EdgeInsets pageInsets =
      EdgeInsets.symmetric(horizontal: pageHPadding);

  static const EdgeInsets pagePaddingAll =
      EdgeInsets.all(pagePadding);

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  static const EdgeInsets cardInsetsSymmetric =
      EdgeInsets.symmetric(horizontal: cardPadding, vertical: md);

  static const EdgeInsets listTileInsets =
      EdgeInsets.symmetric(horizontal: pageHPadding, vertical: md);

  static const EdgeInsets bottomSheetInsets =
      EdgeInsets.fromLTRB(lg, xl2, lg, xl2);

  // ─── SizedBox helpers ─────────────────────────────────────────────────────
  static const Widget gapXs2 = SizedBox(height: xs2, width: xs2);
  static const Widget gapXs = SizedBox(height: xs, width: xs);
  static const Widget gapSm = SizedBox(height: sm, width: sm);
  static const Widget gapMd = SizedBox(height: md, width: md);
  static const Widget gapLg = SizedBox(height: lg, width: lg);
  static const Widget gapXl = SizedBox(height: xl, width: xl);
  static const Widget gapXl2 = SizedBox(height: xl2, width: xl2);
  static const Widget gapXl3 = SizedBox(height: xl3, width: xl3);
  static const Widget gapXl4 = SizedBox(height: xl4, width: xl4);

  static Widget hGap(double size) => SizedBox(width: size);
  static Widget vGap(double size) => SizedBox(height: size);
}
