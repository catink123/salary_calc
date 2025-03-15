import 'package:flutter/material.dart';
import 'package:salary_calc/db.dart';
import 'package:sembast/sembast.dart';

typedef PercentToPayMap = Map<double, int>;

class Settings with ChangeNotifier {
  static final PercentToPayMap _defaultPTPMap = {
    0.45: 10,
    0.65: 12,
    0.8: 14,
    1.0: 17,
    double.infinity: 18,
  };

  int _shiftOffset = 0;
  int _shiftDuration = 3;
  int? _weekendDuration;
  int _shiftNorm = 12;
  PercentToPayMap _ptpMap = _defaultPTPMap;
  String _currency = "";

  List<DateTime> _customEnabledDates = [];

  final _store = StoreRef<String, dynamic>('settings');

  void _init() {
    _shiftOffset =
        _store.record('shiftOffset').getSync(DB.instance) as int? ?? 0;
    _shiftDuration =
        _store.record('shiftDuration').getSync(DB.instance) as int? ?? 3;
    _weekendDuration =
        _store.record('weekendDuration').getSync(DB.instance) as int?;
    _shiftNorm = _store.record('shiftNorm').getSync(DB.instance) as int? ?? 12;
    _ptpMap =
        _store.record('ptpMap').getSync(DB.instance) as Map<double, int>? ??
            _defaultPTPMap;
    _currency = _store.record('currency').getSync(DB.instance) as String? ?? '';
    final customEnabledDates = _store.record('customEnabledDates').getSync(DB.instance) as Iterable<Object?>?;
    if (customEnabledDates != null) {
      _customEnabledDates = customEnabledDates.map((el) => DateTime.parse(el as String)).toList();
    }

    notifyListeners();
  }

  Settings() {
    _init();
  }

  int get shiftOffset => _shiftOffset;
  int get shiftDuration => _shiftDuration;
  int? get weekendDuration => _weekendDuration;
  int get shiftNorm => _shiftNorm;
  PercentToPayMap get ptpMap => _ptpMap;
  String get currency => _currency;

  List<DateTime> get customEnabledDates => _customEnabledDates;

  set shiftOffset(int val) {
    _shiftOffset = val;

    _store.record('shiftOffset').put(DB.instance, val);
    notifyListeners();
  }

  set shiftDuration(int val) {
    _shiftDuration = val;
    _store.record('shiftDuration').put(DB.instance, val);
    notifyListeners();
  }

  set weekendDuration(int? val) {
    _weekendDuration = val;
    if (val != null) {
      _store.record('weekendDuration').put(DB.instance, val);
    } else {
      _store.record('weekendDuration').delete(DB.instance);
    }
    notifyListeners();
  }

  set shiftNorm(int val) {
    _shiftNorm = val;
    _store.record('shiftNorm').put(DB.instance, val);
    notifyListeners();
  }

  set ptpMap(PercentToPayMap val) {
    _ptpMap = val;
    _store.record('ptpMap').put(DB.instance, val);
    notifyListeners();
  }

  set currency(String val) {
    _currency = val;
    _store.record('currency').put(DB.instance, val);
    notifyListeners();
  }

  set customEnabledDates(List<DateTime> val) {
    _customEnabledDates = val;
    final convertedEnabledDates = val.map((el) => el.toIso8601String()).toList();
    _store.record('customEnabledDates').put(DB.instance, convertedEnabledDates);
    notifyListeners();
  }
}
