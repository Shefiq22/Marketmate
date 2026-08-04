import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/chat/services/cloudinary_upload_service.dart';

final cloudinaryUploadServiceProvider = Provider<CloudinaryUploadService>(
  (ref) => CloudinaryUploadService(),
);

class CloudinarySignatureState extends Notifier<Map<String, Map<String, dynamic>>> {
  @override
  Map<String, Map<String, dynamic>> build() => {};

  Future<Map<String, dynamic>> getSignature(String folder) async {
    final cached = state[folder];
    if (cached != null) return cached;

    final service = ref.read(cloudinaryUploadServiceProvider);
    final sig = await service.getSignature(folder);
    state = {...state, folder: sig};
    return sig;
  }

  void invalidate(String folder) {
    state = Map.from(state)..remove(folder);
  }
}

final cloudinarySignatureProvider = NotifierProvider<CloudinarySignatureState, Map<String, Map<String, dynamic>>>(
  CloudinarySignatureState.new,
);
