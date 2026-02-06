import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/chat/models/chat_models.dart';
import 'package:udb_association/src/features/chat/providers/chat_providers.dart';
import 'package:udb_association/src/features/chat/screens/new_chat_screen.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Connect to WebSocket when entering chat list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(webSocketServiceProvider).connect();
    });
  }

  @override
  void dispose() {
    // Don't disconnect WebSocket here as user might navigate to chat screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          l10n.translate('chat_messages_title'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewChatScreen()),
              );
            },
            icon: const Icon(Icons.edit, color: Color(0xFF6B7B3A)),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _buildEmptyState(l10n);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(
                chat: chat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        recipientName: chat.name,
                        recipientProfession: chat.type == 'group'
                            ? l10n.translate('chat_group_type')
                            : l10n.translate('chat_user_type'),
                        recipientImage: chat.image,
                        l10n: l10n,
                      ),
                    ),
                  );
                },
                l10n: l10n,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.translate(
                  'chat_failed_to_load_messages',
                  params: {'error': error.toString()},
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(chatsProvider);
                },
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6B7B3A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFF6B7B3A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate('chat_empty_title'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('chat_empty_subtitle'),
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewChatScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.translate('chat_new_chat')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7B3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({
    required this.chat,
    required this.onTap,
    required this.l10n,
  });

  final Chat chat;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF6B7B3A).withOpacity(0.1),
          backgroundImage: chat.image != null && chat.image!.isNotEmpty
              ? NetworkImage(chat.image!)
              : null,
          child: chat.image == null || chat.image!.isEmpty
              ? const Icon(Icons.group, color: Color(0xFF6B7B3A), size: 24)
              : null,
        ),
        title: Text(
          chat.name ?? l10n.translate('chat_unknown_chat'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.lastMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                chat.lastMessage!.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (chat.lastMessage != null) ...[
                  Text(
                    _formatTime(
                      chat.lastMessage!.createdAt ?? DateTime.now(),
                      l10n,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (chat.unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7B3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: chat.unreadCount > 0
            ? const Icon(Icons.circle, size: 8, color: Color(0xFF6B7B3A))
            : null,
      ),
    );
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.translate(
        'chat_time_d_ago',
        params: {'days': difference.inDays.toString()},
      );
    } else if (difference.inHours > 0) {
      return l10n.translate(
        'chat_time_h_ago',
        params: {'hours': difference.inHours.toString()},
      );
    } else if (difference.inMinutes > 0) {
      return l10n.translate(
        'chat_time_m_ago',
        params: {'minutes': difference.inMinutes.toString()},
      );
    } else {
      return l10n.translate('chat_time_just_now');
    }
  }
}
