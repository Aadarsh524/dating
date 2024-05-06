import 'dart:developer';

import 'package:flutter/widgets.dart';

class UserProfileProvider extends ChangeNotifier {
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
}
