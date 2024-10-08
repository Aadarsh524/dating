import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/admin/approve_document_model.dart';
import 'package:dating/datamodel/complaint/complaint_filter_model.dart';
import 'package:dating/datamodel/complaint/complaint_model.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/datamodel/document_verification_model.dart';
import 'package:dating/datamodel/admin/admin_subscription_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/platform/platform_mobile.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AdminDashboardProvider extends ChangeNotifier {
  bool _isAdminDataLoading = false;
  bool get isAdminDataLoading => _isAdminDataLoading;
  Future<void> setAdminLoading(bool value) async {
    _isAdminDataLoading = value;
    notifyListeners();
  }

  List<UserProfileModel>? _usersListProvider;
  List<UserProfileModel>? get usersList => _usersListProvider;
  void setUsers(List<UserProfileModel> usersList) {
    _usersListProvider = usersList;
    notifyListeners();
  }

  List<AdminSubscriptionModel>? _userSubscriptionList;
  List<AdminSubscriptionModel>? get userSubscriptionList =>
      _userSubscriptionList;
  void setUserSubscriptionList(List<AdminSubscriptionModel> usersList) {
    _userSubscriptionList = usersList;
    notifyListeners();
  }

  List<DocumentVerificationModel>? _documentsVerificationListProvider;
  List<DocumentVerificationModel>? get documentsList =>
      _documentsVerificationListProvider;
  void setDocumentsVerification(List<DocumentVerificationModel> documentsList) {
    _documentsVerificationListProvider = documentsList;
    notifyListeners();
  }

  List<ComplaintModel>? _usersComplaintProvider;
  List<ComplaintModel>? get usersComplainList => _usersComplaintProvider;
  void setUserComplaints(List<ComplaintModel> usersList) {
    _usersComplaintProvider = usersList;
    notifyListeners();
  }

  ApproveDocumentModel? _approveDocumentProvider;
  ApproveDocumentModel? get approvedocuments => _approveDocumentProvider;
  void setApproveDocument(ApproveDocumentModel documentsList) {
    _approveDocumentProvider = documentsList;
    notifyListeners();
  }

  Future<List<UserProfileModel>> fetchUsers(
      int page, BuildContext context) async {
    try {
      log('Fetching users - start');
      setAdminLoading(true);

      String api;
      try {
        api = getApiEndpoint();
        log('API endpoint: $api');
      } catch (e) {
        log('Error getting API endpoint: $e');
        api = 'http://localhost:8001/api'; // Fallback to a default value
      }

      final token = await TokenManager.getToken();
      if (token == null) {
        log('No token found');
        throw Exception('No token found');
      }
      log('Token retrieved successfully');

      final url =
          Uri.parse('$api/admin/dasboard/users').replace(queryParameters: {
        'page': page.toString(),
      });
      log('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<UserProfileModel> userProfileList = [];
        List<dynamic> data = jsonDecode(response.body);

        for (var i in data) {
          userProfileList.add(UserProfileModel.fromJson(i));
        }

        log('Parsed ${userProfileList.length} user profiles');
        setUsers(userProfileList);
        return userProfileList;
      } else {
        log('Error response: ${response.body}');
        throw HttpException('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in fetchUsers: ${e.toString()}');
      rethrow;
    } finally {
      setAdminLoading(false);
      notifyListeners(); // Make sure this is uncommented if you're using ChangeNotifier
    }
  }

  Future<List<AdminSubscriptionModel>> fetchUserSubscription(int page) async {
    try {
      setAdminLoading(true);

      String api;
      try {
        api = getApiEndpoint();
        log('API endpoint: $api');
      } catch (e) {
        log('Error getting API endpoint: $e');
        api = 'http://localhost:8001/api'; // Fallback to a default value
      }

      final token = await TokenManager.getToken();
      if (token == null) {
        log('No token found');
        throw Exception('No token found');
      }
      log('Token retrieved successfully');

      final url =
          Uri.parse('$api/admin/subscriptions').replace(queryParameters: {
        'page': page.toString(),
      });

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<AdminSubscriptionModel> userSubscriptionList = [];
        List<dynamic> data = jsonDecode(response.body);

        for (var i in data) {
          userSubscriptionList.add(AdminSubscriptionModel.fromJson(i));
        }

        log('Parsed ${userSubscriptionList.length} user profiles');
        setUserSubscriptionList(userSubscriptionList);
        return userSubscriptionList;
      } else {
        log('Error response: ${response.body}');
        throw HttpException('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in fetchUsers: ${e.toString()}');
      rethrow;
    } finally {
      setAdminLoading(false);
      notifyListeners(); // Make sure this is uncommented if you're using ChangeNotifier
    }
  }

  Future<List<DashboardResponseModel>> fetchElement(
      BuildContext context) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

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
      setAdminLoading(false);
    }
  }

  Future<bool> banUser(String userId) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

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
      setAdminLoading(true);
    }
  }

  Future<bool> activateUser(String userId, BuildContext context) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

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
      setAdminLoading(false);
    }
  }

  Future<List<ComplaintModel>> fetchComplaints(
      ComplaintFilterModel complaintModel, BuildContext context) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse('$api/admin/complains'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<ComplaintModel> userComplainList = [];
        List<dynamic> data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          userComplainList.add(ComplaintModel.fromJson(i));
        }
        setUserComplaints(userComplainList);
        return userComplainList;
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      setAdminLoading(true);
    }
  }

  Future<bool> sendApprovalStatus(
      BuildContext context, userId, int approvalStatus) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

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
        fetchUsers(1, context);
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      setAdminLoading(false);
    }
  }

  Future<ApproveDocumentModel?> fetchDocumentById(String userId) async {
    setAdminLoading(true);

    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$api/admin/ApproveDocument/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData'); // Log the response data

        final approveDocumentModel =
            ApproveDocumentModel.fromJson(responseData);
        setApproveDocument(approveDocumentModel);
        notifyListeners();
        return approveDocumentModel;
      } else {
        print('Failed to fetch document: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching document: $e');
      rethrow;
    } finally {
      setAdminLoading(false);
    }
  }

  void clearUserData() {
    _usersListProvider = null;
    _userSubscriptionList = null;
    _documentsVerificationListProvider = null;
    _usersComplaintProvider = null;
    _approveDocumentProvider = null;
    notifyListeners();
  }
}
