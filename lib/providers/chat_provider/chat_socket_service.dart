import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../datamodel/chat/send_message_model.dart';

class ChatSocketService {
  IO.Socket? _socket;

  bool connectSocket(String userId) {
    try {
      _socket = IO.io(
          'ws://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/communication?userId=$userId',
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': true,
          });

      _socket?.onConnect((_) {
        print('WebSocket connected for user: $userId');
      });

      return true;
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      return false;
    }
  }

  void onMessageReceived(Function(Map<String, dynamic>) onMessage) {
    _socket?.on('message', (data) {
      try {
        final decodedData = json.decode(data);
        onMessage(decodedData);
      } catch (e) {
        print('Failed to parse message: $e');
      }
    });
  }

  void sendMessage(SendMessageModel message) {
    _socket?.emit('message', json.encode(message));
  }

  void onError(Function(String) onError) {
    _socket?.onError((error) {
      onError(error.toString());
    });
  }

  void onDisconnect(Function() onDisconnect) {
    _socket?.onDisconnect((_) {
      print('WebSocket disconnected');
      onDisconnect();
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
  }
}
