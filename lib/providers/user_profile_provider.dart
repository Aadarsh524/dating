import 'dart:convert';

import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/utils/platform.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UserProfileProvider extends ChangeNotifier {
  UserProfileModel? currentUserProfileModel;

  void setCurrentUserProfile(UserProfileModel userProfile) {
    currentUserProfileModel = userProfile;
    notifyListeners();
  }

  UserProfileModel? get currentUserProfile => currentUserProfileModel;

  Future<UserProfileModel> addNewUser(
      UserProfileModel userProfileModel, BuildContext context) async {
    try {
      String api = getApiEndpoint();
      setCurrentUserProfile(userProfileModel);
      final response = await http.post(
        Uri.parse('$api/user'), // Replace with your API endpoint
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

  Future<UserProfileModel?> getUserData(uid) async {
    try {
      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/User/$uid'),
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
      BuildContext context, UserProfileModel updatedProfile) async {
    try {
      String api = getApiEndpoint();
      String? uid = updatedProfile.uid;
      final url = Uri.parse('$api/userprofile/${updatedProfile.uid}');
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
        getUserData(uid!).then(
          (value) {
            if (value != null) {
              setCurrentUserProfile(value);
              notifyListeners();
            }
          },
        );

        return updatedProfile;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Uploads> uploadPost(
      BuildContext context, newUpload, String uid) async {
    try {
      String api = getApiEndpoint();

      final url = Uri.parse('$api/file?UserID=$uid');
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
        await getUserData(uid).then(
          (value) {
            if (value != null) {
              setCurrentUserProfile(value);
              notifyListeners();
            }
          },
        );
        return newUpload;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> deletePost(String uid) async {
    try {
      String api = getApiEndpoint();

      final url = Uri.parse('$api/file/$uid');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access_token': 'accesstokentest'
        },
      );

      if (response.statusCode == 200) {
        await getUserData(uid).then(
          (value) {
            if (value != null) {
              setCurrentUserProfile(value);
              notifyListeners();
            }
          },
        );
        return true;
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(
      BuildContext context, base64image, String uid) async {
    try {
      String api = getApiEndpoint();

      var response = await http.put(
        Uri.parse('$api/UserProfile/Image/$uid'),
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
              notifyListeners();
            }
          },
        );
      } else {}
    } catch (error) {
      print('Error updating profile image: $error');
    }
  }
}
