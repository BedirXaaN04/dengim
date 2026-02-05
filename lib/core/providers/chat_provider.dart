import 'dart:async';
import 'package:flutter/material.dart';
import '../features/chats/models/chat_models.dart';
import '../features/chats/services/chat_service.dart';
import '../utils/log_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  StreamSubscription? _conversationsSubscription;

  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;

  final ChatService _chatService = ChatService();

  void initConversations() {
    _isLoading = true;
    notifyListeners();

    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatService.getConversations().listen(
      (chats) {
        _conversations = chats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        LogService.e("Chat subscription error", error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> markAsRead(String chatId) async {
    try {
      await _chatService.markAsRead(chatId);
    } catch (e) {
      LogService.e("Error marking chat as read", e);
    }
  }
}
