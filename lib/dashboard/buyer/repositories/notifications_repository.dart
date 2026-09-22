import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart' show ApiEndpoints;
import '../models/models.dart';

class NotificationsRepository {
  final ApiClient _client = ApiClient();

  Future<List<AppNotification>> getAll() async {
    final res = await _client.get(ApiEndpoints.notifications);
    if (!res.success) throw Exception(res.message);

    return res.dataList
        .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _client.patch(ApiEndpoints.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _client.patch(ApiEndpoints.notificationsReadAll);
  }

  Future<void> delete(String id) async {
    await _client.delete(ApiEndpoints.deleteNotification(id));
  }

  Future<int> unreadCount() async {
    final res = await _client.get(ApiEndpoints.notificationsUnreadCount);
    if (!res.success) return 0;
    final data = res.data;
    if (data is num) return data.toInt();
    if (data is Map<String, dynamic>) {
      final n = data['count'] ?? data['unreadCount'];
      if (n is num) return n.toInt();
    }
    return 0;
  }
}
