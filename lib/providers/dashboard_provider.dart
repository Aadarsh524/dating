import 'dart:convert';
import 'dart:developer';

import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/utils/platform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DashboardProvider extends ChangeNotifier {
  List<DashboardResponseModel>? _dashboardListProvider;
  List<DashboardResponseModel>? get dashboardList => _dashboardListProvider;

  void setDashboard(List<DashboardResponseModel> dashboardResponseModel) {
    _dashboardListProvider = dashboardResponseModel;
    notifyListeners();
  }

  Future<List<DashboardResponseModel>> dashboard(
      int page, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    context.read<LoadingProvider>().setLoading(true);
    String api = getApiEndpoint();
    try {
      final response = await http.get(
        Uri.parse('$api/Dashboard/$uid&page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
      );
      log(response.body);

      if (response.statusCode == 200) {
        List<DashboardResponseModel> dashboardList = [];
        List<dynamic> data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          dashboardList.add(DashboardResponseModel.fromJson(i));
        }
        setDashboard(dashboardList);
        notifyListeners();

        return dashboardList;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }
}
