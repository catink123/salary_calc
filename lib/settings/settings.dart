import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late final SharedPreferences sharedPrefs;

  Future<void> _initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();

    _shiftOffset = sharedPrefs.getInt("shiftOffset") ?? 0;
    _shiftDuration = sharedPrefs.getInt("shiftDuration") ?? 3;
    _weekendDuration = sharedPrefs.getInt("weekendDuration");
    _shiftNorm = sharedPrefs.getInt("shiftNorm") ?? 12;
    final ptpMapJson = sharedPrefs.getString("ptpMap");
    if (ptpMapJson != null) {
      _ptpMap = jsonDecode(ptpMapJson);
    } else {
      _ptpMap = _defaultPTPMap;
    }
    _currency = sharedPrefs.getString("currency") ?? '';

    notifyListeners();
  }

  Settings() {
    _initSharedPrefs();
  }

  int get shiftOffset => _shiftOffset;
  int get shiftDuration => _shiftDuration;
  int? get weekendDuration => _weekendDuration;
  int get shiftNorm => _shiftNorm;
  PercentToPayMap get ptpMap => _ptpMap;
  String get currency => _currency;

  set shiftOffset(int val) {
    _shiftOffset = val;
    sharedPrefs.setInt("shiftOffset", val);
    notifyListeners();
  }

  set shiftDuration(int val) {
    _shiftDuration = val;
    sharedPrefs.setInt("shiftDuration", val);
    notifyListeners();
  }

  set weekendDuration(int? val) {
    _weekendDuration = val;
    if (val != null) {
      sharedPrefs.setInt("weekendDuration", val);
    } else {
      sharedPrefs.remove("weekendDuration");
    }
    notifyListeners();
  }

  set shiftNorm(int val) {
    _shiftNorm = val;
    sharedPrefs.setInt("shiftNorm", val);
    notifyListeners();
  }

  set ptpMap(PercentToPayMap val) {
    _ptpMap = val;
    sharedPrefs.setString("ptpMap", jsonEncode(val));
    notifyListeners();
  }

  set currency(String val) {
    _currency = val;
    sharedPrefs.setString("currency", val);
    notifyListeners();
  }
}
