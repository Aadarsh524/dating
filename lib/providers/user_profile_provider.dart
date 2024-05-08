import 'dart:convert';
import 'dart:developer';
import 'package:dating/auth/db_client.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider() {
    fetchData();
  }

  UserProfileModel? _currentUserProfile;

  void setCurrentUserProfile(UserProfileModel userProfile) {
    _currentUserProfile = userProfile;
    notifyListeners();
  }

  Future<void> fetchData() async {
    try {
      String uid = await DbClient().getData(dbKey: 'uid');
      final url = Uri.parse('$URI/$USER_PROFILE/$uid');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        log(decoded.toString());
        UserProfileModel userProfileModel = UserProfileModel.fromJson(decoded);
        _currentUserProfile = userProfileModel;
        log("Provider value ${_currentUserProfile!.name}");
        notifyListeners();
      } else {
        log('Failed to fetch data: ${response.statusCode}');
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> updateUserProfile(UserProfileModel updatedProfile) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8001/api/userprofile/${updatedProfile.uid}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedProfile.toJson()),
      );

      if (response.statusCode == 200) {
        _currentUserProfile = updatedProfile;
        notifyListeners();
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      print('Error updating user profile: $error');
    }
  }

  Future<void> updateProfileImage(String base64image, String uid) async {
    try {
      var response = await http.put(
        Uri.parse('http://10.0.2.2:8001/api/userprofile/Image/$uid'),
        body: jsonEncode(base64image),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _currentUserProfile!.image = base64image;
        notifyListeners();
      } else {
        print('Failed to update profile image: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating profile image: $error');
    }
  }

  UserProfileModel? get currentUserProfile => _currentUserProfile;
}
