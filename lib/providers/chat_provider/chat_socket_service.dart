import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  IO.Socket? socket;

  void initializeSocket(String token) {
    try {
      socket = IO.io(
        'https://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/communication', // Replace with your server URL
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // Add token
            .build(),
      );

      // Listen for connection events
      socket?.onConnect((_) {
        print('Socket connected');
      });

      // Listen for disconnection
      socket?.onDisconnect((_) {
        print('Socket disconnected');
      });
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  void sendMessage(String chatID, Map<String, dynamic> message) {
    socket?.emit('send_message', {'chatID': chatID, ...message});
  }

  void listenForMessages(void Function(dynamic) onMessageReceived) {
    socket?.on('receive_message', (data) {
      onMessageReceived(data);
    });
  }

  void disconnectSocket() {
    socket?.disconnect();
  }
}
