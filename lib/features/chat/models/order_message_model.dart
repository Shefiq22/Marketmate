class OrderMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? readAt;

  const OrderMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    this.senderRole = 'customer',
    this.content = '',
    this.imageUrl,
    required this.createdAt,
    this.readAt,
  });

  bool get isImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory OrderMessage.fromJson(Map<String, dynamic> json) {
    return OrderMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? json['order_id'] ?? '').toString(),
      senderId: (json['senderId'] ?? json['sender_id'] ?? json['sender'] ?? '').toString(),
      senderName: (json['senderName'] ?? json['sender_name'] ?? json['name'] ?? 'Unknown').toString(),
      senderRole: (json['senderRole'] ?? json['sender_role'] ?? json['role'] ?? 'customer').toString(),
      content: (json['content'] ?? json['text'] ?? json['message'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    if (content.isNotEmpty) 'content': content,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

class MessageListResponse {
  final List<OrderMessage> messages;
  final int totalPages;
  final int currentPage;
  final bool hasMore;

  const MessageListResponse({
    required this.messages,
    this.totalPages = 1,
    this.currentPage = 1,
    this.hasMore = false,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final items = (data['items'] ?? data['messages'] ?? data['data'] ?? []) as List<dynamic>;
    final meta = (json['meta'] ?? data['meta'] ?? {}) as Map<String, dynamic>; // Fixed type

    return MessageListResponse(
      messages: items
          .map((m) => OrderMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalPages: (meta['totalPages'] ?? meta['pages'] ?? 1) as int,
      currentPage: (meta['page'] ?? meta['currentPage'] ?? 1) as int,
      hasMore: (meta['hasMore'] ?? meta['has_next'] ?? false) as bool,
    );
  }
}
