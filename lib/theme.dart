import 'package:enter_cms_flutter/components/no_page_transitions_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006590),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC8E6FF),
  onPrimaryContainer: Color(0xFF001E2E),
  secondary: Color(0xFF4F606E),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD3E5F5),
  onSecondaryContainer: Color(0xFF0B1D29),
  tertiary: Color(0xFF006590),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC8E6FF),
  onTertiaryContainer: Color(0xFF001E2E),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF191C1E),
  surfaceVariant: Color(0xFFDDE3EA),
  onSurfaceVariant: Color(0xFF41484D),
  outline: Color(0xFF71787E),
  onInverseSurface: Color(0xFFF0F0F3),
  inverseSurface: Color(0xFF2E3133),
  inversePrimary: Color(0xFF88CEFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006590),
  outlineVariant: Color(0xFFC1C7CE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF88CEFF),
  onPrimary: Color(0xFF00344D),
  primaryContainer: Color(0xFF004C6D),
  onPrimaryContainer: Color(0xFFC8E6FF),
  secondary: Color(0xFFB7C9D8),
  onSecondary: Color(0xFF21323F),
  secondaryContainer: Color(0xFF384956),
  onSecondaryContainer: Color(0xFFD3E5F5),
  tertiary: Color(0xFF88CEFF),
  onTertiary: Color(0xFF00344D),
  tertiaryContainer: Color(0xFF004C6D),
  onTertiaryContainer: Color(0xFFC8E6FF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF41484D),
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8B9198),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF006590),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF88CEFF),
  outlineVariant: Color(0xFF41484D),
  scrim: Color(0xFF000000),
);


// const ColorScheme lightColorScheme = ColorScheme.light(
//   primary: Color(0xFF007cb0),
//   //secondary: Color(0xFFa58b4c),
// );
//
// const ColorScheme darkColorScheme = ColorScheme.dark(
//   primary: Color(0xFF007cb0),
//   onPrimary: Colors.white,
//   onBackground: Colors.white,
//   onSurface: Colors.white,
//   //secondary: Color(0xFFa58b4c),
// );

final TextTheme _baseTextTheme = GoogleFonts.ibmPlexSansTextTheme();
final TextTheme textTheme = _baseTextTheme.copyWith(
  titleSmall: _baseTextTheme.titleSmall!.copyWith(
    fontWeight: FontWeight.w600,
  ),
);

final PageTransitionsTheme pageTransitionsTheme =
    PageTransitionsTheme(builders: {
  for (final platform in TargetPlatform.values)
    platform: const NoPageTransitionsBuilder(),
});

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
  appBarTheme: baseDarkTheme.appBarTheme.copyWith(
    backgroundColor: baseDarkTheme.colorScheme.primaryContainer,
    foregroundColor: Colors.white,
  ),
);
