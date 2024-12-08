import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;
  Timer? _statusRequestTimer;
  Function(bool)? _onNewStatus;
  Function(Messages)? _onNewMessage;

  // Set the callback for online status updates
  void onNewStatus(Function(bool) onNewStatus) {
    _onNewStatus = onNewStatus;
  }

  // Set the callback for new chat messages
  void onNewMessage(Function(Messages) onNewMessage) {
    _onNewMessage = onNewMessage;
  }

  // Connect to the WebSocket
  void connectSocket(String userId, String othersID) {
    final uri = Uri.parse(
        'ws://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/online?userId=$userId');
    _channel = WebSocketChannel.connect(uri);
    print('Connected to WebSocket at $uri');

    // Send the handshake message
    _channel?.sink.add("${json.encode({
          "protocol": "json",
          "version": 1,
        })}\u001E");

    print('WebSocket handshake initiated');

    startPeriodicStatusRequests(othersID);

    // Listen for WebSocket messages
    _channel?.stream.listen(
      (data) {
        _handleIncomingMessage(data, userId);
      },
      onDone: () {
        print('WebSocket connection closed');
      },
      onError: (error) {
        print('WebSocket error: $error');
        if (error is WebSocketException) {
          print('WebSocket exception message: ${error.message}');
        }
      },
    );
  }

  // Handle incoming WebSocket messages
  void _handleIncomingMessage(String data, String userId) {
    try {
      // Clean and parse the incoming data
      String cleanData = data.replaceAll('\u001E', '').trim();
      final decodedData = json.decode(cleanData);

      // Handle different types of messages
      if (decodedData['type'] == 1) {
        switch (decodedData['target']) {
          case 'ReceiveConnectionId':
            print('Handshake successful: ${decodedData['arguments'][0]}');
            break;
          case 'UpdateStatus':
            if (decodedData['arguments'] is List &&
                decodedData['arguments'].length > 1) {
              bool isOnline = decodedData['arguments'][1];
              _onNewStatus?.call(isOnline);
              print(
                  'User online status received: ${decodedData['arguments'][0]} is ${isOnline ? 'online' : 'offline'}');
            } else {
              print('Invalid arguments for UpdateStatus');
            }
            break;
          case 'NewMessage':
            if (decodedData['arguments'] is List &&
                decodedData['arguments'].isNotEmpty) {
              var messageData = decodedData['arguments'][0];
              var message = Messages.fromJson(messageData);
              _onNewMessage?.call(message);
            } else {
              print('Invalid message arguments');
            }
            break;
          default:
            print('Unhandled target: ${decodedData['target']}');
        }
      } else {
        print('Unhandled WebSocket message: $cleanData');
      }
    } catch (e) {
      print('Error parsing WebSocket data: $e');
    }
  }

  // Request online status
  void requestOnlineStatus(String userId) {
    final onlineStatusMessage = '${json.encode({
          "type": 1,
          "target": "OnlineStatus",
          "arguments": [userId],
        })}\u001E';
    _channel?.sink.add(onlineStatusMessage);
    print('Online status request sent for user: $userId');
  }

  // Start periodic online status requests
  void startPeriodicStatusRequests(String userId) {
    _statusRequestTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      requestOnlineStatus(userId);
    });
    print('Started periodic online status requests');
  }

  // Stop periodic online status requests
  void stopPeriodicStatusRequests() {
    _statusRequestTimer?.cancel();
    print('Stopped periodic online status requests');
  }

  // Disconnect the WebSocket
  void disconnectSocket() {
    stopPeriodicStatusRequests(); // Stop periodic requests before disconnecting
    _channel?.sink.close();
    print('WebSocket connection closed manually');
  }
}
