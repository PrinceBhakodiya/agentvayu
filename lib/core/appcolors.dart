import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const primary = Colors.white;
  static const primaryGreen = Color(0xFF32854F);
  static const primaryLight = Color(0xFF17335B);
  static const primaryBlue = Color(0xFF485FCC);

  static const black = Color(0xff263238);
  static const blackColor = Colors.black87;
  static const greyColor = Color(0xff858585);
  static const greyLabelColor = Color(0xff989898);
  static const greyTextColor = Color(0xff344054);
  static const greyMenuIconColor = Color(0xff999999);
  static const lightGreyColor = Color(0xffF2F2F2);
  static const helpTextColor = Color(0xff333333);
  static const white = Color(0xffffffff);
  static const grey = Color(0xff8892aa);
  static const borderGrey = Color(0XFFb5b5bf);
  static const Map<int, Color> primaryPallet = {
    50: Color.fromRGBO(23, 51, 91, .1),
    100: Color.fromRGBO(23, 51, 91, .2),
    200: Color.fromRGBO(23, 51, 91, .3),
    300: Color.fromRGBO(23, 51, 91, .4),
    400: Color.fromRGBO(23, 51, 91, .5),
    500: Color.fromRGBO(23, 51, 91, .6),
    600: Color.fromRGBO(23, 51, 91, .7),
    700: Color.fromRGBO(23, 51, 91, .8),
    800: Color.fromRGBO(23, 51, 91, .9),
    900: primary,
  };
}
