import 'dart:convert';
import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UserProfileProvider extends ChangeNotifier {
  ApiClient apiClient = ApiClient();

  UserProfileModel? _currentUserProfileProvider;

  void setCurrentUserProfile(UserProfileModel userProfile) {
    _currentUserProfileProvider = userProfile;
    notifyListeners();
  }

  Future<UserProfileModel> addNewUser(
      UserProfileModel userProfile, BuildContext context) async {
    try {
      final UserProfileModel? value =
          await apiClient.postUserProfileDataMobile(userProfile);

      if (value != null) {
        notifyListeners();
        return value;
      } else {
        throw Exception('Cant upload');
      }
    } catch (e) {
      print("error:$e");
      rethrow;
    }
  }

  UserProfileModel? get currentUserProfile => _currentUserProfileProvider;

  Future<UserProfileModel>? getUserData(String uid) async {
    try {
      // Wait for the result of getUserProfileDataMobile using await
      final UserProfileModel? value =
          await apiClient.getUserProfileDataMobile(uid);

      // Check if the value is not null
      if (value != null) {
        // Set the current user profile
        setCurrentUserProfile(value);

        // Notify listeners of the change
        notifyListeners();

        // Return the UserProfileModel
        return value;
      } else {
        // If the value is null, throw an exception
        throw Exception('User profile data is null');
      }
    } catch (error) {
      // Print error message if an error occurs
      print('Error fetching data: $error');
      // Rethrow the error to propagate it to the caller
      rethrow;
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
        _currentUserProfileProvider = updatedProfile;
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
        _currentUserProfileProvider!.image = base64image;
        notifyListeners();
      } else {
        print('Failed to update profile image: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating profile image: $error');
    }
  }
}
