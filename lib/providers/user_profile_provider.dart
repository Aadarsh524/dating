import 'dart:convert';
import 'package:dating/datamodel/user_profile_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UserProfileProvider extends ChangeNotifier {
  UserProfileModel? _currentUserProfile;

  UserProfileModel? get currentUser => _currentUserProfile;

  void setCurrentUserProfile(UserProfileModel userProfile) {
    _currentUserProfile = userProfile;
    notifyListeners();
  }

  UserProfileModel? getCurrentUserProfile() {
    return _currentUserProfile;
  }

  Future<void> updateUserProfile(UserProfileModel updatedProfile) async {
    // Make HTTP request to save updated profile
    final url =
        Uri.parse('http://10.0.2.2:8001/api/userprofile/${updatedProfile.uid}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedProfile.toJson()),
    );

    if (response.statusCode == 200) {
      // Update local profile with updated data
      _currentUserProfile = updatedProfile;
      print(_currentUserProfile!.name);
      print(_currentUserProfile!.name);
      print(_currentUserProfile!.name);
      print(_currentUserProfile!.name);
      print(_currentUserProfile!.name);

      notifyListeners();
    } else {
      throw Exception('Failed to update user profile');
    }
  }

  Future<void> updateProfileImage(String base64image, String uid) async {
    try {
      // Convert UserProfileModel to a Map

      // Make the HTTP request to update the user profile with image
      var response = await http.put(
        Uri.parse('http://10.0.2.2:8001/api/userprofile/Image/$uid'),
        body: jsonEncode(base64image),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Update the local state or notify listeners if necessary

        _currentUserProfile!.image = base64image;
        notifyListeners();
      } else {
        // Handle the case where the request was not successful
        print('Failed to update profile image: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error updating profile image: $error');
    }
  }
}
