import 'package:flutter/material.dart';

class Constants {
  final String apiKey = "AIzaSyA4MOhrN6qMTCmAmoz8HdmY8DKcWm4Vz5E";

  static String appName = "Walk With Us";

  static String deviceToken = "DEV_TOKEN";
  static String groupID = "GROUP_ID";

//Colors for theme
//  Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color darkAccent = Colors.red[400];
  static Color darkBG = Colors.black;
  static Color ratingBG = Colors.yellow[600];

  static Color lightPrimary = Color(0xfffcfcff);
  static Color lightAccent = Colors.pinkAccent;
  static Color appThemeColor = Color(0xffAD0000);
  static Color appThemeComplementaryColor = Color(0xff00ADAD);
  static Color lightBG = Color(0xfffcfcff);
  static Color myAccent = Color(0xffFFA500);

  static ThemeData mainTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: appThemeColor,
    accentColor: myAccent,
    cursorColor: myAccent,
    fontFamily: "Oxygen",
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: lightPrimary,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
     iconTheme: IconThemeData(
       color: lightPrimary,
     ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    fontFamily: "Oxygen",
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: darkBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
//      iconTheme: IconThemeData(
//        color: lightAccent,
//      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    fontFamily: "Oxygen",
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: lightBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
//      iconTheme: IconThemeData(
//        color: darkAccent,
//      ),
    ),
  );
}
