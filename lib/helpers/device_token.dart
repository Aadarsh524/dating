import 'dart:convert';
import 'package:dating/platform/platform.dart';
import 'package:http/http.dart' as http;

// Function to POST device token
Future<bool> postDeviceToken(String uid, String deviceToken) async {
  String api = getApiEndpoint();

  final String url = '$api/DeviceToken';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'uid': uid,
      'deviceToken': deviceToken,
    }),
  );

  if (response.statusCode == 200) {
    // Successfully posted the device token
    return true;
  } else {
    // Handle errors
    print('Failed to post device token: ${response.body}');
    return false;
  }
}

// Function to GET device token by ID
Future<String?> getDeviceTokenFromDb(String id) async {
  String api = getApiEndpoint();

  final String url = '$api/DeviceToken?id=$id';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Parse the response body
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['deviceToken'];
  } else {
    // Handle errors
    print('Failed to get device token: ${response.body}');
    return null;
  }
}
