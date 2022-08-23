import 'package:flutter/material.dart';

class MyTheme {
  static final darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFA12568).withRed(100),
      foregroundColor: const Color(0xFFFEC260),
      elevation: 10,
      titleTextStyle: const TextStyle(
        color: Color(0xFFFEC260),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF2A0944),
    textTheme: const TextTheme(
      headline1: TextStyle(
        color: Colors.yellow,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      headline2: TextStyle(
        color: Color(0xFFFEC260),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      headline3: TextStyle(
        color: Colors.yellow,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color: Color(0xFFFEC260),
        fontSize: 15,
      ),
      subtitle2: TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.yellow,
      size: 25,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.yellow),
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFFEC260),
      disabledColor: Colors.grey,
      selectedColor: Colors.black,
      secondarySelectedColor: Colors.black87,
      padding: EdgeInsets.all(0),
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      secondaryLabelStyle: TextStyle(
        color: Colors.black,
      ),
      brightness: Brightness.dark,
    ),
    dialogBackgroundColor: Colors.black87,
    colorScheme: const ColorScheme.dark(),
    splashColor: const Color(0xFFA12568),
    backgroundColor: const Color(0xFFFEC260),
    primaryColor: const Color(0xFF3B185F),
  );

  static final lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF075E54),
      foregroundColor: Colors.white,
      elevation: 10,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headline1: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      headline2: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
      subtitle2: TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 25,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFF25D366)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
    ),
    fixTextFieldOutlineLabel: true,
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF25D366),
      disabledColor: Colors.grey,
      selectedColor: Colors.black,
      secondarySelectedColor: Colors.black87,
      padding: EdgeInsets.all(0),
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      secondaryLabelStyle: TextStyle(
        color: Colors.black,
      ),
      brightness: Brightness.dark,
    ),
    dialogBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    splashColor: const Color(0xFF128C7E),
    primaryColor: const Color(0xFF075E54),
    backgroundColor: const Color(0xFF25D366),
    accentColor: const Color(0xFF34B7F1),
  );
}
