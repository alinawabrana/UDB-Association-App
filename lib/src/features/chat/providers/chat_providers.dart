import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/chat/models/chat_models.dart';
import 'package:udb_association/src/features/chat/services/chat_service.dart';
import 'package:udb_association/src/features/chat/services/websocket_service.dart';

// Services
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());
final webSocketServiceProvider = Provider<WebSocketService>(
  (ref) => WebSocketService.instance,
);

// Chat List Provider
final chatsProvider = FutureProvider<List<Chat>>((ref) async {
  final service = ref.read(chatServiceProvider);
  return await service.getChats();
});

// Specific Chat Provider
final chatProvider = FutureProvider.family<Chat, int>((ref, chatId) async {
  final service = ref.read(chatServiceProvider);
  return await service.getChat(chatId);
});

// Chat Messages Provider
final chatMessagesProvider = FutureProvider.family<List<Message>, int>((
  ref,
  chatId,
) async {
  final service = ref.read(chatServiceProvider);
  return await service.getChatMessages(chatId);
});

// Search Recipients Provider
final searchRecipientsProvider =
    FutureProvider.family<List<ChatSearchResult>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final service = ref.read(chatServiceProvider);
      return await service.searchRecipients(query);
    });

// Send Message To Chat Provider
final sendMessageToChatProvider =
    FutureProvider.family<Message, (int chatId, String content)>((
      ref,
      args,
    ) async {
      final service = ref.read(chatServiceProvider);
      return await service.sendMessageToChat(chatId: args.$1, content: args.$2);
    });

// Create Chat Provider
final createChatProvider = FutureProvider.family<Chat, CreateChatRequest>((
  ref,
  request,
) async {
  final service = ref.read(chatServiceProvider);
  return await service.createChat(request);
});

// Resolve Chat Provider (user or branch)
final resolveChatProvider =
    FutureProvider.family<Chat, (String recipientType, int recipientId)>((
      ref,
      args,
    ) async {
      final service = ref.read(chatServiceProvider);
      return await service.resolveChat(
        recipientType: args.$1,
        recipientId: args.$2,
      );
    });

// WebSocket Connection Status Provider
final webSocketConnectionProvider = StreamProvider<String>((ref) {
  final service = ref.read(webSocketServiceProvider);
  return service.connectionStream;
});

// WebSocket Messages Provider
final webSocketMessagesProvider = StreamProvider<Message>((ref) {
  final service = ref.read(webSocketServiceProvider);
  return service.messageStream;
});

// Chat State Notifier for real-time updates
class ChatStateNotifier extends StateNotifier<Map<int, List<Message>>> {
  ChatStateNotifier(this.ref) : super({});

  final Ref ref;

  void addMessage(int chatId, Message message) {
    final currentMessages = state[chatId] ?? [];
    state = {
      ...state,
      chatId: [...currentMessages, message],
    };
  }

  void updateMessage(int chatId, Message message) {
    final currentMessages = state[chatId] ?? [];
    final updatedMessages = currentMessages.map((m) {
      return m.id == message.id ? message : m;
    }).toList();

    state = {...state, chatId: updatedMessages};
  }

  void setMessages(int chatId, List<Message> messages) {
    state = {...state, chatId: messages};
  }

  void clearMessages(int chatId) {
    state = {...state, chatId: []};
  }
}

final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, Map<int, List<Message>>>((ref) {
      return ChatStateNotifier(ref);
    });

// Current Chat ID Provider
final currentChatIdProvider = StateProvider<int?>((ref) => null);

// Message Input Provider
final messageInputProvider = StateProvider<String>((ref) => '');

// Is Typing Provider
final isTypingProvider = StateProvider<bool>((ref) => false);
