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

  bool _showMNP = true;
  bool _showEstimatedSalary = true;

  final _store = StoreRef<String, dynamic>('settings');

  RecordRef<String, dynamic> _getRecord(String key) {
    return _store.record(key);
  }

  dynamic _get(String key) {
    return _getRecord(key).getSync(DB.instance);
  }

  void _put(String key, dynamic val) {
    _getRecord(key).put(DB.instance, val);
  }

  void _init() {
    _shiftOffset = _get('shiftOffset') as int? ?? 0;
    _shiftDuration = _get('shiftDuration') as int? ?? 3;
    _weekendDuration = _get('weekendDuration') as int?;
    _shiftNorm = _get('shiftNorm') as int? ?? 12;
    _ptpMap = _get('ptpMap') as Map<double, int>? ?? _defaultPTPMap;
    _currency = _get('currency') as String? ?? '';
    final customEnabledDates = _get('customEnabledDates') as Iterable<Object?>?;
    if (customEnabledDates != null) {
      _customEnabledDates = customEnabledDates.map((el) => DateTime.parse(el as String)).toList();
    }
    _showMNP = _get('showMNP') as bool? ?? true;
    _showEstimatedSalary = _get('showEstimatedSalary') as bool? ?? true;

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

  bool get showMNP => _showMNP;
  bool get showEstimatedSalary => _showEstimatedSalary;

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

  set showMNP(bool val) {
    _showMNP = val;
    _put('showMNP', val);
    notifyListeners();
  }

  set showEstimatedSalary(bool val) {
    _showEstimatedSalary = val;
    _put('showEstimatedSalary', val);
    notifyListeners();
  }
}
