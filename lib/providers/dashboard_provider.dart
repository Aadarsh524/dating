import 'dart:convert';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import '../../platform/platform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  bool _isDashboardLoading = false;
  List<DashboardResponseModel> _dashboardListProvider = [];

  bool get isDashboardLoading => _isDashboardLoading;
  List<DashboardResponseModel> get dashboardList => _dashboardListProvider;

  Future<void> dashboard(int page, BuildContext context) async {
    _isDashboardLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is logged in');
    }
    String uid = user.uid;
    String api = getApiEndpoint();

    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$api/Dashboard/$uid&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _dashboardListProvider =
            data.map((i) => DashboardResponseModel.fromJson(i)).toList();
      } else {
        _dashboardListProvider = [];
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      _dashboardListProvider = [];
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _dashboardListProvider.clear();
    notifyListeners();
  }
}
