import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatSocketService {
  final WebSocketChannel _channel;

  ChatSocketService(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  Stream get stream => _channel.stream;

  void send(String message) {
    _channel.sink.add(message);
  }

  void close() {
    _channel.sink.close(status.goingAway);
  }
}
