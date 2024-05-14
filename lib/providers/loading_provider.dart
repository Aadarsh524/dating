import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }
}
