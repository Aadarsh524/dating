import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class DbClient {
  setData({required String dbKey, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dbKey, value);
  }

  Future removeData({required String dbkey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dbkey);
  }

  Future getData({required var dbKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(dbKey);
    return result ?? '';
  }
   Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data
    print('All data cleared');
  }

  resetData({required String dbKey}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
