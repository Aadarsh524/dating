import 'dart:convert';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/platform/platform_mobile.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CallProvider extends ChangeNotifier {
  Future<bool> createRoom(
      String roomId,
      Map<String, dynamic> offer,
      String callerCandidateUid,
      String calleeCandidateUid,
      BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$api/api/Call/createRoom'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'roomId': roomId,
          'offer': offer,
          'callerCandidateUid': callerCandidateUid,
          'calleeCandidateUid': calleeCandidateUid,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<bool> updateRoom(
      String roomId, String sdp, String type, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$api/api/Call/room/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sdp': sdp,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<bool> addIceCandidate(String roomId, bool isCaller, String candidate,
      String sdpMid, int sdpMLineIndex, BuildContext context) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    context.read<LoadingProvider>().setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$api/api/Call/addIceCandidate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'roomId': roomId,
          'isCaller': isCaller,
          'candidate': candidate,
          'sdpMid': sdpMid,
          'sdpMLineIndex': sdpMLineIndex,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }
}
