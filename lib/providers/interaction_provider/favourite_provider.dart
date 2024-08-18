import 'dart:convert';
import 'dart:developer';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/interaction/favourite_model.dart';
import 'package:dating/platform/platform_mobile.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FavouritesProvider extends ChangeNotifier {
  List<FavouriteModel>? _favourites = [];

  List<FavouriteModel>? get favourites => _favourites;

  bool _isFavoriteLoading = false;

  bool get isFavoriteLoading => _isFavoriteLoading;
  bool _isCurrentProfileFavourite = false;
  bool get isCurrentProfileFavourite => _isCurrentProfileFavourite;

  void setFavoriteLoading(bool value) {
    _isFavoriteLoading = value;
    notifyListeners();
  }

  void setFavouriteProvider(List<FavouriteModel> favModel) {
    _favourites = favModel;
    notifyListeners();
  }

  Future<void> addFavourites(String uid, String favoriteUser) async {
    setFavoriteLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/Favourite");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'uid': uid, 'favoriteUser': favoriteUser}),
      );

      if (response.statusCode == 200) {
        _favourites?.add(FavouriteModel(uid: favoriteUser));
        log(_favourites.toString());
        notifyListeners();
      } else {
        throw Exception('Failed to add favourite: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setFavoriteLoading(false);
    }
  }

  Future<List<FavouriteModel>> getFavourites(String userId, int page) async {
    setFavoriteLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/Favourite").replace(queryParameters: {
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
        final favourites =
            data.map((json) => FavouriteModel.fromJson(json)).toList();
        setFavouriteProvider(favourites);
        notifyListeners();
        return favourites;
      } else {
        throw Exception('Failed to fetch favourites: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    } finally {
      setFavoriteLoading(false);
    }
  }

  Future<void> removeFavourites(String uid, String favouriteUser) async {
    setFavoriteLoading(true);
    String api = getApiEndpoint();
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/Favourite");
      final response = await http.delete(
        body: json.encode({'uid': uid, 'favoriteUser': favouriteUser}),
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _favourites?.removeWhere((favourite) => favourite.uid == favouriteUser);
        notifyListeners();
      } else {
        throw Exception('Failed to remove favourite: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setFavoriteLoading(false);
    }
  }

  bool checkIfCurrentProfileIsFavourite(String currentProfileId) {
    if (_favourites != null) {
      _isCurrentProfileFavourite =
          favourites!.any((favourite) => favourite.uid == currentProfileId);
      return _favourites!.any((favourite) => favourite.uid == currentProfileId);
    } else {
      return _isCurrentProfileFavourite;
    }
  }

  Future<void> toggleFavStatus(String currentUser, String favUserId) async {
    if (checkIfCurrentProfileIsFavourite(favUserId)) {
      await removeFavourites(currentUser, favUserId);
    } else {
      await addFavourites(currentUser, favUserId);
    }
  }

  void clearUserData() {
    _favourites = null;
    notifyListeners();
  }
}
