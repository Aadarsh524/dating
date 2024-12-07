import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class OnlineSocketService {
  WebSocketChannel? _channel;
  Function(bool)? _onNewStatus;
  Timer? _statusRequestTimer;
  // Set the callback function for online status updates
  void onNewStatus(Function(bool) onNewStatus) {
    _onNewStatus = onNewStatus;
  }

  // Connect to the WebSocket
  void connectSocket(String userId, String othersID) {
    final uri = Uri.parse(
        'ws://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/online?userId=$userId'); // Your backend WebSocket URL

    _channel = WebSocketChannel.connect(uri);
    print('Connected to WebSocket at $uri');

    _channel?.sink.add("${json.encode({
          "protocol": "json",
          "version": 1,
        })}\u001E");

    print('WebSocket handshake initiated');

    // Start listening to WebSocket messages
    _channel?.stream.listen(
      (data) {
        try {
          // Clean incoming data by removing the \u001E separator
          String cleanData = data.replaceAll('\u001E', '').trim();

          // Decode the JSON response
          final decodedData = json.decode(cleanData);

          // Handle the ReceiveConnectionId message
          if (decodedData['type'] == 1 &&
              decodedData['target'] == 'ReceiveConnectionId') {
            print('Handshake successful: ${decodedData['arguments'][0]}');

            // Perform handshake after connection
            startPeriodicStatusRequests(othersID);
          } else if (decodedData['type'] == 1 &&
              decodedData['target'] == 'UpdateStatus') {
            // Handle UpdateStatus message
            if (decodedData['arguments'] is List &&
                decodedData['arguments'].length > 1) {
              bool isOnline = decodedData['arguments'][1];
              _onNewStatus?.call(isOnline);
              print(
                  'User online status received: ${decodedData['arguments'][0]} is ${isOnline ? 'online' : 'offline'}');
            } else {
              print('Invalid arguments for UpdateStatus');
            }
          } else {
            print('Unhandled WebSocket message: $cleanData');
          }
        } catch (e) {
          print('Error parsing WebSocket data: $e');
        }
      },
      onDone: () {
        print('WebSocket connection closed');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }

  // Start sending periodic status requests

  // Request online status for a specific user
  void requestOnlineStatus(String userId) {
    final onlineStatusMessage = '${json.encode({
          "type": 1,
          "target": "OnlineStatus",
          "arguments": [userId],
        })}\u001E'; // Add separator
    _channel?.sink.add(onlineStatusMessage);
    print('Online status request sent for user: $userId');
  }

  // Start periodic status requests
  void startPeriodicStatusRequests(String userId) {
    _statusRequestTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      requestOnlineStatus(userId);
    });
    print('Started periodic online status requests');
  }

  // Stop periodic status requests
  void stopPeriodicStatusRequests() {
    _statusRequestTimer?.cancel();
    print('Stopped periodic online status requests');
  }

  // Disconnect WebSocket connection
  void disconnectSocket() {
    stopPeriodicStatusRequests(); // Stop periodic requests before disconnecting
    _channel?.sink.close();
    print('WebSocket connection closed manually');
  }
}
