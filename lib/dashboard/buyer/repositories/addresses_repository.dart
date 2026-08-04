import 'dart:convert';
import '../../../core/utils/prefs_cache.dart';
import '../models/models.dart';

class AddressesRepository {
  static const String _storageKey = 'saved_addresses';
  final PrefsCache _cache = PrefsCache();

  List<UserAddress> getAll() {
    final raw = _cache.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((j) => UserAddress.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  void _saveAll(List<UserAddress> addresses) {
    final raw = jsonEncode(addresses.map((a) => a.toJson()).toList());
    _cache.setString(_storageKey, raw);
  }

  UserAddress create(Map<String, dynamic> data) {
    final addresses = getAll();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final address = UserAddress(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
    _saveAll([...addresses, address]);
    return address;
  }

  UserAddress update(String id, Map<String, dynamic> data) {
    final addresses = getAll();
    final index = addresses.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Address not found');

    final existing = addresses[index];
    final updated = UserAddress(
      id: id,
      name: data['name'] as String? ?? existing.name,
      address: data['address'] as String? ?? existing.address,
      phone: data['phone'] as String? ?? existing.phone,
      isDefault: data['isDefault'] as bool? ?? existing.isDefault,
      latitude: data['latitude'] as double? ?? existing.latitude,
      longitude: data['longitude'] as double? ?? existing.longitude,
    );
    final updatedList = [...addresses];
    updatedList[index] = updated;
    _saveAll(updatedList);
    return updated;
  }

  void delete(String id) {
    final addresses = getAll();
    _saveAll(addresses.where((a) => a.id != id).toList());
  }

  UserAddress setDefault(String id) {
    final addresses = getAll();
    final updatedList = addresses.map((a) {
      if (a.id == id) {
        return UserAddress(
          id: a.id,
          name: a.name,
          address: a.address,
          phone: a.phone,
          isDefault: true,
          latitude: a.latitude,
          longitude: a.longitude,
        );
      }
      if (a.isDefault) {
        return UserAddress(
          id: a.id,
          name: a.name,
          address: a.address,
          phone: a.phone,
          isDefault: false,
          latitude: a.latitude,
          longitude: a.longitude,
        );
      }
      return a;
    }).toList();

    _saveAll(updatedList);
    return updatedList.firstWhere((a) => a.id == id);
  }
}
