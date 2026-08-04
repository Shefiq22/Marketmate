import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/features/chat/models/order_message_model.dart';
import 'package:market_mate/features/chat/services/socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() {
    service.dispose();
  });

  if (ApiClient().isAuthenticated) {
    Future.microtask(() => service.connect());
  }

  return service;
});

final socketNewMessageProvider = StreamProvider<OrderMessage>((ref) {
  final service = ref.watch(socketServiceProvider);
  return service.messageStream;
});
