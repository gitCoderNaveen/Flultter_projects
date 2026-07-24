import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = FlexThemeData.light(
    useMaterial3: true,

    scheme: FlexScheme.blue,

    primary: AppColors.primary,

    secondary: AppColors.secondary,

    scaffoldBackground: AppColors.background,

    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,

    blendLevel: 10,

    appBarStyle: FlexAppBarStyle.background,

    subThemesData: const FlexSubThemesData(
      defaultRadius: 22,

      cardRadius: 24,

      inputDecoratorRadius: 18,

      fabRadius: 18,

      bottomNavigationBarElevation: 0,

      elevatedButtonRadius: 14,

      filledButtonRadius: 14,
    ),

    textTheme: AppTextTheme.textTheme,
  );
}