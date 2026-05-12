import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_chronometer_balance/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _temporalIdentifier = '';
  InstrumentType _instrumentType = InstrumentType.stakingTool;
  String _manufacturerAndMaker = '';
  CountryOfOrigin _countryOfOrigin = CountryOfOrigin.england;
  String _eraOfProduction = '';
  OperatingPrinciple _operatingPrinciple = OperatingPrinciple.mechanical;
  String _precisionRating = '';
  String _materials = '';
  String _dimensionsAndWeight = '';
  ConditionState _conditionState = ConditionState.unknown;
  String _includedAccessories = '';
  String _markingsAndStamps = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get temporalIdentifier => _temporalIdentifier;
  InstrumentType get instrumentType => _instrumentType;
  String get manufacturerAndMaker => _manufacturerAndMaker;
  CountryOfOrigin get countryOfOrigin => _countryOfOrigin;
  String get eraOfProduction => _eraOfProduction;
  OperatingPrinciple get operatingPrinciple => _operatingPrinciple;
  String get precisionRating => _precisionRating;
  String get materials => _materials;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get conditionState => _conditionState;
  String get includedAccessories => _includedAccessories;
  String get markingsAndStamps => _markingsAndStamps;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set temporalIdentifier(String v) {
    _temporalIdentifier = v;
    notifyListeners();
  }
  set instrumentType(InstrumentType v) {
    _instrumentType = v;
    notifyListeners();
  }
  set manufacturerAndMaker(String v) {
    _manufacturerAndMaker = v;
    notifyListeners();
  }
  set countryOfOrigin(CountryOfOrigin v) {
    _countryOfOrigin = v;
    notifyListeners();
  }
  set eraOfProduction(String v) {
    _eraOfProduction = v;
    notifyListeners();
  }
  set operatingPrinciple(OperatingPrinciple v) {
    _operatingPrinciple = v;
    notifyListeners();
  }
  set precisionRating(String v) {
    _precisionRating = v;
    notifyListeners();
  }
  set materials(String v) {
    _materials = v;
    notifyListeners();
  }
  set dimensionsAndWeight(String v) {
    _dimensionsAndWeight = v;
    notifyListeners();
  }
  set conditionState(ConditionState v) {
    _conditionState = v;
    notifyListeners();
  }
  set includedAccessories(String v) {
    _includedAccessories = v;
    notifyListeners();
  }
  set markingsAndStamps(String v) {
    _markingsAndStamps = v;
    notifyListeners();
  }
  set provenance(String v) {
    _provenance = v;
    notifyListeners();
  }
  set notes(String v) {
    _notes = v;
    notifyListeners();
  }
  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }
  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }
  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _temporalIdentifier = '';
    _instrumentType = InstrumentType.stakingTool;
    _manufacturerAndMaker = '';
    _countryOfOrigin = CountryOfOrigin.england;
    _eraOfProduction = '';
    _operatingPrinciple = OperatingPrinciple.mechanical;
    _precisionRating = '';
    _materials = '';
    _dimensionsAndWeight = '';
    _conditionState = ConditionState.unknown;
    _includedAccessories = '';
    _markingsAndStamps = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
