import 'package:enter_cms_flutter/components/no_page_transitions_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0061A5),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD2E4FF),
  onPrimaryContainer: Color(0xFF001C37),
  secondary: Color(0xFF7E3AC0),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF0DBFF),
  onSecondaryContainer: Color(0xFF2C0051),
  tertiary: Color(0xFFA413A9),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD6F7),
  onTertiaryContainer: Color(0xFF37003A),
  error: Color(0xFFFF3333),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFF191C1E),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFDFCFF),
  onSurface: Color(0xFF1A1C1E),
  surfaceVariant: Color(0xFFDFE2EB),
  onSurfaceVariant: Color(0xFF43474E),
  outline: Color(0xFF73777F),
  onInverseSurface: Color(0xFFF1F0F4),
  inverseSurface: Color(0xFF2F3033),
  inversePrimary: Color(0xFFA0CAFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF0061A5),
  outlineVariant: Color(0xFFC3C6CF),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA0CAFF),
  onPrimary: Color(0xFF003259),
  primaryContainer: Color(0xFF00497E),
  onPrimaryContainer: Color(0xFFD2E4FF),
  secondary: Color(0xFFDDB8FF),
  onSecondary: Color(0xFF490081),
  secondaryContainer: Color(0xFF641AA7),
  onSecondaryContainer: Color(0xFFF0DBFF),
  tertiary: Color(0xFFFFAAF8),
  onTertiary: Color(0xFF5A005E),
  tertiaryContainer: Color(0xFF800084),
  onTertiaryContainer: Color(0xFFFFD6F7),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1A1C1E),
  onBackground: Color(0xFFE2E2E6),
  surface: Color(0xFF1A1C1E),
  onSurface: Color(0xFFE2E2E6),
  surfaceVariant: Color(0xFF43474E),
  onSurfaceVariant: Color(0xFFC3C6CF),
  outline: Color(0xFF8D9199),
  onInverseSurface: Color(0xFF1A1C1E),
  inverseSurface: Color(0xFFE2E2E6),
  inversePrimary: Color(0xFF0061A5),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFA0CAFF),
  outlineVariant: Color(0xFF43474E),
  scrim: Color(0xFF000000),
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
