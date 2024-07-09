import 'dart:convert';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import '../../platform/platform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class DashboardProvider extends ChangeNotifier {
  List<DashboardResponseModel>? _dashboardListProvider;
  List<DashboardResponseModel>? get dashboardList => _dashboardListProvider;

  bool _isDashboardLoading = false;
  bool get isDashboardLoading => _isDashboardLoading;

  Future<void> dashboard(int page, BuildContext context) async {
    _isDashboardLoading = true;
    // We're not calling notifyListeners() here

    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
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
      print(e.toString());
      _dashboardListProvider = [];
    } finally {
      _isDashboardLoading = false;
      notifyListeners(); // We only call notifyListeners once, at the end
    }
  }
}
