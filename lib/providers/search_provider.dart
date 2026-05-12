import 'package:the_chronometer_balance/models/archive_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<HorologicalInstrumentModel> filteredList(
      List<HorologicalInstrumentModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.temporalIdentifier.toLowerCase().contains(query) ||
              item.manufacturerAndMaker.toLowerCase().contains(query) ||
              item.materials.toLowerCase().contains(query) ||
              item.provenance.toLowerCase().contains(query) ||
              item.eraOfProduction.toLowerCase().contains(query) ||
              item.precisionRating.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
