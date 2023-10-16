import 'package:enter_cms_flutter/components/no_page_transitions_builder.dart';
import 'package:flutter/material.dart';

class EnterThemeColors {
  static const red = Color(0xFFFF3333);
  static const orange = Color(0xFFFFA347);
  static const green = Color(0xFF9ADE52);
  static const yellow = Color(0xFFFFE173);
  static const turquoise = Color(0xFF35F0F0);
  static const blue = Color(0xFF4DA6FF);
  static const purple = Color(0xFFB16EF5);
  static const pink = Color(0xFFE85DE8);
}

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: EnterThemeColors.blue,
);

final darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: EnterThemeColors.blue,
);

final TextTheme _baseTextTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'ABCDiatypeRounded',
).textTheme;

final TextTheme textTheme = _baseTextTheme.copyWith(
  headlineMedium: _baseTextTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.w600,
  ),
  titleSmall: _baseTextTheme.titleSmall!.copyWith(
    fontWeight: FontWeight.w600,
  ),
);

final PageTransitionsTheme pageTransitionsTheme =
    PageTransitionsTheme(builders: {
  for (final platform in TargetPlatform.values)
    platform: const NoPageTransitionsBuilder(),
});

const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  border: const OutlineInputBorder(),
  isDense: true,
);

final ThemeData baseLightTheme = ThemeData.from(
  colorScheme: lightColorScheme,
  useMaterial3: true,
  textTheme: textTheme,
);

final ThemeData baseDarkTheme = ThemeData.from(
  colorScheme: darkColorScheme,
  useMaterial3: true,
  textTheme: textTheme.apply(
    bodyColor: darkColorScheme.onBackground,
    displayColor: darkColorScheme.onBackground,
  ),
);

final ThemeData lightTheme = baseLightTheme.copyWith(
  dividerTheme: baseLightTheme.dividerTheme.copyWith(
    space: 1,
    color: baseLightTheme.colorScheme.surfaceVariant,
  ),
  pageTransitionsTheme: pageTransitionsTheme,
  inputDecorationTheme: inputDecorationTheme,
  appBarTheme: baseLightTheme.appBarTheme.copyWith(
    backgroundColor: baseLightTheme.colorScheme.primary,
    foregroundColor: Colors.white,
  ),
);

final ThemeData darkTheme = baseDarkTheme.copyWith(
  dividerTheme: baseDarkTheme.dividerTheme.copyWith(
    space: 1,
    color: baseDarkTheme.colorScheme.surfaceVariant,
  ),
  pageTransitionsTheme: pageTransitionsTheme,
  inputDecorationTheme: inputDecorationTheme,
  appBarTheme: baseDarkTheme.appBarTheme.copyWith(
    backgroundColor: baseDarkTheme.colorScheme.primaryContainer,
    foregroundColor: Colors.white,
  ),
);
