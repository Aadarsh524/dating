import 'package:dating/providers/chat_provider/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../platform/platform_stub.dart';
import '../../backend/MongoDB/token_manager.dart';
import '../../datamodel/chat/chat_message_model.dart';
import '../../datamodel/chat/send_message_model.dart';

class SocketMessageProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  bool _isUserOnline = false;
  bool get isUserOnline => _isUserOnline;

  bool _isMessagesLoading = false;
  bool get isMessagesLoading => _isMessagesLoading;

  ChatMessageModel? chatMessageModel;

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
  void setChatMessageModel(ChatMessageModel chatRoomModel) {
    chatMessageModel = chatRoomModel;
    notifyListeners();
  }

  ChatMessageModel? get userChatMessageModel => chatMessageModel;

  /// Send a chat message via API
  Future<void> sendChatViaAPI(
      SendMessageModel sendMessageModel, String chatID, String uid) async {
    try {
      Messages newSentMessage = Messages(
          messageContent: sendMessageModel.messageContent,
          senderId: sendMessageModel.senderId,
          recieverId: sendMessageModel.receiverId,
          fileName: sendMessageModel.fileName,
          file: sendMessageModel.file,
          type: sendMessageModel.type,
          callDetails: sendMessageModel.callDetails);

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

      // Handle different types of messages based on 'type'
      if (sendMessageModel.type == 'Text' &&
          sendMessageModel.messageContent != null &&
          sendMessageModel.messageContent!.isNotEmpty) {
        request.fields['MessageContent'] = sendMessageModel.messageContent!;
      }

      request.fields['SenderId'] = sendMessageModel.senderId.toString();
      request.fields['RecieverId'] = sendMessageModel.receiverId.toString();

      if (kIsWeb) {
        if (sendMessageModel.type == 'Image' &&
            sendMessageModel.fileBytes != null &&
            sendMessageModel.fileName != null) {
          final file = http.MultipartFile.fromBytes(
            'File',
            sendMessageModel.fileBytes!,
            filename: sendMessageModel.fileName![0],
          );
          request.files.add(file);
        }
      } else if (sendMessageModel.type == 'Image' &&
          sendMessageModel.file != null &&
          sendMessageModel.file!.path.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'File',
          sendMessageModel.file!.path,
        );
        request.files.add(file);
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

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final chatRoomModel = ChatMessageModel.fromJson(jsonData);

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
  void addMessage(Messages message) {
    chatMessageModel ??= ChatMessageModel(messages: []);
    chatMessageModel!.messages ??= [];
    chatMessageModel!.messages!.insert(0, message);
    notifyListeners();
  }

  /// Remove the last message
  void removeLastMessage() {
    chatMessageModel ??= ChatMessageModel(messages: []);
    chatMessageModel!.messages ??= [];
    if (chatMessageModel!.messages!.isNotEmpty) {
      chatMessageModel!.messages!.removeLast();
      notifyListeners();
    }
  }

  /// Disconnect WebSocket
  void disconnectSocket() {
    _socketService.disconnectSocket();
    _socketService.disconnectSocket();
  }
}
