import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/features/chat/models/order_message_model.dart';

class ChatRepository {
  final ApiClient _client = ApiClient();

  Future<MessageListResponse> getMessages(
    String orderId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _client.get(
      ApiEndpoints.messages(orderId),
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    return MessageListResponse.fromJson({
      'data': response.data,
      'meta': response.meta,
    });
  }

  Future<OrderMessage> sendMessage(
    String orderId, {
    String? content,
    String? imageUrl,
  }) async {
    if ((content == null || content.isEmpty) && (imageUrl == null || imageUrl.isEmpty)) {
      throw Exception('Message content or image is required');
    }
    final body = <String, dynamic>{};
    if (content != null && content.isNotEmpty) {
      body['content'] = content;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      body['imageUrl'] = imageUrl;
    }
    final response = await _client.post(
      ApiEndpoints.messages(orderId),
      body: body,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    return OrderMessage.fromJson(
      (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : {'content': content, 'imageUrl': imageUrl, 'createdAt': DateTime.now().toIso8601String()},
    );
  }

  Future<void> markAsRead(String orderId) async {
    final response = await _client.patch(
      ApiEndpoints.messagesRead(orderId),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
