import 'dart:convert';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/document_verification_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import '../../platform/platform.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UserProfileProvider extends ChangeNotifier {
  UserProfileModel? currentUserProfileModel;

  bool _isProfileLoading = false;

  bool get isProfileLoading => _isProfileLoading;

  Future<void> setProfileLoading(bool value) async {
    _isProfileLoading = value;
    notifyListeners();
  }

  void setCurrentUserProfile(UserProfileModel userProfile) {
    currentUserProfileModel = userProfile;
    notifyListeners();
  }

  UserProfileModel? get currentUserProfile => currentUserProfileModel;

  Future<UserProfileModel> addNewUser(UserProfileModel userProfileModel) async {
    setProfileLoading(true);
    try {
      String api = getApiEndpoint();

      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      setCurrentUserProfile(userProfileModel);
      final response = await http.post(
        Uri.parse('$api/user'), // Replace with your API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
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
    } finally {
      setProfileLoading(false);
    }
  }

  Future<bool> uploadDocumentsForVerification(
      DocumentVerificationModel documentVerificationModel) async {
    setProfileLoading(true);
    try {
      String api = getApiEndpoint();
      final response = await http.post(
        Uri.parse("$api/UserDocument"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(documentVerificationModel.toJson()),
      );
      if (response.statusCode == 200) {
        getUserProfile(documentVerificationModel.uid);
        notifyListeners();
        return true;
      } else {
        print('Not sent for approval');
        throw Exception('Cant upload data');
      }
    } catch (e) {
      rethrow;
    } finally {
      setProfileLoading(false);
    }
  }

  Future<UserProfileModel?> getUserProfile(uid) async {
    setProfileLoading(true);
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/UserProfile/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final userProfile =
            UserProfileModel.fromJson(json.decode(response.body));
        setCurrentUserProfile(userProfile); // Add this line
        notifyListeners();
        return userProfile;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    } finally {
      setProfileLoading(false);
    }
  }

  Future<UserProfileModel> updateUserProfile(
      UserProfileModel updatedProfile) async {
    setProfileLoading(true);
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();
      String? uid = updatedProfile.uid;
      final url = Uri.parse('$api/userprofile/${updatedProfile.uid}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedProfile.toJson()),
      );

      if (response.statusCode == 200) {
        getUserProfile(uid!).then(
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
    } finally {
      setProfileLoading(false);
    }
  }

  Future<Uploads> uploadPost(newUpload, String uid) async {
    setProfileLoading(true);
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();

      final url = Uri.parse('$api/file?UserID=$uid');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newUpload.toJson()),
      );

      if (response.statusCode == 200) {
        await getUserProfile(uid).then(
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
    } finally {
      setProfileLoading(false);
    }
  }

  Future<bool> deletePost(String uid) async {
    setProfileLoading(true);
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();

      final url = Uri.parse('$api/file/$uid');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await getUserProfile(uid).then(
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
    } finally {
      setProfileLoading(false);
    }
  }

  Future<void> updateProfileImage(base64image, String uid) async {
    setProfileLoading(true);
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();

      var response = await http.put(
        Uri.parse('$api/UserProfile/Image/$uid'),
        body: jsonEncode(base64image.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        getUserProfile(uid).then(
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
    } finally {
      setProfileLoading(false);
    }
  }
}
