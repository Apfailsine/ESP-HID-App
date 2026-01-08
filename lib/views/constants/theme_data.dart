import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';

ThemeData themeData() {
  return ThemeData(
    // colorScheme: const ColorScheme(
    //   brightness: Brightness.dark,
    //   primary: Color.fromARGB(255, 17, 32, 59),
    //   onPrimary: Color.fromARGB(255, 255, 255, 255),
    //   secondary: Color.fromARGB(255, 163, 175, 198),
    //   onSecondary: Color.fromARGB(255, 0, 0, 0),
    //   tertiary: Color.fromARGB(255, 234, 162, 65),
    //   onTertiary: Color.fromARGB(255, 0, 0, 0),
    //   error: Color.fromARGB(255, 215, 74, 74),
    //   onError: Color.fromARGB(255, 255, 255, 255),
    //   background: Color.fromARGB(255, 251, 253, 255),
    //   onBackground: Color.fromARGB(255, 0, 0, 0),
    //   surface: Color.fromARGB(255, 251, 253, 255),
    //   onSurface: Color.fromARGB(255, 0, 0, 0),
    //   surfaceTint: Color.fromARGB(255, 17, 32, 59),
    // ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.lightBlue[200], // Heller Blau für die Auswahl
      selectionHandleColor: Colors.blue[300], // Dunkleres Blau für die Griffe
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            side: BorderSide(color: CustomColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16)),
        backgroundColor: WidgetStateProperty.all<Color>(CustomColors.backgroundWhite),
        foregroundColor: WidgetStateProperty.all<Color>(CustomColors.primary),
        overlayColor: WidgetStateProperty.all<Color>(CustomColors.primaryHover),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(300, 50)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16)),
        backgroundColor: WidgetStateProperty.all<Color>(CustomColors.backgroundWhite),
        foregroundColor: WidgetStateProperty.all<Color>(CustomColors.primary),
        elevation: const WidgetStatePropertyAll(10),
        overlayColor: WidgetStateProperty.all<Color>(CustomColors.primaryHover),
      ),
    ),
    useMaterial3: true,
  );
}
