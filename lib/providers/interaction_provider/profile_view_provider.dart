import 'dart:convert';
import 'dart:developer';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/interaction/profile_view_model.dart';
import 'package:dating/platform/platform_mobile.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileViewProvider extends ChangeNotifier {
  List<ProfileViewModel>? _visitedMyProfiles = [];
  List<ProfileViewModel>? _viewedProfiles = [];

  List<ProfileViewModel>? get visitedMyProfiles => _visitedMyProfiles;
  List<ProfileViewModel>? get viewedProfiles => _viewedProfiles;

  bool _isProfileViewLoading = false;
  bool get isProfileViewLoading => _isProfileViewLoading;

  void setLoading(bool value) {
    _isProfileViewLoading = value;
    notifyListeners();
  }

  void setVisitedMyProfile(List<ProfileViewModel> profiles) {
    _visitedMyProfiles = profiles;
    notifyListeners();
  }

  void setViewByMeProfiles(List<ProfileViewModel> profiles) {
    _viewedProfiles = profiles;
    notifyListeners();
  }

  Future<List<ProfileViewModel>> getWhoVisitedMyProfile(
      String userId, int page) async {
    setLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri =
          Uri.parse("$api/ProfileView/visited").replace(queryParameters: {
        'userId': userId,
        'page': page.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final visitedMyProfiles =
            data.map((json) => ProfileViewModel.fromJson(json)).toList();
        setVisitedMyProfile(visitedMyProfiles);
        return visitedMyProfiles;
      } else {
        throw Exception(
            'Failed to fetch viewed profiles: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<List<ProfileViewModel>> getProfileWhomIViewed(
      String userId, int page) async {
    setLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri =
          Uri.parse("$api/ProfileView/viewed").replace(queryParameters: {
        'userId': userId,
        'page': page.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final viewedProfiles =
            data.map((json) => ProfileViewModel.fromJson(json)).toList();
        setViewByMeProfiles(viewedProfiles);
        return viewedProfiles;
      } else {
        throw Exception(
            'Failed to fetch visited profiles: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> addProfileView(String uid, String seenUser) async {
    setLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/ProfileView");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'uid': uid, 'seenUser': seenUser}),
      );

      if (response.statusCode == 200) {
        log('Profile view added successfully');
        // You can add additional logic here if needed
      } else {
        throw Exception('Failed to add profile view: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearUserData() {
    _visitedMyProfiles = null;
    _viewedProfiles = null;
    notifyListeners();
  }
}
