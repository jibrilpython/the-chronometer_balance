import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/utils/const.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kBackground,
  primaryColor: kAccent,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kWalnut,
    surface: kCardSurface,
    error: kError,
    outline: kOutline,
  ),

  textTheme: TextTheme(
    displayLarge: GoogleFonts.libreBaskerville(
      color: kPrimaryText,
      fontSize: 32.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.libreBaskerville(
      color: kPrimaryText,
      fontSize: 26.sp,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: GoogleFonts.libreBaskerville(
      color: kPrimaryText,
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.sourceSans3(
      color: kPrimaryText,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.sourceSans3(
      color: kPrimaryText,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.sourceSans3(
      color: kPrimaryText,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.sourceSans3(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.ibmPlexMono(
      color: kPrimaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.ibmPlexMono(
      color: kSecondaryText,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    ),
    labelSmall: GoogleFonts.ibmPlexMono(
      color: kSecondaryText,
      fontSize: 9.sp,
      fontWeight: FontWeight.w400,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kCardSurface,
    hintStyle: GoogleFonts.sourceSans3(
      color: kSecondaryText.withAlpha(150),
      fontSize: 14.sp,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: const BorderSide(color: kOutline, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: const BorderSide(color: kOutline, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: const BorderSide(color: kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: const BorderSide(color: kError, width: 1.0),
    ),
  ),

  iconTheme: const IconThemeData(
    color: kSecondaryText,
    size: 24,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: kBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.sourceSans3(
      color: kPrimaryText,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),

  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 1,
  ),

  cardTheme: CardThemeData(
    color: kCardSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      side: const BorderSide(color: kOutline),
    ),
    margin: EdgeInsets.zero,
  ),
);
