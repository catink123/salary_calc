import 'package:collection_providers/collection_providers.dart';
import 'package:salary_calc/db.dart';
import 'package:sembast/sembast.dart';

typedef DayData = Map<String, double>;
typedef DayEntry = MapEntry<String, double>;

class CalendarData {
  MapChangeNotifier<DateTime, DayData> data = MapChangeNotifier();

  final _store = StoreRef<int, Map<String, Object?>>('calendarData');
  Future<void>? savingFuture;

  Future<void> _saveData() async {
    await _store
        .records(data.keys.map((e) => e.millisecondsSinceEpoch))
        .put(DB.instance, data.values.toList(), merge: true);
  }

  void _init() {
    final records = _store
        .findSync(
          DB.instance,
        )
        .keysAndValues
        .map(
          (e) => MapEntry(
            DateTime.fromMillisecondsSinceEpoch(e.$1, isUtc: true),
            e.$2.map(
              (key, value) => MapEntry(key, value as double),
            ),
          ),
        );

    data.addAll(Map.fromEntries(records));
    data.addListener(() {
      savingFuture = _saveData();
    });
  }

  CalendarData() {
    _init();
  }
}
