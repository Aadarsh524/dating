import 'dart:convert';
import 'dart:async'; // Required for periodic operations
import 'package:web_socket_channel/web_socket_channel.dart';

class OnlineSocketService {
  WebSocketChannel? _channel;
  Function(bool)? _onNewStatus;

  // Modify the setter function to handle a bool (online status)
  void onNewStatus(Function(bool) onNewStatus) {
    _onNewStatus = onNewStatus;
  }

  // Connect to the WebSocket with userId and other user details
  void connectSocket(String userId, String othersId) {
    final uri = Uri.parse(
        'ws://your-websocket-url/online?userId=$userId'); // Your backend URL
    _channel = WebSocketChannel.connect(uri);

    // Start periodic sending of the handshake message
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_channel != null && _channel?.sink != null) {
        final message = '${json.encode({
              "protocol": "json",
              "version": 1,
              'arguments': othersId
            })}\u001E'; // Adding separator after JSON message
        _channel?.sink.add(message);
        print('Periodic WebSocket handshake sent: $message');
      }
    });

    print('WebSocket handshake initiated');

    // Listen for messages from the server
    _channel?.stream.listen(
      (data) {
        try {
          // Clean the data by removing the \u001E character and trimming any whitespace
          String cleanData = data.replaceAll('\u001E', '').trim();

          // Decode the cleaned JSON string
          final decodedData = json.decode(cleanData);

          // Check if the message is of type "UpdateStatus"
          if (decodedData['type'] == 1 &&
              decodedData['target'] == 'UpdateStatus') {
            if (decodedData['arguments'] is List &&
                decodedData['arguments'].isNotEmpty) {
              var statusData = decodedData['arguments'];
              bool isOnline = statusData[1];

              // Call the callback with the online status
              _onNewStatus?.call(isOnline);
            } else {
              print('Invalid message arguments');
            }
          } else {
            print('Unhandled type: ${decodedData['type']}');
          }
        } catch (e) {
          print('Error parsing data: $e');
        }
      },
      onDone: () {
        print('WebSocket stream closed');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }

  // Disconnect WebSocket connection
  void disconnectSocket() {
    _channel?.sink.close();
  }

  //
}
