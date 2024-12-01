import 'package:dating/providers/chat_provider/chat_socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../platform/platform_stub.dart';
import '../../backend/MongoDB/token_manager.dart';
import '../../datamodel/chat/chat_message_model.dart';
import '../../datamodel/chat/send_message_model.dart';

class SocketMessageProvider extends ChangeNotifier {
  ChatMessageModel? chatMessageModel;
  final ChatSocketService _socketService = ChatSocketService();

  bool _isMessagesLoading = false;
  bool get isMessagesLoading => _isMessagesLoading;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  /// Set loading state
  Future<void> setMessagesLoading(bool value) async {
    _isMessagesLoading = value;
    notifyListeners();
  }

  /// Set chat message provider (for state updates)
  void setChatMessageProvider(ChatMessageModel chatRoomModel) {
    chatMessageModel = chatRoomModel;
    notifyListeners();
  }

  ChatMessageModel? get userChatMessageModel => chatMessageModel;

  /// Send a chat message via API (for fallback or offline)
  Future<void> sendChatViaAPI(
      SendMessageModel sendMessageModel, String chatID, String uid) async {
    try {
      // Get API endpoint
      String api = getApiEndpoint();

      // Get bearer token
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No token found');
      }

      // Set params in URI
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

      // Handle file uploads
      if (kIsWeb) {
        if (sendMessageModel.fileBytes != null &&
            sendMessageModel.fileName != null) {
          final file = http.MultipartFile.fromBytes(
            'File',
            sendMessageModel.fileBytes!,
            filename: sendMessageModel.fileName![0],
          );
          request.files.add(file);
        }
      } else if (sendMessageModel.file != null &&
          sendMessageModel.file!.path.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'File',
          sendMessageModel.file!.path,
        );
        request.files.add(file);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        await getMessage(chatID, 1, uid);
      } else {
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

        setChatMessageProvider(chatRoomModel);
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

  /// Initialize WebSocket connection
  void initializeSocket(String userId) {
    bool _isConnected = _socketService.connectSocket(userId);

    if (_isConnected) {
      // Listen for incoming messages
      _socketService.onMessageReceived((data) {
        final newMessage = Messages.fromJson(data);
        addMessage(newMessage); // Add received message to the list
      });

      // Handle socket errors or disconnections
      _socketService.onError((error) {
        print("Socket error: $error");
      });

      _socketService.onDisconnect(() {
        print("Socket disconnected");
      });
    }
  }

  /// Add a single message to the chat
  void addMessage(Messages message) {
    // Add the received message to the list
    if (chatMessageModel != null) {
      chatMessageModel!.messages?.add(message);
      notifyListeners();
    }
  }

  /// Disconnect WebSocket
  void disconnectSocket() {
    _socketService.disconnectSocket();
  }

  /// Send a chat message (WebSocket)
  void sendChatViaSocket(SendMessageModel sendMessageModel) {
    _socketService.sendMessage(sendMessageModel.toJson() as SendMessageModel);
  }
}
