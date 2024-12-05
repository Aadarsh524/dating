import 'dart:convert';
import 'dart:io';

import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSocketService {
  WebSocketChannel? _channel;
// Adjust the type of _onNewMessage to accept List<Messages>
  Function(Messages)? _onNewMessage;

// Modify the setter function to handle a List<Messages> instead of a List<String>
  void onNewMessage(Function(Messages) onNewMessage) {
    _onNewMessage = onNewMessage;
  }

  void connectSocket(String userId) {
    final uri = Uri.parse(
        'ws://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/online?userId=$userId');
    _channel = WebSocketChannel.connect(uri);

    // Send the handshake message after connecting
    _channel?.sink.add("${json.encode({
          "protocol": "json",
          "version": 1,
        })}\u001E");

    print('WebSocket handshake initiated');

    // Listen for messages from the server
    _channel?.stream.listen(
      (data) {
        try {
          // Clean the data by removing the \u001E character and trimming any whitespace
          String cleanData = data.replaceAll('\u001E', '').trim();

          // Decode the cleaned JSON string
          final decodedData = json.decode(cleanData);

          // Check if the message is a "NewMessage" type
          if (decodedData['type'] == 1 &&
              decodedData['target'].toString() == 'NewMessage') {
            if (decodedData['arguments'] is List) {
              // Map each element in decodedData['arguments'] to a Messages object
              if (decodedData['arguments'] is List &&
                  decodedData['arguments'].isNotEmpty) {
                // Extract the first message from the list
                var messageData = decodedData['arguments']
                    [0]; // Accessing the first message object

                // Map the message data to a single Messages model
                Messages message = Messages(
                  messageId: messageData['messageId'],
                  senderId: messageData['senderId'],
                  messageContent: messageData['messageContent'],
                  recieverId: messageData['recieverId'],
                  timeStamp: messageData['timeStamp'],
                  type: messageData['type'],
                  fileName: List<String>.from(messageData['fileName'] ?? []),
                  file: messageData['file'] != null
                      ? File(messageData['file'])
                      : null,
                  callDetails: messageData['callDetails'] != null
                      ? CallDetails.fromJson(messageData['callDetails'])
                      : null,
                  call: messageData['call'],
                );

                // Call the _onNewMessage callback with the single Messages object
                _onNewMessage?.call(message);
              } else {
                print('No valid message found in the arguments list');
              }
            }
            print(
                'Message event: ${decodedData['target']} - ${decodedData['arguments']}');

            // Call the onNewMessage callback with the decoded message
            _onNewMessage?.call(decodedData['arguments']);
          }
          // Handle other cases if needed
          else {
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

// Sending data to the WebSocket
    void sendMessage(Map<String, dynamic> message) {
      try {
        // Convert the message to JSON and send it via the WebSocket
        String messageJson = json.encode(message);
        _channel?.sink.add(messageJson);
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void disconnectSocket() {
    _channel?.sink.close();
  }
}
