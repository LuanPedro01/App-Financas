import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // ─── Navigation ───────────────────────────────────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool canPop() => Navigator.of(this).canPop();

  // ─── Overlay ──────────────────────────────────────────────────────────────
  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showSuccessSnackBar(String message) => showSnackBar(
        message,
        backgroundColor: const Color(0xFF10B981),
      );

  void showErrorSnackBar(String message) => showSnackBar(
        message,
        backgroundColor: const Color(0xFFEF4444),
      );

  // ─── Screen ───────────────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  bool get isKeyboardVisible => viewInsets.bottom > 0;
  double get bottomPadding => padding.bottom;
  double get topPadding => padding.top;

  bool get isSmallScreen => screenWidth < 360;
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;
  bool get isLargeScreen => screenWidth >= 600;

  // ─── Theme ────────────────────────────────────────────────────────────────
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isLight => !isDark;
}
