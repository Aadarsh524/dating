import 'dart:developer';

import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/platform/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../backend/MongoDB/token_manager.dart';

class ChatMessageProvider extends ChangeNotifier {
  ChatMessageModel? chatMessageModel;

  void setChatMessageProvider(ChatMessageModel chatRoomModel) {
    chatMessageModel = chatRoomModel;
    notifyListeners();
  }

  ChatMessageModel? get userChatMessageModel => chatMessageModel;

  Future<void> sendChat(ChatMessageModel chatSendModel) async {
    try {
      //get api endpoint
      String api = getApiEndpoint();

      //get bearer token
      final token = await TokenManager.getToken();

      //set params for request
      final queryParams = {
        'SenderId': chatSendModel.participants!.first,
        'MessageContent': chatSendModel.messages,
        'ReceiverId': chatSendModel.participants!.last,
      };
      //set params in uri
      final uri =
          Uri.parse("$api/communication").replace(queryParameters: queryParams);

      if (token == null) {
        throw Exception('No token found');
      }

      //send post request
      final request = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(chatSendModel.toJson()));

      //return response
      if (request.statusCode == 200) {
        notifyListeners();
        final responseJson = json.decode(request.body);
        log(responseJson.toString());
      } else {
        throw Exception('Failed to send chat: ${request.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<ChatMessageModel?> getMessage(String chatID) async {
    String api = getApiEndpoint();
    try {
      final uri = Uri.parse("$api/communication/id=$chatID/page=1");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final chatRoomModel = ChatMessageModel.fromJson(jsonData);

        setChatMessageProvider(chatRoomModel);
        notifyListeners();
        return ChatMessageModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
