import 'dart:convert';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

class UploadsProvider extends ChangeNotifier {
  Uploads? uploads;
  Future<Uploads> uploadPost(Uploads newUpload, String uid) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8001/api/File/$uid');
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
        notifyListeners();
        return newUpload;
      } else {
        throw Exception('Failed to update user post');
      }
    } catch (error) {
      rethrow;
    }
  }
}
