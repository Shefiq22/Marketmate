import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/chat/models/order_message_model.dart';
import 'package:market_mate/features/chat/services/chat_repository.dart';
import 'package:market_mate/features/chat/services/cloudinary_upload_service.dart';
import 'package:market_mate/features/chat/providers/cloudinary_providers.dart';
import 'package:market_mate/features/chat/providers/socket_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

class ChatMessageState extends Notifier<Map<String, List<OrderMessage>>> {
  @override
  Map<String, List<OrderMessage>> build() => {};

  void setMessages(String orderId, List<OrderMessage> messages) {
    state = {...state, orderId: messages};
  }

  void addMessage(String orderId, OrderMessage message) {
    final list = (state[orderId] ?? [])..add(message);
    state = {...state, orderId: list};
  }
}

final chatMessageStateProvider =
    NotifierProvider<ChatMessageState, Map<String, List<OrderMessage>>>(
      () => ChatMessageState(),
);

final messageListProvider = Provider.family<List<OrderMessage>, String>(
  (ref, orderId) => ref.watch(chatMessageStateProvider)[orderId] ?? [],
);

class ChatLoadingState extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void setLoading(String orderId, bool loading) {
    state = {...state, orderId: loading};
  }
}

final chatLoadingStateProvider =
    NotifierProvider<ChatLoadingState, Map<String, bool>>(
      () => ChatLoadingState(),
);

final messagesLoadingProvider = Provider.family<bool, String>(
  (ref, orderId) => ref.watch(chatLoadingStateProvider)[orderId] ?? false,
);

final _loadMessagesProvider = FutureProvider.family<void, String>(
  (ref, orderId) async {
    final repo = ref.read(chatRepositoryProvider);
    final response = await repo.getMessages(orderId);
    ref.read(chatMessageStateProvider.notifier).setMessages(orderId, response.messages);
  },
);

Future<void> loadOrderMessages(WidgetRef ref, String orderId) async {
  ref.read(chatLoadingStateProvider.notifier).setLoading(orderId, true);
  try {
    await ref.refresh(_loadMessagesProvider(orderId).future);
    final socketService = ref.read(socketServiceProvider);
    socketService.joinOrder(orderId);
  } catch (e) {
    debugPrint('[Chat] Load failed: $e');
  }
  ref.read(chatLoadingStateProvider.notifier).setLoading(orderId, false);
}

void listenForNewMessages(WidgetRef ref, String orderId) {
  ref.listen(socketNewMessageProvider, (previous, next) {
    next.whenData((message) {
      if (message.orderId == orderId) {
        ref.read(chatMessageStateProvider.notifier).addMessage(orderId, message);
      }
    });
  });
}

Future<void> sendTextMessage(WidgetRef ref, String orderId, String content) async {
  if (content.trim().isEmpty) return;
  try {
    final repo = ref.read(chatRepositoryProvider);
    final message = await repo.sendMessage(orderId, content: content);
    ref.read(chatMessageStateProvider.notifier).addMessage(orderId, message);
  } catch (e) {
    debugPrint('[Chat] Send failed: $e');
  }
}

Future<void> sendImageMessage(WidgetRef ref, String orderId, String filePath) async {
  try {
    final uploader = ref.read(cloudinaryUploadServiceProvider);
    final imageUrl = await uploader.uploadImage(
      File(filePath),
      folder: 'chat',
    );
    final repo = ref.read(chatRepositoryProvider);
    final message = await repo.sendMessage(orderId, imageUrl: imageUrl);
    ref.read(chatMessageStateProvider.notifier).addMessage(orderId, message);
  } catch (e) {
    debugPrint('[Chat] Image send failed: $e');
  }
}

Future<void> markMessagesRead(WidgetRef ref, String orderId) async {
  try {
    final repo = ref.read(chatRepositoryProvider);
    await repo.markAsRead(orderId);
  } catch (_) {}
}

String formatTimestamp(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$h:$m$ampm';
  }
  return '${dt.day}/${dt.month}/${dt.year}';
}
