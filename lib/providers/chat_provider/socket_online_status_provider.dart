import 'package:dating/providers/chat_provider/online_status_socket.dart';
import 'package:flutter/foundation.dart';

class SocketOnlineStatusProvider extends ChangeNotifier {
  final OnlineSocketService _socketService = OnlineSocketService();

  bool _isUserOnline = false;
  bool get userOnlineStatus => _isUserOnline;

  /// Set loading state
  Future<void> setOnlineStatus(bool value) async {
    _isUserOnline = value;
    notifyListeners();
  }

  // Initialize WebSocket connection
  void initializeSocket(String userId, String othersID) {
    _socketService.connectSocket(userId, othersID);

    // Set up the callback to handle new messages
    _socketService.onNewStatus((value) {
      setOnlineStatus(value);
      notifyListeners();
    });
  }

  /// Disconnect WebSocket
  void disconnectSocket() {
    _socketService.disconnectSocket();
  }
}
