import 'package:flutter/material.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';

class AppTheme {

  static ThemeData get generalTheme{
    return ThemeData(
      //colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      primaryColor: AppColors.primaryColor,
      /*colorScheme: ColorScheme(
          brightness: brightness,
          primary: AppColors.primaryColor,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          error: error, onError: onError,
          surface: surface,
          onSurface: onSurface
      ),*/
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
            color: AppColors.primaryTextColor, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle( // *Para titulos principales
            color: AppColors.primaryTextColor, fontWeight: FontWeight.bold,fontSize: 25.0),
        titleLarge: TextStyle(  // *Para subtitulos
            color: AppColors.primaryTextColor, fontWeight: FontWeight.bold),
        titleSmall: TextStyle( // *Para texto de botones
            color: AppColors.primaryTextColor,fontSize: 17.0,  fontWeight: FontWeight.bold ),
        bodyMedium: TextStyle( // *Para texto de botones
            color: AppColors.primaryTextColor),
        bodySmall: TextStyle( // *Para descripciones de las cards
            color: AppColors.variantTextColor,fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.secondaryColor),
            foregroundColor: WidgetStateProperty.all(AppColors.secondaryTextColor),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                )),
            splashFactory: InkRipple.splashFactory,
            overlayColor: WidgetStateProperty.all(AppColors.primaryVariantColor),
          )
      ),
    );
  }

}