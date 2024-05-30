import 'dart:convert';

import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/platform/platform.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

import '../../backend/MongoDB/token_manager.dart';

class ChatRoomProvider extends ChangeNotifier {
  ChatRoomModel? userChatRoomModel;

  void setUsersChatRoom(ChatRoomModel chatRoomModel) {
    userChatRoomModel = chatRoomModel;
    notifyListeners();
  }

  ChatRoomModel? get getUserChatRoom => userChatRoomModel;

  Future<ChatRoomModel?> getchatRoom(uid) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/Communication/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(Uri.parse('$api/Communication/$uid'));
      if (response.statusCode == 200) {
        setUsersChatRoom(ChatRoomModel.fromJson(json.decode(response.body)));
        notifyListeners();
        return ChatRoomModel.fromJson(json.decode(response.body));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
