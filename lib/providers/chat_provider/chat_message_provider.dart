import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';

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

  Future<void> sendChat(
      SendMessageModel sendMessageModel, String chatID, String uid) async {
    try {
      // Get API endpoint
      String api = getApiEndpoint();

      // Get bearer token
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No token found');
      }

      // Set params in uri
      final uri = Uri.parse("$api/communication");

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['SenderId'] = sendMessageModel.senderId.toString();
      request.fields['MessageContent'] =
          sendMessageModel.messageContent.toString();
      request.fields['ReceiverId'] = sendMessageModel.receiverId.toString();

      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        await getMessage(chatID, uid);
      } else {
        throw Exception('Failed to send chat: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<ChatMessageModel?> getMessage(String chatID, String uid) async {
    String api = getApiEndpoint();

    try {
      var headers = {'Content-Type': 'application/json'};
      var requestUrl = Uri.parse('$api/Communication/$chatID/page=1');

      var request = http.Request('GET', requestUrl)
        ..headers.addAll(headers)
        ..body = json.encode(uid).toString();

      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final chatRoomModel = ChatMessageModel.fromJson(jsonData);

        setChatMessageProvider(chatRoomModel);
        return chatRoomModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
