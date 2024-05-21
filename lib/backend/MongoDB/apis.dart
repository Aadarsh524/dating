import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../platform/platform.dart';

class ApiClient {
  Future<String?> validateToken() async {
    String api = getApiEndpoint();
    log(api);

    try {
      final response = await http.post(
        Uri.parse('$api/validate'),
        headers: {
          'Content-Type': 'text/plain',
          'Accept': 'text/plain',
          "Authorization": 'Basic apikeyxxx'
        },
        body: '',
      );

      if (response.statusCode == 200) {
        return response.body.toString();
      }
      return '';
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
