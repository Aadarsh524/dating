import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';

import 'package:dating/platform/platform.dart';
import 'package:dating/providers/chat_provider/chat_socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/MongoDB/token_manager.dart';

class ChatMessageProvider extends ChangeNotifier {
  ChatMessageModel? chatMessageModel;
  final ChatSocketService _socketService = ChatSocketService();

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
      final uri = Uri.parse("$api/Communication");

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

      // handle for web
      if (kIsWeb) {
        if (sendMessageModel.fileBytes != null &&
            sendMessageModel.fileName != null) {
          final file = http.MultipartFile.fromBytes(
              'File', // Treating the file as an array with 'File[]'
              sendMessageModel.fileBytes!,
              filename: sendMessageModel.fileName![0]);
          request.files.add(file);
        }
      }

      //this for other platforms
      if (sendMessageModel.file != null &&
          sendMessageModel.file!.path.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'File', // Treating the file as an array with 'File[]'
          sendMessageModel.file!.path,
        );
        request.files.add(file);
      }
      var response = await request.send();
      // Handle the response
      if (response.statusCode == 200) {
        await getMessage(chatID, 1, uid);
      } else {
        throw Exception('Failed to send chat: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setMessagesLoading(false);
    }
  }

  Future<String> fetchImage() async {
    const url =
        'http://localhost:8001/api/Communication/FileView/2234ca44679f324108ae9ae4ae87d2fde9ec7c167572a07e3234f3991ca0b17c.jpeg';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<ChatMessageModel?> getMessage(
      String chatID, int page, String uid) async {
    String api = getApiEndpoint();
    setMessagesLoading(true);

    try {
      var headers = {'Content-Type': 'application/json'};
      var requestUrl = Uri.parse('$api/Communication/$uid/$chatID/page=1');

      var request = http.Request('GET', requestUrl)..headers.addAll(headers);

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
