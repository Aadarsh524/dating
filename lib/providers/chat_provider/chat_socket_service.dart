import 'package:web_socket_channel/web_socket_channel.dart';
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

  List<ChatMessageModel> _messages = [];
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

  /// Add a single message to the chat
  void addMessage(Messages message) {
    // Add the received message to the list
    if (chatMessageModel != null) {
      chatMessageModel!.messages?.add(message);
      notifyListeners();
    }
  }

  /// Initialize WebSocket connection
  void initializeSocket(String userId) {
    _socketService.connectSocket(userId);

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

  /// Disconnect WebSocket
  void disconnectSocket() {
    _socketService.disconnectSocket();
  }

  /// Send a chat message (WebSocket)
  void sendChatViaSocket(SendMessageModel sendMessageModel) {
    _socketService.sendMessage(sendMessageModel.toJson() as SendMessageModel);
  }

  /// Send a chat message via API (for fallback or offline)
  Future<void> sendChatViaAPI(
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
    } finally {
      setMessagesLoading(false);
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
}

class ChatSocketService {
  WebSocketChannel? _channel;

  /// Connect to the WebSocket server
  void connectSocket(String userId) {
    try {
      // Replace with your WebSocket server URL
      final String webSocketUrl =
          'wss://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/communication?userId=$userId';

      _channel = WebSocketChannel.connect(Uri.parse(webSocketUrl));
      print('WebSocket connected for user: $userId');
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  /// Send a message via WebSocket
  void sendMessage(SendMessageModel message) {
    if (_channel != null) {
      final encodedMessage = json.encode(message);
      _channel!.sink.add(encodedMessage);
      print('Message sent: $encodedMessage');
    } else {
      print('WebSocket is not connected');
    }
  }

  /// Listen for incoming messages
  void onMessageReceived(Function(Map<String, dynamic>) onMessage) {
    if (_channel != null) {
      _channel!.stream.listen((data) {
        try {
          final decodedData = json.decode(data);
          onMessage(decodedData);
        } catch (e) {
          print('Failed to parse message: $e');
        }
      });
    } else {
      print('WebSocket is not connected');
    }
  }

  /// Listen for errors
  void onError(Function(String) onError) {
    if (_channel != null) {
      _channel!.stream.handleError((error) {
        onError(error.toString());
      });
    }
  }

  /// Handle disconnection
  void onDisconnect(Function() onDisconnect) {
    if (_channel != null) {
      _channel!.stream.listen(
        (_) {},
        onDone: () {
          print('WebSocket disconnected');
          onDisconnect();
        },
        cancelOnError: true,
      );
    }
  }

  /// Disconnect from the WebSocket server
  void disconnectSocket() {
    if (_channel != null) {
      _channel!.sink.close();
      print('WebSocket connection closed');
    }
  }
}
