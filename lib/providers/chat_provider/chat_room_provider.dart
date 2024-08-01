import 'dart:convert';

import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/platform/platform.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;

import '../../backend/MongoDB/token_manager.dart';

class ChatRoomProvider extends ChangeNotifier {
  ChatRoomModel? _userChatRoomModel;

  bool _isChatRoomLoading = false;

  bool get isChatRoomLoading => _isChatRoomLoading;

  Future<void> setChatRoomLoading(bool value) async {
    _isChatRoomLoading = value;
    notifyListeners();
  }

  void setChatRoomProvider(ChatRoomModel chatRoomModel) {
    _userChatRoomModel = chatRoomModel;
    notifyListeners();
  }

  ChatRoomModel? get userChatRoomModel => _userChatRoomModel;

  Future<void> fetchChatRoom(BuildContext context, uid) async {
    setChatRoomLoading(true);
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/Communication/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final chatRoomModel = ChatRoomModel.fromJson(jsonData);

        setChatRoomProvider(chatRoomModel);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch chat room: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to handle it in the caller
    } finally {
      setChatRoomLoading(false);
    }
  }

  Future<String?> fetchChatRoomToCheckUser(
      BuildContext context, String uid, String ouid) async {
    setChatRoomLoading(true);
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/Communication/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return null; // Return null if response body is empty
        }

        final jsonData = json.decode(response.body);
        if (jsonData == null) {
          return null; // Return null if jsonData is null
        }

        final chatRoomModel = ChatRoomModel.fromJson(jsonData);

        // Check if the conversations list is empty
        if (chatRoomModel.conversations == null ||
            chatRoomModel.conversations!.isEmpty) {
          return null; // Return null if there are no conversations
        }

        Conversations? userConversation;
        for (var conversation in chatRoomModel.conversations!) {
          if (conversation.endUserId == ouid) {
            userConversation = conversation;
            break;
          }
        }
        if (userConversation != null) {
          return userConversation.chatId;
        }

        setChatRoomProvider(chatRoomModel);
        notifyListeners();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      rethrow; // Rethrow the exception to handle it in the caller
    } finally {
      setChatRoomLoading(false);
    }
  }

  void clearUserData() {
    _userChatRoomModel = null;
    notifyListeners();
  }
}
