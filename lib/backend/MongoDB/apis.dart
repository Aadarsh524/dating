import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../platform/platform.dart';
import 'dart:convert';

class ApiClient {
  Future<String?> validateToken() async {
    String api = getApiEndpoint();
    log('API Endpoint: $api');

    final url = Uri.parse('$api/validate');
    log('Full URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Basic apikeyxxx'
        },
        body: json.encode({}), // Send an empty JSON object if no body is needed
      );

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        log('Non-200 status code received');
        return null;
      }
    } catch (e) {
      log('Error in validateToken: $e');

      rethrow; // Rethrow the exception for the caller to handle
    }
  }
}
