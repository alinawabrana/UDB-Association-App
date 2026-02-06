import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:udb_association/src/features/chat/models/chat_models.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamController<Message>? _messageController;
  StreamController<String>? _connectionController;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isConnecting = false;
  final TokenStorage _tokenStorage = const TokenStorage();

  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  /// Stream of incoming messages
  Stream<Message> get messageStream {
    _messageController ??= StreamController<Message>.broadcast();
    return _messageController!.stream;
  }

  /// Stream of connection status
  Stream<String> get connectionStream {
    _connectionController ??= StreamController<String>.broadcast();
    return _connectionController!.stream;
  }

  bool get isConnected => _isConnected;

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionController?.add('connecting');
    print('[WebSocket] Connecting...');

    try {
      final token = await _tokenStorage.readToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Replace with your actual WebSocket URL
      final wsUrl = 'wss://udbconnect.com/ws?token=$token';
      print('[WebSocket] URL: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _isConnecting = false;
      _connectionController?.add('connected');
      print('[WebSocket] Connected');

      // Cancel any existing reconnect timer
      _reconnectTimer?.cancel();
    } catch (e) {
      _isConnecting = false;
      _connectionController?.add('error');
      _scheduleReconnect();
      print('[WebSocket] Connect error: $e');
      rethrow;
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    _connectionController?.add('disconnected');
    print('[WebSocket] Disconnected');
  }

  /// Send a message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      print('[WebSocket] send: $message');
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> messageData = jsonDecode(data);
      print('[WebSocket] recv: $messageData');

      // Check if it's a message event
      if (messageData['type'] == 'message' && messageData['data'] != null) {
        final message = Message.fromJson(messageData['data']);
        _messageController?.add(message);
      }
    } catch (e) {
      print('[WebSocket] Handle message error: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    print('[WebSocket] Error: $error');
    _connectionController?.add('error');
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _isConnected = false;
    _connectionController?.add('disconnected');
    _scheduleReconnect();
    print('[WebSocket] Disconnected (onDone)');
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isConnecting) {
        print('[WebSocket] Reconnecting...');
        connect();
      }
    });
  }

  /// Subscribe to a chat channel
  void subscribeToChat(int chatId) {
    if (_isConnected) {
      print('[WebSocket] subscribe chat=$chatId');
      sendMessage({'type': 'subscribe', 'chat_id': chatId});
    }
  }

  /// Unsubscribe from a chat channel
  void unsubscribeFromChat(int chatId) {
    if (_isConnected) {
      print('[WebSocket] unsubscribe chat=$chatId');
      sendMessage({'type': 'unsubscribe', 'chat_id': chatId});
    }
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _messageController?.close();
    _connectionController?.close();
    _channel?.sink.close();
    _instance = null;
  }
}
