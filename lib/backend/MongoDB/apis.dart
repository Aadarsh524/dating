import 'dart:convert';
import 'dart:developer';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/utils/platform.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Future postDataMobile(
      {required String endpoint, required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.post(endpoint, data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future postDataDesktop(
      {required String endpoint, required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.post(endpoint, data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future getDataMobile({required String endpoint, required String uid}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.get('$endpoint/$uid');

      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  Future getDataDesktop({required String endpoint, required String uid}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.get('$endpoint/$uid');
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future updateDataMobile(
      {required String endpoint,
      required String uid,
      required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.put('$endpoint/$uid', data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future updateDataDesktop(
      {required String endpoint,
      required String uid,
      required Map<String, dynamic> data}) async {
    final Dio dio = Dio(BaseOptions(baseUrl: URI_DESKTOP, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }));
    try {
      final result = await dio.put('$endpoint/$uid', data: data);
      return result.data;
    } catch (e) {
      return e.toString();
    }
  }

  Future<UserProfileModel>? postUserProfileDataMobile(
      UserProfileModel userProfileModel) async {
    final response = await http.post(
      Uri.parse('$URI/user'), // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'access_token': 'accesstokentest'
      },

      body: jsonEncode(userProfileModel.toJson()),
    );
    if (response.statusCode == 200) {
      return userProfileModel;
    }
    return userProfileModel;
  }

  Future<UserProfileModel?> getUserProfileDataMobile(String uid) async {
    final response = await http.get(
      Uri.parse('$URI/User/$uid'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'access_token': 'accesstokentest'
      },
    );
    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> addUserMediaDataMobile(String base64Image, String user) async {
    final response = await http.post(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'access_token': 'accesstokentest'
      },
      Uri.parse(
          '$URI/UserProfile/Image/$user.uid'), // Replace with your API endpoint
      body: jsonEncode(base64Image),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<DashboardResponseModel> dashboard(String uid, int page) async {
    String api = getApiEndpoint();
    print(api);

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

      // Parse the JSON response as a list
      List<dynamic> jsonList = json.decode(response.body);

      // Handle the case where the list is empty
      if (jsonList.isEmpty) {
        // Return an empty DashboardResponseModel
        return DashboardResponseModel(data: []);
      } else {
        // Convert the list to DashboardResponseModel
        return DashboardResponseModel.fromList(jsonList);
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
