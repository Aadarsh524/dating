import 'dart:convert';

import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/platform/platform.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

import '../../backend/MongoDB/token_manager.dart';

class ChatRoomProvider extends ChangeNotifier {
  Future<ChatRoomModel?> chatRoomProvider(ChatRoomModel chatRoomModel, String uid) async {
    String api = getApiEndpoint();
    final token = await TokenManager.getToken();
    final uri = Uri.parse("$api/communication/id=$uid");

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer '
    });
    if (response.statusCode == 200) {
      return ChatRoomModel.fromJson(jsonDecode(response.toString()));
    }
  }
}
