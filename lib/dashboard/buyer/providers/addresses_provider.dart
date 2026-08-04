import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/addresses_repository.dart';

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  return AddressesRepository();
});

class AddressesNotifier extends Notifier<List<UserAddress>> {
  @override
  List<UserAddress> build() {
    final repo = ref.read(addressesRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    final repo = ref.read(addressesRepositoryProvider);
    state = repo.getAll();
  }

  void add(Map<String, dynamic> data) {
    final repo = ref.read(addressesRepositoryProvider);
    final created = repo.create(data);
    state = [...state, created];
  }

  void edit(String id, Map<String, dynamic> data) {
    final repo = ref.read(addressesRepositoryProvider);
    final updated = repo.update(id, data);
    state = [
      for (final a in state)
        if (a.id == id) updated else a,
    ];
  }

  void remove(String id) {
    final repo = ref.read(addressesRepositoryProvider);
    repo.delete(id);
    state = state.where((a) => a.id != id).toList();
  }

  void setDefault(String id) {
    final repo = ref.read(addressesRepositoryProvider);
    final updated = repo.setDefault(id);
    state = [
      for (final a in state)
        if (a.id == id)
          updated
        else
          UserAddress(
            id: a.id,
            name: a.name,
            address: a.address,
            phone: a.phone,
            isDefault: false,
            latitude: a.latitude,
            longitude: a.longitude,
          ),
    ];
  }
}

final addressesProvider = NotifierProvider<AddressesNotifier, List<UserAddress>>(
  AddressesNotifier.new,
);
