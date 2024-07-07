import 'dart:convert';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/datamodel/document_verification_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/platform/platform_mobile.dart';

import 'package:dating/providers/loading_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdminDashboardProvider extends ChangeNotifier {
  List<UserProfileModel>? _usersListProvider;
  List<DocumentVerificationModel>? _documentsVerificationListProvider;

  List<UserProfileModel>? get usersList => _usersListProvider;
  List<DocumentVerificationModel>? get documentsList =>
      _documentsVerificationListProvider;

  void setUsers(List<UserProfileModel> usersList) {
    _usersListProvider = usersList;
    notifyListeners();
  }

  void setDocuments(List<DocumentVerificationModel> documentsList) {
    _documentsVerificationListProvider = documentsList;
    notifyListeners();
  }

  Future<List<UserProfileModel>> fetchUsers(BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$api/admin/dashboard/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<UserProfileModel> userProfileList = [];
        List<dynamic> data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          userProfileList.add(UserProfileModel.fromJson(i));
        }
        setUsers(userProfileList);
        return userProfileList;
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

  Future<List<DashboardResponseModel>> fetchElement(
      BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$api/admin/dashboard/elements'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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

  Future<bool> banUser(String userId, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$api/admin/dashboard/user/ban?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<bool> activateUser(String userId, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$api/admin/dashboard/user/active?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<List<UserProfileModel>> fetchDocuments(BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$api/admin/ApproveDocument'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<UserProfileModel> userProfileList = [];
        List<dynamic> data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          userProfileList.add(UserProfileModel.fromJson(i));
        }
        setUsers(userProfileList);
        return userProfileList;
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

  Future<bool> approveDocument(
      String userId, int approvalStatus, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(
            '$api/admin/ApproveDocument?userId=$userId&approvalStatus=$approvalStatus'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<DocumentVerificationModel?> fetchDocumentById(
      String userId, String id, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('$api/admin/ApproveDocument/$id?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body.toString());
        return DocumentVerificationModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }
}
