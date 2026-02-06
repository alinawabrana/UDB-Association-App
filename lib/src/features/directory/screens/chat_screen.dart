import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/chat/models/chat_models.dart';
import 'package:udb_association/src/features/chat/providers/chat_providers.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:udb_association/src/features/surveys/services/branch_users_service.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int? chatId;
  final String? recipientName;
  final String? recipientProfession;
  final String? recipientImage;
  final int? recipientId;
  final String? chatType; // 'user' or 'branch'
  final AppLocalizations? l10n;

  const ChatScreen({
    super.key,
    this.chatId,
    this.recipientName,
    this.recipientProfession,
    this.recipientImage,
    this.recipientId,
    this.chatType,
    this.l10n,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  int? _currentChatId;
  StreamSubscription<Message>? _wsSubscription;
  Timer? _pollTimer;

  AppLocalizations get _l10n => widget.l10n ?? context.l10n;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupWebSocketListener();
    _startPolling();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _wsSubscription?.cancel();
    _pollTimer?.cancel();
    // Refresh chats list when leaving the screen
    try {
      ref.invalidate(chatsProvider);
    } catch (_) {}
    // Don't use ref in dispose - WebSocket cleanup will happen automatically
    super.dispose();
  }

  void _initializeChat() async {
    print(
      '[ChatScreen] init chatId=${widget.chatId} recipientId=${widget.recipientId}',
    );
    if (widget.recipientId != null) {
      print(
        '[ChatScreen] Navigated with recipientId=${widget.recipientId} name=${widget.recipientName}',
      );
    }
    // Never auto-use a passed chatId blindly; always validate/derive
    if (widget.recipientId != null) {
      await _findExistingChat();
    } else if (widget.chatId != null) {
      // As a fallback, if recipient unknown but chatId is provided
      _currentChatId = widget.chatId;
      // Invalidate cached messages to fetch fresh data immediately
      try {
        ref.invalidate(chatMessagesProvider(_currentChatId!));
      } catch (_) {}
      await _loadMessages();
    }
  }

  Future<void> _findExistingChat() async {
    try {
      if (widget.recipientId == null || widget.chatType == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // Derive chatId from /chats using participants (users) and pivot
      final currentUser = ref.read(profileProvider).valueOrNull;
      final currentUserId = int.tryParse(currentUser?.id ?? '') ?? -1;
      final chats = await ref.read(chatsProvider.future);
      Chat? derived;
      for (final c in chats) {
        final ids = c.participants.map((p) => p.id).toSet();
        if (ids.contains(currentUserId) && ids.contains(widget.recipientId)) {
          derived = c;
          break;
        }
      }
      if (derived != null) {
        print(
          '[ChatScreen] Derived chatId=${derived.id} from /chats for recipientId=${widget.recipientId}',
        );
        _currentChatId = derived.id;
        ref.read(webSocketServiceProvider).subscribeToChat(_currentChatId!);
        // Invalidate cached messages to fetch fresh data immediately
        try {
          ref.invalidate(chatMessagesProvider(_currentChatId!));
        } catch (_) {}
        setState(() {
          _messages = [];
        });
        await _loadMessages();
        return;
      }

      // Fallback using the same chats/currentUser/currentUserId (avoid redeclare)
      Chat? target;
      for (final c in chats) {
        if ((c.type == "private" || c.type == null) &&
            c.participants.length == 2) {
          final a = c.participants[0];
          final b = c.participants[1];
          final pivAUserId = a.pivotUserId ?? a.id;
          final pivBUserId = b.pivotUserId ?? b.id;
          final userIds = {a.id, b.id};
          if (userIds.contains(currentUserId) &&
              userIds.contains(widget.recipientId)) {
            if ((pivAUserId == currentUserId &&
                    pivBUserId == widget.recipientId) ||
                (pivBUserId == currentUserId &&
                    pivAUserId == widget.recipientId)) {
              target = c;
              break;
            }
          }
        }
      }
      if (target != null) {
        print(
          '[ChatScreen] Final derived chatId=${target.id} (with pivots) for recipientId=${widget.recipientId}',
        );
        _currentChatId = target.id;
        ref.read(webSocketServiceProvider).subscribeToChat(_currentChatId!);
        // Invalidate cached messages to fetch fresh data immediately
        try {
          ref.invalidate(chatMessagesProvider(_currentChatId!));
        } catch (_) {}
        setState(() {
          _messages = [];
        });
        await _loadMessages();
      } else {
        print(
          '[ChatScreen] Fallback could not find any chat for recipientId=${widget.recipientId}',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ChatScreen] Error resolving chat: $e');
      setState(() {
        _isLoading = false;
      });
      // Show user-friendly error if backend has issues
      if (e.toString().contains('branch must return a relationship instance') ||
          e.toString().contains('500')) {
        _showErrorSnackBar(_l10n.translate('chat_backend_error'));
      }
    }
  }

  void _setupWebSocketListener() {
    _wsSubscription?.cancel();
    _wsSubscription = ref.read(webSocketServiceProvider).messageStream.listen((
      message,
    ) {
      if (message.chatId == _currentChatId) {
        if (!mounted) return;
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_currentChatId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('[ChatScreen] load messages chatId=$_currentChatId');
      final messages = await ref.read(
        chatMessagesProvider(_currentChatId!).future,
      );

      // Set message ownership based on current user
      final currentUser = ref.read(profileProvider).valueOrNull;
      final messagesWithOwnership = messages.map((message) {
        return Message(
          id: message.id,
          content: message.content,
          userId: message.userId,
          userName: message.userName,
          userImage: message.userImage,
          chatId: message.chatId,
          messageType: message.messageType,
          fileName: message.fileName,
          fileSize: message.fileSize,
          fileUrl: message.fileUrl,
          isRead: message.isRead,
          isFromCurrentUser: currentUser?.id == message.userId.toString(),
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
        );
      }).toList();

      setState(() {
        _messages = messagesWithOwnership;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('[ChatScreen] load messages error: $e');
      setState(() {
        _isLoading = false;
      });

      // If the chat endpoint doesn't exist, show a helpful message
      if (e.toString().contains('404') && e.toString().contains('chats')) {
        _showErrorSnackBar(_l10n.translate('chat_endpoint_not_found'));
        // Don't show error for individual message loading failure
        return;
      }

      // If there's a SQL error from backend, show helpful message
      if (e.toString().contains('SQLSTATE') &&
          e.toString().contains('ambiguous')) {
        _showErrorSnackBar(_l10n.translate('chat_sql_error'));
        // Don't show error for individual message loading failure
        return;
      }

      _showErrorSnackBar(
        _l10n.translate(
          'chat_failed_to_load_messages',
          params: {'error': e.toString()},
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;
    if (_currentChatId == null && widget.recipientId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      print(
        '[ChatScreen] send message chatId=$_currentChatId recipientId=${widget.recipientId}',
      );
      // Ensure we have a chatId: resolve if needed
      if (_currentChatId == null &&
          widget.recipientId != null &&
          widget.chatType != null) {
        // Try derive again just before resolve (ignore errors, fallback to resolve)
        try {
          final chats = await ref.read(chatsProvider.future);
          final me = ref.read(profileProvider).valueOrNull;
          final meId = int.tryParse(me?.id ?? '') ?? -1;
          for (final c in chats) {
            if ((c.type == 'private' || c.type == null) &&
                c.participants.length == 2) {
              final a = c.participants[0];
              final b = c.participants[1];
              final pivA = a.pivotUserId ?? a.id;
              final pivB = b.pivotUserId ?? b.id;
              final ids = {a.id, b.id};
              if (ids.contains(meId) && ids.contains(widget.recipientId)) {
                if ((pivA == meId && pivB == widget.recipientId) ||
                    (pivB == meId && pivA == widget.recipientId)) {
                  _currentChatId = c.id;
                  print(
                    '[ChatScreen] Late-derived chatId=$_currentChatId before resolve',
                  );
                  break;
                }
              }
            }
          }
        } catch (_) {}
        if (_currentChatId == null) {
          final chat = await ref.read(
            resolveChatProvider((widget.chatType!, widget.recipientId!)).future,
          );
          // Validate resolved chat participants
          final meta = await ref.read(chatProvider(chat.id).future);
          final ids = meta.participants.map((p) => p.id).toSet();
          if (!ids.contains(widget.recipientId)) {
            print(
              '[ChatScreen][ERROR] Resolve returned chatId=${chat.id} not containing recipientId=${widget.recipientId}; aborting send',
            );
            _isSending = false;
            _showErrorSnackBar(_l10n.translate('chat_resolve_wrong_chat'));
            return;
          }
          _currentChatId = chat.id;
          // New chat created/selected; refresh chat list cache
          try {
            ref.invalidate(chatsProvider);
          } catch (_) {}
          print(
            '[ChatScreen] Resolved chatId=$_currentChatId for recipientId=${widget.recipientId} via /chats/resolve',
          );
        }
      }

      if (_currentChatId == null) {
        throw Exception(_l10n.translate('chat_unable_to_resolve'));
      }

      final message = await ref.read(
        sendMessageToChatProvider((_currentChatId!, messageText)).future,
      );

      print(
        '[ChatScreen] Sent message id=${message.id} chatId=${message.chatId} userId=${message.userId} content="${message.content}"',
      );

      // Subscribe for realtime after we have a chat
      ref.read(webSocketServiceProvider).subscribeToChat(_currentChatId!);

      // Set message ownership based on current user
      final currentUser = ref.read(profileProvider).valueOrNull;
      final messageWithOwnership = Message(
        id: message.id,
        content: message.content,
        userId: message.userId,
        userName: message.userName,
        userImage: message.userImage,
        chatId: message.chatId,
        messageType: message.messageType,
        fileName: message.fileName,
        fileSize: message.fileSize,
        fileUrl: message.fileUrl,
        isRead: message.isRead,
        isFromCurrentUser: currentUser?.id == message.userId.toString(),
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
      );

      setState(() {
        _messages.add(messageWithOwnership);
        _isSending = false;
      });

      _scrollToBottom();

      // After send, refetch chat metadata and recent messages for verification logs
      try {
        final chatMeta = await ref.read(chatProvider(_currentChatId!).future);
        print(
          '[ChatScreen] Refetched chat meta: ' + chatMeta.toJson().toString(),
        );
        // Ensure chat list reflects new/updated chat ordering
        try {
          ref.invalidate(chatsProvider);
        } catch (_) {}
      } catch (e) {
        print('[ChatScreen] Refetch chat meta error: $e');
      }
      try {
        final recentMessages = await ref
            .read(chatServiceProvider)
            .getChatMessages(_currentChatId!, perPage: 20);
        print(
          '[ChatScreen] Refetched messages count=${recentMessages.length} chatId=${_currentChatId}',
        );
        if (recentMessages.isNotEmpty) {
          final last = recentMessages.last;
          print(
            '[ChatScreen] Last message after send id=${last.id} userId=${last.userId} content="${last.content}"',
          );
        }
      } catch (e) {
        print('[ChatScreen] Refetch messages error: $e');
      }
    } catch (e) {
      print('[ChatScreen] send message error: $e');
      setState(() {
        _isSending = false;
      });

      // Show user-friendly error message
      String errorMessage = _l10n.translate('chat_failed_to_send');
      if (e.toString().contains('500')) {
        errorMessage = _l10n.translate('chat_server_error');
      } else if (e.toString().contains('401')) {
        errorMessage = _l10n.translate('chat_login_again');
      } else if (e.toString().contains('403')) {
        errorMessage = _l10n.translate('chat_permission_denied');
      } else if (e.toString().contains('422')) {
        errorMessage = _l10n.translate('chat_invalid_message');
      }

      _showErrorSnackBar(errorMessage);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (!mounted) return;
    if (_currentChatId == null) return;
    if (_isSending) return; // avoid clobbering UI during send
    try {
      final fresh = await ref
          .read(chatServiceProvider)
          .getChatMessages(_currentChatId!, perPage: 20);
      if (fresh.isEmpty && _messages.isEmpty) return;
      final lastExistingId = _messages.isNotEmpty ? _messages.last.id : -1;
      final lastFreshId = fresh.isNotEmpty ? fresh.last.id : -1;
      if (lastFreshId != lastExistingId) {
        final currentUser = ref.read(profileProvider).valueOrNull;
        final mapped = fresh
            .map(
              (m) => Message(
                id: m.id,
                content: m.content,
                userId: m.userId,
                userName: m.userName,
                userImage: m.userImage,
                chatId: m.chatId,
                messageType: m.messageType,
                fileName: m.fileName,
                fileSize: m.fileSize,
                fileUrl: m.fileUrl,
                isRead: m.isRead,
                isFromCurrentUser: currentUser?.id == m.userId.toString(),
                createdAt: m.createdAt,
                updatedAt: m.updatedAt,
              ),
            )
            .toList();
        if (!mounted) return;
        setState(() {
          _messages = mapped;
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    });
  }

  Future<void> _handleCallButton(BuildContext context) async {
    if (widget.recipientId == null || widget.chatType != 'user') {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch user details to get phone number
      // Note: Chat participants don't include phone numbers, so we fetch from API
      final phoneNumber = await _fetchUserPhoneNumber(widget.recipientId!);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await _makePhoneCall(context, phoneNumber);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number not available for this user'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not fetch phone number: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _fetchUserPhoneNumber(int userId) async {
    try {
      // Try to get from all directory users first (if available)
      final token = ref.read(authTokenProvider);
      if (token == null) return null;

      // Fetch all users and find the matching one
      final service = BranchUsersService();
      final currentUser = ref.read(profileProvider).valueOrNull;
      final currentUserBranchId = currentUser?.userBranchId;

      if (currentUserBranchId != null) {
        final users = await service.fetchBranchUsers(currentUserBranchId, token);
        final user = users.firstWhere(
          (u) => u.id != null && int.tryParse(u.id!) == userId,
          orElse: () => users.firstWhere(
            (u) => false,
            orElse: () => throw Exception('User not found'),
          ),
        );

        // Get phone number with country code
        if (user.phone != null && user.phone!.isNotEmpty) {
          if (user.countryCode != null && user.countryCode!.isNotEmpty) {
            final phone = user.phone!.trim();
            final countryCode = user.countryCode!.trim();
            // If phone already starts with +, don't add country code
            if (phone.startsWith('+')) {
              return phone;
            }
            return '$countryCode$phone';
          }
          return user.phone!.trim();
        }
      }
      return null;
    } catch (e) {
      print('[ChatScreen] Error fetching user phone: $e');
      return null;
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      // Trim and clean the phone number - remove all whitespace, dashes, parentheses, etc.
      // Keep only digits and + sign
      String cleanedNumber = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');
      
      // Remove any remaining whitespace characters
      cleanedNumber = cleanedNumber.replaceAll(RegExp(r'\s+'), '');
      
      // Ensure the number is not empty
      if (cleanedNumber.isEmpty) {
        throw 'Invalid phone number';
      }
      
      // Create the tel: URI - ensure no spaces
      final uriString = 'tel:$cleanedNumber';
      final uri = Uri.parse(uriString);
      
      // Try to launch the dialer
      bool launched = false;
      
      // First try with external application mode
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          launched = true;
        } catch (e) {
          // If external application fails, try platform default
          try {
            await launchUrl(uri);
            launched = true;
          } catch (e2) {
            throw 'Could not launch dialer: $e2';
          }
        }
      } else {
        throw 'No app available to handle phone calls';
      }
      
      if (!launched) {
        throw 'Could not launch dialer for $cleanedNumber';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make phone call: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(69),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.recipientImage != null
                        ? (widget.recipientImage!.startsWith('http')
                              ? widget.recipientImage!
                              : ApiUrls.getProfileImageUrl(
                                  widget.recipientImage!,
                                ))
                        : '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF6B7B3A),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipientName ??
                          _l10n.translate('chat_default_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      widget.recipientProfession ??
                          _l10n.translate('chat_online_status'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (widget.chatType == 'user' && widget.recipientId != null)
              IconButton(
                onPressed: () => _handleCallButton(context),
                icon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
              ),
            // TODO: Uncomment when backend implementation is ready
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.videocam, color: Color(0xFF2563EB)),
            // ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
            // ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isFromCurrentUser =
                            currentUser?.id == message.userId.toString();
                        return _MessageBubble(
                          message: message,
                          isFromCurrentUser: isFromCurrentUser,
                          l10n: _l10n,
                        );
                      },
                    ),
                  ),
                ),
                _InputArea(
                  controller: _messageController,
                  onSendMessage: _sendMessage,
                  isSending: _isSending,
                ),
              ],
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isFromCurrentUser,
    required this.l10n,
  });

  final Message message;
  final bool isFromCurrentUser;
  final AppLocalizations l10n;

  String _getMessageSenderImageUrl(String? senderImage) {
    if (senderImage == null || senderImage.isEmpty) {
      return '';
    }

    // If the sender image is already a full URL, return it
    if (senderImage.startsWith('http')) {
      return senderImage;
    }

    // If it's a placeholder, return as is
    if (senderImage.contains('placeholder')) {
      return senderImage;
    }

    // Otherwise, construct the full URL using ApiUrls
    return ApiUrls.getProfileImageUrl(senderImage);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12
        ? l10n.translate('time_period_pm')
        : l10n.translate('time_period_am');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _getMessageSenderImageUrl(message.userImage),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF6B7B3A),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isFromCurrentUser)
                  Row(
                    children: [
                      Text(
                        message.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.createdAt != null
                            ? _formatTime(message.createdAt!)
                            : '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                if (isFromCurrentUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.createdAt != null
                            ? _formatTime(message.createdAt!)
                            : '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (message.isRead)
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                    ],
                  ),
                const SizedBox(height: 4),
                _MessageContent(
                  message: message,
                  isFromCurrentUser: isFromCurrentUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.isFromCurrentUser,
  });

  final Message message;
  final bool isFromCurrentUser;

  @override
  Widget build(BuildContext context) {
    final messageType = message.messageType ?? 'text';

    Widget content;

    switch (messageType) {
      case 'file':
        content = _FileAttachment(
          fileName: message.fileName ?? message.content,
          fileSize: message.fileSize ?? '',
          isFromCurrentUser: isFromCurrentUser,
        );
        break;
      case 'image':
        content = _ImageAttachment(
          caption: message.content,
          isFromCurrentUser: isFromCurrentUser,
        );
        break;
      default:
        content = _TextMessage(
          text: message.content,
          isFromCurrentUser: isFromCurrentUser,
        );
    }

    return content;
  }
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({required this.text, required this.isFromCurrentUser});

  final String text;
  final bool isFromCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFromCurrentUser ? const Color(0xFF6B7B3A) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
          bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isFromCurrentUser ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
    );
  }
}

class _FileAttachment extends StatelessWidget {
  const _FileAttachment({
    required this.fileName,
    required this.fileSize,
    required this.isFromCurrentUser,
  });

  final String fileName;
  final String fileSize;
  final bool isFromCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
          bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileSize,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.download, color: Color(0xFF2563EB), size: 20),
        ],
      ),
    );
  }
}

class _ImageAttachment extends StatelessWidget {
  const _ImageAttachment({
    required this.caption,
    required this.isFromCurrentUser,
  });

  final String caption;
  final bool isFromCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
          bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            child: Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              caption,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.controller,
    required this.onSendMessage,
    this.isSending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 81,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // TODO: Uncomment when backend implementation is ready
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.attach_file, color: Color(0xFF6B7280)),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.camera_alt, color: Color(0xFF6B7280)),
          // ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.translate('chat_type_message_hint'),
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFADAEBC),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // TODO: Uncomment when backend implementation is ready
                // suffixIcon: const Icon(
                //   Icons.emoji_emotions,
                //   color: Color(0xFF6B7280),
                // ),
                fillColor: const Color(0xFFF9FAFB),
                filled: true,
              ),
              onSubmitted: (_) => onSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : const Color(0xFF6B7B3A),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
