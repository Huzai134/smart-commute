import 'dart:async';

class PlacesService {
  static const String apiKey = "MOCK_MODE_ACTIVE"; 

  static const List<String> _mockLocations = [
    "National University of Modern Languages (NUML), H-9, Islamabad",
    "GCT College, Peshawar Road, Rawalpindi",
    "Saddar Metro Station, Rawalpindi",
    "Faisal Mosque, Islamabad",
    "Bahria Town Phase 7, Rawalpindi",
    "Centaurus Mall, Blue Area, Islamabad",
    "Commercial Market, Satellite Town, Rawalpindi",
    "Comsats University, Park Road, Islamabad",
    "DHA Phase 2, Islamabad",
    "Six Road Metro Station, Rawalpindi",
    "Faizabad Interchange, Islamabad",
    "National University (FAST), G-11, Islamabad",
    "Peshawar Road, Rawalpindi",
    "G-11 Markaz, Islamabad",
  ];

  static Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockLocations
        .where((place) => place.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}