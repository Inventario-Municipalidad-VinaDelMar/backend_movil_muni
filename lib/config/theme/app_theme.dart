// lib/config/theme.dart

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  static ShadThemeData getShadTheme(Size size) {
    return ShadThemeData(
      brightness: Brightness.light,
      // textTheme: ShadTextTheme(
      //   colorScheme: ShadColorScheme(background: background, foreground: foreground, card: card, cardForeground: cardForeground, popover: popover, popoverForeground: popoverForeground, primary: primary, primaryForeground: primaryForeground, secondary: secondary, secondaryForeground: secondaryForeground, muted: muted, mutedForeground: mutedForeground, accent: accent, accentForeground: accentForeground, destructive: destructive, destructiveForeground: destructiveForeground, border: border, input: input, ring: ring, selection: selection),
      //   family: 'Kanit',
      // ),
      // colorScheme: const ShadSlateColorScheme.dark(),
      colorScheme: const ShadSlateColorScheme.light(muted: Colors.blue),
      buttonSizesTheme: ShadButtonSizesTheme(
        lg: ShadButtonSizeTheme(
          height: size.height * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }

  static ThemeData getMaterialTheme() {
    return ThemeData(
      // fontFamily: 'Kanit',
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue[600],
    );
  }

  static ShadThemeData getDarkShadTheme(Size size) {
    return ShadThemeData(
      buttonSizesTheme: ShadButtonSizesTheme(
        lg: ShadButtonSizeTheme(
          height: size.height * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
      // textTheme: ShadTextTheme(
      //   family: 'Kanit',
      // ),
      brightness: Brightness.light,
      // colorScheme: const ShadSlateColorScheme.dark(),
      colorScheme: const ShadSlateColorScheme.light(muted: Colors.blue),
    );
  }
}
