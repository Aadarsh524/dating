import 'dart:convert';
import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'package:dating/backend/MongoDB/constants.dart';

class UserProfileProvider extends ChangeNotifier {
  ApiClient apiClient = ApiClient();

  UserProfileModel? _currentUserProfileProvider;

  void setCurrentUserProfile(UserProfileModel userProfile) {
    _currentUserProfileProvider = userProfile;
    notifyListeners();
  }

  UserProfileModel? get currentUserProfile => _currentUserProfileProvider;

  Future<UserProfileModel> addNewUser(
      UserProfileModel userProfileModel, BuildContext context) async {
    try {
      setCurrentUserProfile(userProfileModel);
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
        setCurrentUserProfile(userProfileModel);
        notifyListeners();
        return userProfileModel;
      } else {
        throw Exception('Cant upload data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel?> getUserData(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$URI/User/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
      );
      if (response.statusCode == 200) {
        notifyListeners();
        return UserProfileModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel> updateUserProfile(
      UserProfileModel updatedProfile) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8001/api/userprofile/${updatedProfile.uid}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
        body: jsonEncode(updatedProfile.toJson()),
      );

      if (response.statusCode == 200) {
        setCurrentUserProfile(updatedProfile);
        notifyListeners();
        return updatedProfile;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Uploads> uploadPost(Uploads newUpload, String uid) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8001/api/file');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
        body: jsonEncode(newUpload.toJson()),
      );

      if (response.statusCode == 200) {
        getUserData(uid);
        notifyListeners();
        return newUpload;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(String base64image, String uid) async {
    try {
      var response = await http.put(
        Uri.parse('http://10.0.2.2:8001/api/UserProfile/Image/$uid'),
        body: jsonEncode(base64image.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
      );

      if (response.statusCode == 200) {
        getUserData(uid).then(
          (value) {
            if (value != null) {
              setCurrentUserProfile(value);
            }
          },
        );
        notifyListeners();
      } else {}
    } catch (error) {
      print('Error updating profile image: $error');
    }
  }
}
