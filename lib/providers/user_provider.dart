import 'dart:developer';

import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  String _userID = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userID => _userID;

  void addCurrentUser(String name, String email, String uid) {
    _userName = name;
    _userEmail = email;
    _userID = uid;
    notifyListeners();
    log("added");
  }
}
