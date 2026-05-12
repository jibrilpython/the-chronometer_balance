import 'package:flutter/material.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';

const Color kBackground = Color(0xFFF8F8F6);
const Color kPrimaryText = Color(0xFF121210);
const Color kSecondaryText = Color(0xFF888886);
const Color kAccent = Color(0xFF1B4F72);
const Color kOutline = Color(0xFFE6E6E4);
const Color kWalnut = Color(0xFF8B7355);
const Color kError = Color(0xFFB03A2E);
const Color kCardSurface = Color(0xFFFFFFFF);
const Color kActiveBg = Color(0xFFEEF3F8);

const double kRadiusStandard = 8.0;
const double kRadiusSubtle = 6.0;
const double kRadiusPill = 999.0;

const Duration kTransitionDuration = Duration(milliseconds: 260);

Color getInstrumentColor(InstrumentType type) {
  switch (type) {
    case InstrumentType.stakingTool:
      return kAccent;
    case InstrumentType.depthingTool:
      return kWalnut;
    case InstrumentType.mainspringWinder:
      return Color(0xFF5D6D7E);
    case InstrumentType.poiseScale:
      return Color(0xFF7D6608);
    case InstrumentType.watchTimingMachine:
      return Color(0xFF1A5276);
    case InstrumentType.marineChronometerTester:
      return Color(0xFF0E6655);
    case InstrumentType.masterClock:
      return Color(0xFF6C3483);
    case InstrumentType.transitInstrument:
      return Color(0xFF1F6F8B);
    case InstrumentType.ratingScale:
      return Color(0xFF5B2C6F);
  }
}

Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.operational:
      return const Color(0xFF1B4F72);
    case ConditionState.originalFinish:
      return const Color(0xFF117A65);
    case ConditionState.jewelIntegrity:
      return const Color(0xFF7D6608);
    case ConditionState.museumQuality:
      return const Color(0xFF6C3483);
    case ConditionState.unknown:
      return kSecondaryText;
  }
}
