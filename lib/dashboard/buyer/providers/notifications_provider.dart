import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.getAll();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notif = ref.watch(notificationsProvider);
  final list = notif.asData?.value;
  if (list == null) return 0;
  return list.where((n) => !n.isRead).length;
});
