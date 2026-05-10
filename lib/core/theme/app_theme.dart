import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_typography.dart';
import 'package:financeiro/core/theme/app_spacing.dart';

enum AppThemeMode { dark, amoled, light }

abstract final class AppTheme {
  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => _buildDark(
        background: AppColors.dark800,
        surface: AppColors.dark700,
        surfaceVariant: AppColors.dark650,
        onBackground: AppColors.dark50,
      );

  // ─── AMOLED Theme ─────────────────────────────────────────────────────────
  static ThemeData get amoled => _buildDark(
        background: AppColors.dark900,
        surface: AppColors.dark850,
        surfaceVariant: AppColors.dark800,
        onBackground: AppColors.dark50,
        isAmoled: true,
      );

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => _buildLight();

  // ─── Dark Builder ─────────────────────────────────────────────────────────
  static ThemeData _buildDark({
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color onBackground,
    bool isAmoled = false,
  }) {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.brand500,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.brand900,
      onPrimaryContainer: AppColors.brand100,
      secondary: AppColors.accent500,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.accent900,
      onSecondaryContainer: AppColors.accent100,
      tertiary: AppColors.success500,
      onTertiary: AppColors.white,
      error: AppColors.error500,
      onError: AppColors.white,
      errorContainer: const Color(0xFF4A0000),
      onErrorContainer: AppColors.error100,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onBackground,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: AppColors.dark200,
      outline: AppColors.dark500,
      outlineVariant: AppColors.dark600,
      shadow: AppColors.black,
      scrim: AppColors.black.withOpacity(0.8),
      inverseSurface: AppColors.dark50,
      onInverseSurface: AppColors.dark800,
      inversePrimary: AppColors.brand600,
    );

    return _buildBase(colorScheme, Brightness.dark, isAmoled: isAmoled);
  }

  // ─── Light Builder ────────────────────────────────────────────────────────
  static ThemeData _buildLight() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.brand600,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.brand50,
      onPrimaryContainer: AppColors.brand800,
      secondary: AppColors.accent500,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.accent50,
      onSecondaryContainer: AppColors.accent800,
      tertiary: AppColors.success600,
      onTertiary: AppColors.white,
      error: AppColors.error500,
      onError: AppColors.white,
      errorContainer: AppColors.error50,
      onErrorContainer: AppColors.error600,
      background: AppColors.light900,
      onBackground: const Color(0xFF111318),
      surface: AppColors.white,
      onSurface: const Color(0xFF111318),
      surfaceVariant: AppColors.light800,
      onSurfaceVariant: const Color(0xFF4A5267),
      outline: AppColors.light500,
      outlineVariant: AppColors.light600,
      shadow: AppColors.black,
      scrim: AppColors.black.withOpacity(0.6),
      inverseSurface: AppColors.dark750,
      onInverseSurface: AppColors.dark50,
      inversePrimary: AppColors.brand400,
    );

    return _buildBase(colorScheme, Brightness.light);
  }

  // ─── Base ThemeData ───────────────────────────────────────────────────────
  static ThemeData _buildBase(
    ColorScheme colorScheme,
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colorScheme.background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: 'Inter',
      textTheme: textTheme,

      // ─── Scaffold ─────────────────────────────────────────────────────
      scaffoldBackgroundColor: colorScheme.background,

      // ─── AppBar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onBackground,
          size: AppSpacing.iconSize,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),

      // ─── Card ─────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),

      // ─── Elevated Button ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl2,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ─── FilledButton ─────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ─── Outlined Button ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Text Button ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Input Decoration ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // ─── Bottom Navigation ────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ─── NavigationBar ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        height: AppSpacing.bottomNavHeight,
        elevation: 0,
      ),

      // ─── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelSmall,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ─── Dialog ───────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ─── BottomSheet ──────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.bottomSheetRadius),
          ),
        ),
      ),

      // ─── Divider ──────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── Switch ───────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.3);
          }
          return colorScheme.surfaceVariant;
        }),
      ),

      // ─── Slider ───────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceVariant,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.1),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),

      // ─── Progress Indicator ───────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceVariant,
        circularTrackColor: colorScheme.surfaceVariant,
      ),

      // ─── FAB ──────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ─── Snackbar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.dark500 : AppColors.dark700,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.dark50,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardSmallRadius),
        ),
        elevation: 4,
      ),

      // ─── Tabs ─────────────────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge,
        dividerColor: colorScheme.outlineVariant,
      ),

      // ─── List Tile ────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHPadding,
          vertical: AppSpacing.xs,
        ),
        tileColor: Colors.transparent,
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onBackground,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ─── Icon Button ──────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onBackground,
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
      ),
    );
  }
}

// ─── Design Tokens ────────────────────────────────────────────────────────────
extension AppThemeContextExtensions on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Semantic colors
  Color get incomeColor => AppColors.income;
  Color get expenseColor => AppColors.expense;
  Color get transferColor => AppColors.transfer;
  Color get investmentColor => AppColors.investment;
}
