import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

Widget ProfileImage() {
  return Consumer<UserProfileProvider>(
    builder: (context, userProfileProvider, _) {
      // Show a loading indicator while the profile is being fetched.
      if (userProfileProvider.isProfileLoading) {
        return const CircularProgressIndicator();
      }

      // Safely check if userProfileModel is null before accessing properties.
      UserProfileModel? userProfileModel =
          userProfileProvider.currentUserProfile;

      // If the profile is null, return a default avatar.
      if (userProfileModel == null ||
          userProfileModel.image == null ||
          userProfileModel.image!.isEmpty) {
        // Use default avatar if user profile or image is not available.
        return _buildProfileImageFromBase64(defaultBase64Avatar);
      }

      // Return the profile image if available.
      return _buildProfileImageFromBase64(userProfileModel.image!);
    },
  );
}

// Helper function to build the profile image from base64 string.
Widget _buildProfileImageFromBase64(String base64String) {
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  final imageBytes = base64ToImage(base64String);
  return Neumorphic(
    style: const NeumorphicStyle(
      boxShape: NeumorphicBoxShape.circle(),
    ),
    child: SizedBox(
      height: 50,
      width: 50,
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      ),
    ),
  );
}
