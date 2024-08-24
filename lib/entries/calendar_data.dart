import 'dart:convert';

import 'package:collection_providers/collection_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef DayData = Map<String, double>;
typedef DayEntry = MapEntry<String, double>;

class CalendarData {
  MapChangeNotifier<DateTime, DayData> data = MapChangeNotifier();

  late final SharedPreferences sharedPrefs;
  Future<void>? loadingFuture;
  Future<void>? savingFuture;

  Future<void> _saveData() async {
    sharedPrefs.setString(
      'calendarData',
      jsonEncode(
        Map.fromEntries(
            data.entries.where((dayData) => dayData.value.isNotEmpty)).map(
          (key, value) {
            return MapEntry(key.toIso8601String(), jsonEncode(value));
          },
        ),
      ),
    );
  }

  Future<void> _initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey('calendarData')) {
      final json = sharedPrefs.getString('calendarData');
      if (json != null) {
        data.addAll(
          (jsonDecode(json) as Map<String, dynamic>).map(
            (key, value) {
              return MapEntry(
                DateTime.parse(key),
                (jsonDecode(value) as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, value as double),
                ),
              );
            },
          ),
        );
      }
    } else {
      data.addAll(
        {
          DateTime.utc(2024, 8, 19): {
            "Thing 1": 4,
            "Thing 2": 2,
          },
          DateTime.utc(2024, 8, 17): {
            "Other thing 1": 8,
            "Other thing 2": 3,
          },
        },
      );
    }
    data.addListener(() {
      savingFuture = _saveData();
    });
  }

  CalendarData() {
    loadingFuture = _initSharedPrefs();
  }
}
