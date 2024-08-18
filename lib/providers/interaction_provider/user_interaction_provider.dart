import 'package:dating/datamodel/interaction/user_interaction_model.dart';
import 'package:dating/datamodel/interaction/user_match_model.dart';
import 'package:dating/platform/platform_mobile.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/MongoDB/token_manager.dart';
import 'package:flutter/material.dart';

class UserInteractionProvider extends ChangeNotifier {
  UserInteractionModel? userInteractionModel;

  List<UserMatchesModel>? userMatchesModel;

  void setUserMatchesProvider(List<UserMatchesModel> model) {
    userMatchesModel = model;
    notifyListeners();
  }

  List<UserMatchesModel>? get getUserMatchModel => userMatchesModel;

  bool _isInteractionLoading = false;

  bool get isInteractionLoading => _isInteractionLoading;

  Future<void> setInteractionLoading(bool value) async {
    _isInteractionLoading = value;
    notifyListeners();
  }

  void setUserInteractionProvider(UserInteractionModel model) {
    userInteractionModel = model;
    notifyListeners();
  }

  UserInteractionModel? get getUserInteractionModel => userInteractionModel;

  bool isUserLiked(String userId) {
    if (userInteractionModel == null) return false;
    if (userInteractionModel != null &&
        userInteractionModel!.likedUsers == null) return false;

    return userInteractionModel!.likedUsers!
        .any((likedUser) => likedUser.uid == userId);
  }

  Future<UserInteractionModel?> getUserInteraction(String userId) async {
    setInteractionLoading(true);
    try {
      String api = getApiEndpoint();
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/UserInteraction").replace(queryParameters: {
        'userId': userId,
      });

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final userInteractionModel =
            UserInteractionModel.fromJson(json.decode(response.body));
        setUserInteractionProvider(userInteractionModel);
        notifyListeners();
        return userInteractionModel;
      } else {
        throw Exception(
            'Failed to load user interaction: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<List<UserMatchesModel>?> getUserMatches(String userId) async {
    setInteractionLoading(true);
    try {
      String api = getApiEndpoint();
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/UserMatch/$userId&page=1");
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final userMatchesList =
            UserMatchesResponseModel.fromJson(json.decode(response.body));
        setUserMatchesProvider(userMatchesList.userMatches!);
        notifyListeners();
        return userMatchesList.userMatches;
      } else {
        throw Exception(
            'Failed to load user interaction: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<LikedByUsers?> fetchLikesByUser(String userId, int page) async {
    setInteractionLoading(true);
    try {
      String api =
          getApiEndpoint(); // Replace with your actual API endpoint getter
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/like/$userId&page=$page");

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final likedByUsers = LikedByUsers.fromJson(json.decode(response.body));
        return likedByUsers;
      } else {
        throw Exception(
            'Failed to fetch likes by user: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<LikedUsers?> fetchLikedByUser(String userId, int page) async {
    setInteractionLoading(true);
    try {
      String api =
          getApiEndpoint(); // Replace with your actual API endpoint getter
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/liked/$userId&page=$page");

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final likeUserModel = LikedUsers.fromJson(json.decode(response.body));
        return likeUserModel;
      } else {
        throw Exception(
            'Failed to fetch liked by user: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<MutualLikes?> fetchMutualLikes(String userId, int page) async {
    setInteractionLoading(false);
    try {
      String api =
          getApiEndpoint(); // Replace with your actual API endpoint getter
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/like/mutual/$userId&page=$page");

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final mutualLikedModel =
            MutualLikes.fromJson(json.decode(response.body));
        return mutualLikedModel;
      } else {
        throw Exception('Failed to fetch mutual likes: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<void> likeUser(String userId, String likedUserId) async {
    setInteractionLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/UserInteraction/api/Like");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': userId, 'likedUserId': likedUserId}),
      );

      if (response.statusCode == 200) {
        userInteractionModel?.likedUsers?.add(LikedUsers(uid: likedUserId));
        notifyListeners();
      } else {
        throw Exception('Failed to like user: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<void> unlikeUser(String userId, String likedUserId) async {
    setInteractionLoading(false);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/UserInteraction/api/like");
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': userId, 'likedUserId': likedUserId}),
      );

      if (response.statusCode == 200) {
        userInteractionModel?.likedUsers
            ?.removeWhere((user) => user.uid == likedUserId);
        notifyListeners();
      } else {
        throw Exception('Failed to unlike user: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setInteractionLoading(false);
    }
  }

  Future<void> toggleLikeStatus(
      String currentUserId, String likedUserId) async {
    if (isUserLiked(likedUserId)) {
      await unlikeUser(currentUserId, likedUserId);
    } else {
      await likeUser(currentUserId, likedUserId);
    }
    await getUserInteraction(currentUserId); // Refresh the liked users list
  }

  // Other methods and properties...

  Future<bool> checkMutualLikes(String userId, String likedUserId) async {
    // Fetch user interaction data for the current user
    final UserInteractionModel? userInteraction =
        await getUserInteraction(userId);

    if (userInteraction == null) {
      return false; // No user interaction data found
    }

    // Get the mutual likes list from the user interaction model
    final List<MutualLikes>? mutualLikes = userInteraction.mutualLikes;

    if (mutualLikes == null || mutualLikes.isEmpty) {
      return false; // No mutual likes found
    }

    try {
      // Check if the likedUserId exists in the mutual likes list
      mutualLikes.firstWhere((mutualLike) => mutualLike.uid == likedUserId);
      return true; // User found in mutual likes
    } catch (e) {
      return false; // User not found in mutual likes
    }
  }

  void clearUserData() {
    userInteractionModel = null;
    userMatchesModel = null;
    notifyListeners();
  }
}
