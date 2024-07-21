import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';

import 'package:dating/platform/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/MongoDB/token_manager.dart';

class ChatMessageProvider extends ChangeNotifier {
  ChatMessageModel? chatMessageModel;

  bool _isMessagesLoading = false;

  bool get isMessagesLoading => _isMessagesLoading;

  Future<void> setMessagesLoading(bool value) async {
    _isMessagesLoading = value;
    notifyListeners();
  }

  void setChatMessageProvider(ChatMessageModel chatRoomModel) {
    chatMessageModel = chatRoomModel;
    notifyListeners();
  }

  ChatMessageModel? get userChatMessageModel => chatMessageModel;

  Future<void> sendChat(
      SendMessageModel sendMessageModel, String chatID, String uid) async {
    setMessagesLoading(true);
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
        ..headers['Accept'] = 'application/json'
        ..headers['Content-Type'] = 'multipart/form-data';

      // Add text fields
      if (sendMessageModel.messageContent != null &&
          sendMessageModel.messageContent!.isNotEmpty) {
        request.fields['MessageContent'] = sendMessageModel.messageContent!;
      }

      request.fields['SenderId'] = sendMessageModel.senderId.toString();
      request.fields['RecieverId'] = sendMessageModel.receiverId.toString();

      // Add the file if it exists and is not null
      if (sendMessageModel.file != null &&
          sendMessageModel.file!.path.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'File', // Treating the file as an array with 'File[]'
          sendMessageModel.file!.path,
        );
        request.files.add(file);
        request.fields['Type'] = "Image";
      }
      var response = await request.send();
      // Handle the response
      if (response.statusCode == 200) {
        await getMessage(chatID, 1);
      } else {
        throw Exception('Failed to send chat: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setMessagesLoading(false);
    }
  }

  Future<ChatMessageModel?> getMessage(String chatID, int page) async {
    String api = getApiEndpoint();
    setMessagesLoading(true);

    try {
      var headers = {'Content-Type': 'application/json'};
      var requestUrl = Uri.parse('$api/Communication/$chatID/page=1');

      var request = http.Request('GET', requestUrl)
        ..headers.addAll(headers)
        ..body = json.encode(page).toString();

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
    } finally {
      setMessagesLoading(false);
    }
  }
}
