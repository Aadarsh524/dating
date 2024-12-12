import 'package:dating/providers/chat_provider/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../platform/platform_stub.dart';
import '../../backend/MongoDB/token_manager.dart';
import '../../datamodel/chat/chat_message_model.dart' as messages;
import '../../datamodel/chat/send_message_model.dart';

class SocketMessageProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  bool _isUserOnline = false;
  bool get isUserOnline => _isUserOnline;

  bool _isMessagesLoading = false;
  bool get isMessagesLoading => _isMessagesLoading;

  messages.ChatMessageModel? chatMessageModel;

  /// Set loading state for online status
  Future<void> setOnlineStatus(bool value) async {
    _isUserOnline = value;
    notifyListeners();
  }

  /// Set loading state for messages
  Future<void> setMessagesLoading(bool value) async {
    _isMessagesLoading = value;
    notifyListeners();
  }

  /// Set chat message model for state updates
  void setChatMessageModel(messages.ChatMessageModel chatRoomModel) {
    chatMessageModel = chatRoomModel;
    notifyListeners();
  }

  messages.ChatMessageModel? get userChatMessageModel => chatMessageModel;

  /// Send a chat message via API
  Future<void> sendChatViaAPI(
      SendMessageModel sendMessageModel, String chatID, String uid) async {
    try {
      messages.Messages newSentMessage = messages.Messages(
          messageContent: sendMessageModel.messageContent,
          senderId: sendMessageModel.senderId,
          recieverId: sendMessageModel.receiverId,
          fileBytes: sendMessageModel.fileBytes,
          type: sendMessageModel.type,
          callDetails: messages.CallDetails(
            duration: sendMessageModel.callDetails!.duration,
            status: sendMessageModel.callDetails!.status,
          ));

      addMessage(newSentMessage);
      String api = getApiEndpoint();
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No token found');
      }

      final uri = Uri.parse("$api/Communication");

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..headers['Content-Type'] = 'multipart/form-data';

      request.fields['Type'] = sendMessageModel.type.toString();

      // Handle different types of messages based on 'type'
      if (sendMessageModel.type == 'Text' &&
          sendMessageModel.messageContent != null &&
          sendMessageModel.messageContent!.isNotEmpty) {
        request.fields['MessageContent'] = sendMessageModel.messageContent!;
      }

      request.fields['SenderId'] = sendMessageModel.senderId.toString();
      request.fields['RecieverId'] = sendMessageModel.receiverId.toString();

      if (kIsWeb) {
        // Handling fileBytes for web platform
        if (sendMessageModel.type == 'Image' &&
            sendMessageModel.fileBytes != null &&
            sendMessageModel.fileName != null) {
          final file = http.MultipartFile.fromBytes(
            'File',
            sendMessageModel.fileBytes!.first,
            filename: sendMessageModel.fileName!.first,
          );
          request.files.add(file);
        }
      } else {
        // Handling files for non-web platform
        if (sendMessageModel.type == 'Image' &&
            sendMessageModel.files != null &&
            sendMessageModel.files!.isNotEmpty) {
          for (var file in sendMessageModel.files!) {
            final filePart = await http.MultipartFile.fromPath(
              'File',
              file.path,
              filename: sendMessageModel.fileName?.first ?? 'image.jpg',
            );
            request.files.add(filePart);
          }
        }
      }

      // Handle call details
      if (sendMessageModel.type == 'Call' &&
          sendMessageModel.callDetails != null) {
        request.fields['duration'] = sendMessageModel.callDetails!.duration!;
        request.fields['status'] = sendMessageModel.callDetails!.status!;
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        // await getMessage(chatID, 1, uid);
        print('Message sent');
      } else {
        removeLastMessage();
        throw Exception('Failed to send chat: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// Fetch older messages via API
  Future<messages.ChatMessageModel?> getMessage(
      String chatID, int page, String uid) async {
    String api = getApiEndpoint();
    setMessagesLoading(true);

    try {
      var headers = {'Content-Type': 'application/json'};
      var requestUrl = Uri.parse('$api/Communication/$uid/$chatID/page=1');

      var request = http.Request('GET', requestUrl)..headers.addAll(headers);

      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final chatRoomModel = messages.ChatMessageModel.fromJson(jsonData);

        setChatMessageModel(chatRoomModel);
        return chatRoomModel;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    } finally {
      setMessagesLoading(false);
    }
  }

  /// Initialize WebSocket connection for both online status and messages
  void initializeSocket(String userId, String othersID) {
    _socketService.connectSocket(userId, othersID);

    _socketService.onNewStatus((value) {
      setOnlineStatus(value);
    });

    _socketService.onNewMessage((message) {
      addMessage(message);
    });
  }

  /// Add a new chat message
  void addMessage(messages.Messages message) {
    chatMessageModel ??= messages.ChatMessageModel(messages: []);
    chatMessageModel!.messages ??= [];
    chatMessageModel!.messages!.insert(0, message);
    notifyListeners();
  }

  /// Remove the last message
  void removeLastMessage() {
    // Initialize chatMessageModel and messages if null
    chatMessageModel ??= messages.ChatMessageModel(messages: []);
    chatMessageModel!.messages ??= [];

    // Check if the list is not empty before removing the first element
    if (chatMessageModel!.messages!.isNotEmpty) {
      chatMessageModel!.messages!.removeAt(0); // Remove the first message
    }

    // Notify listeners of the change
    notifyListeners();
  }

  /// Disconnect WebSocket
  void disconnectSocket() {
    _socketService.disconnectSocket();
    _socketService.disconnectSocket();
  }
}
