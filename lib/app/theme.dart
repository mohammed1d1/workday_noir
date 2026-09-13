import 'package:flutter/cupertino.dart';

CupertinoThemeData noirTheme(Brightness brightness) => const CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFF5F5F7),
  scaffoldBackgroundColor: Color(0xFF08080A),
  barBackgroundColor: Color(0xE60A0A0C),
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(color: Color(0xFFF5F5F7), fontSize: 16),
    navTitleTextStyle: TextStyle(color: Color(0xFFF5F5F7), fontSize: 17, fontWeight: FontWeight.w600),
    navLargeTitleTextStyle: TextStyle(color: Color(0xFFF5F5F7), fontSize: 34, fontWeight: FontWeight.w700),
  ),
);
