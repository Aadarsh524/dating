import 'dart:convert';

import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/platform/platform.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../backend/MongoDB/token_manager.dart';

class ChatRoomProvider extends ChangeNotifier {
  ChatRoomModel? _userChatRoomModel;

  void setChatRoomProvider(ChatRoomModel chatRoomModel) {
    _userChatRoomModel = chatRoomModel;
    notifyListeners();
  }

  ChatRoomModel? get userChatRoomModel => _userChatRoomModel;

  Future<void> fetchChatRoom(BuildContext context, uid) async {
    context.read<LoadingProvider>().setLoading(true);
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      String api = getApiEndpoint();
      final response = await http.get(
        Uri.parse('$api/Communication/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final chatRoomModel = ChatRoomModel.fromJson(jsonData);

        setChatRoomProvider(chatRoomModel);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch chat room: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Rethrow the exception to handle it in the caller
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }
}
