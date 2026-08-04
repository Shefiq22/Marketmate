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
}
