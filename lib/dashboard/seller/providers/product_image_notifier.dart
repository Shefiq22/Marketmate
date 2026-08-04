import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum ImageSlotStatus { pending, uploading, done, failed }

class ImageSlot {
  final File file;
  final ImageSlotStatus status;
  final String? url;
  final String? error;

  const ImageSlot({
    required this.file,
    this.status = ImageSlotStatus.pending,
    this.url,
    this.error,
  });

  ImageSlot copyWith({
    File? file,
    ImageSlotStatus? status,
    String? url,
    String? error,
  }) =>
      ImageSlot(
        file: file ?? this.file,
        status: status ?? this.status,
        url: url ?? this.url,
        error: error ?? this.error,
      );
}

class ProductImagesNotifier extends Notifier<List<ImageSlot>> {
  static const int maxImages = 5;

  @override
  List<ImageSlot> build() => [];

  bool get isFull => state.length >= maxImages;
  int get remaining => maxImages - state.length;
  int get uploadedCount =>
      state.where((s) => s.status == ImageSlotStatus.done).length;
  int get pendingCount =>
      state.where((s) => s.status == ImageSlotStatus.pending).length;

  List<String> get uploadedUrls =>
      state
          .where(
              (s) => s.status == ImageSlotStatus.done && s.url != null)
          .map((s) => s.url!)
          .toList();

  Future<void> pickFromCamera() async {
    if (isFull) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        state = [...state, ImageSlot(file: File(file.path))];
      }
    } catch (_) {}
  }

  Future<void> pickFromFiles() async {
    if (isFull) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'heic', 'webp'],
        allowMultiple: true,
      );
      if (result != null) {
        final newSlots = result.files
            .where((f) => f.path != null)
            .take(remaining)
            .map((f) => ImageSlot(file: File(f.path!)))
            .toList();
        if (newSlots.isNotEmpty) state = [...state, ...newSlots];
      }
    } catch (_) {}
  }

  void removeAt(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state.take(index), ...state.skip(index + 1)];
    }
  }

  void markUploading(int index) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.take(index),
        state[index].copyWith(status: ImageSlotStatus.uploading, error: null),
        ...state.skip(index + 1),
      ];
    }
  }

  void markDone(int index, String url) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.take(index),
        state[index].copyWith(status: ImageSlotStatus.done, url: url),
        ...state.skip(index + 1),
      ];
    }
  }

  void markFailed(int index, String error) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.take(index),
        state[index].copyWith(status: ImageSlotStatus.failed, error: error),
        ...state.skip(index + 1),
      ];
    }
  }

  void clear() => state = [];
}

final productImagesProvider =
    NotifierProvider<ProductImagesNotifier, List<ImageSlot>>(
  ProductImagesNotifier.new,
);
