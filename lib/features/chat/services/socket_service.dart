import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:market_mate/core/config/app_config.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/features/chat/models/order_message_model.dart';

class SocketService {
  IO.Socket? _socket;
  final _messageController = StreamController<OrderMessage>.broadcast();
  bool _isConnected = false;

  Stream<OrderMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null && _isConnected) return;

    final token = ApiClient().accessToken;
    if (token == null || token.isEmpty) {
      debugPrint('[Socket] No access token — skipping connection');
      return;
    }

    final uri = '${AppConfig.baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/orders';

    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('[Socket] Connected to /orders namespace');
    });

    _socket!.on('new_message', (data) {
      try {
        final map = data as Map<String, dynamic>;
        final message = OrderMessage.fromJson(map);
        _messageController.add(message);
        debugPrint('[Socket] New message received: ${message.id}');
      } catch (e) {
        debugPrint('[Socket] Failed to parse message: $e');
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('[Socket] Disconnected');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] Error: $err');
      _tryReconnect();
    });

    _socket!.connect();
  }

  void joinOrder(String orderId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_order', {'orderId': orderId});
      debugPrint('[Socket] Joined order room: $orderId');
    }
  }

  void leaveOrder(String orderId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_order', {'orderId': orderId});
      debugPrint('[Socket] Left order room: $orderId');
    }
  }

  void _tryReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_socket != null && !_isConnected) {
        debugPrint('[Socket] Attempting reconnection...');
        _socket!.connect();
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    debugPrint('[Socket] Fully disconnected');
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
