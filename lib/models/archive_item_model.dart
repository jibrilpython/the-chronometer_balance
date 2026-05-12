import 'package:the_chronometer_balance/enum/my_enums.dart';

class HorologicalInstrumentModel {
  String id;

  String temporalIdentifier;
  InstrumentType instrumentType;
  String manufacturerAndMaker;
  CountryOfOrigin countryOfOrigin;
  String eraOfProduction;
  OperatingPrinciple operatingPrinciple;
  String precisionRating;
  String materials;
  String dimensionsAndWeight;
  ConditionState conditionState;
  String includedAccessories;
  String markingsAndStamps;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  HorologicalInstrumentModel({
    required this.id,
    required this.temporalIdentifier,
    required this.instrumentType,
    required this.manufacturerAndMaker,
    required this.countryOfOrigin,
    required this.eraOfProduction,
    required this.operatingPrinciple,
    required this.precisionRating,
    required this.materials,
    required this.dimensionsAndWeight,
    required this.conditionState,
    required this.includedAccessories,
    required this.markingsAndStamps,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'temporalIdentifier': temporalIdentifier,
        'instrumentType': instrumentType.name,
        'manufacturerAndMaker': manufacturerAndMaker,
        'countryOfOrigin': countryOfOrigin.name,
        'eraOfProduction': eraOfProduction,
        'operatingPrinciple': operatingPrinciple.name,
        'precisionRating': precisionRating,
        'materials': materials,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionState': conditionState.name,
        'includedAccessories': includedAccessories,
        'markingsAndStamps': markingsAndStamps,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory HorologicalInstrumentModel.fromJson(Map<String, dynamic> json) =>
      HorologicalInstrumentModel(
        id: json['id'] ?? '',
        temporalIdentifier: json['temporalIdentifier'] ?? '',
        instrumentType:
            InstrumentType.values.asNameMap()[json['instrumentType']] ??
                InstrumentType.stakingTool,
        manufacturerAndMaker: json['manufacturerAndMaker'] ?? '',
        countryOfOrigin:
            CountryOfOrigin.values.asNameMap()[json['countryOfOrigin']] ??
                CountryOfOrigin.england,
        eraOfProduction: json['eraOfProduction'] ?? '',
        operatingPrinciple:
            OperatingPrinciple.values.asNameMap()[json['operatingPrinciple']] ??
                OperatingPrinciple.mechanical,
        precisionRating: json['precisionRating'] ?? '',
        materials: json['materials'] ?? '',
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionState:
            ConditionState.values.asNameMap()[json['conditionState']] ??
                ConditionState.unknown,
        includedAccessories: json['includedAccessories'] ?? '',
        markingsAndStamps: json['markingsAndStamps'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
