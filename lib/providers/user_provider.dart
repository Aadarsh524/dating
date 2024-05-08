import 'dart:developer';

import 'package:dating/auth/db_client.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    // Call getLocalData() when the UserProvider is instantiated
    getLocalData();
  }

  Future<void> getLocalData() async {
    _userName = await DbClient().getData(dbKey: "userName") ?? '';
    _userEmail = await DbClient().getData(dbKey: "email") ?? '';
    _userID = await DbClient().getData(dbKey: "uid") ?? '';
    _gender = await DbClient().getData(dbKey: "gender") ?? '';

    log(_userName);

    // Notify listeners after data is fetched
    log('data is fetchehd');
    notifyListeners();
  }

  String _userName = '';
  String _userEmail = '';
  String _userID = '';
  String _gender = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userID => _userID;
  String get gender => _gender;

  void addCurrentUser(String name, String email, String uid, String gender) {
    _userName = name;
    _userEmail = email;
    _userID = uid;
    _gender = gender;
    notifyListeners();
    log("added");
  }

  updateName(String name) {
    _userName = name;
    notifyListeners();
    return _userName;
  }
}
