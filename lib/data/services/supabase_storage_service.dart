import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';

extension AppResultExtension<T> on AppResult<T> {
  bool get isFailure => !isSuccess;
  String? get errorOrNull => errorMessage;
}

class SupabaseStorageService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  final SupabaseClient? _client;

  SupabaseStorageService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  bool get isAvailable {
    if (_client != null) return true;
    return SupabaseService.instance.isInitialized;
  }

  Future<AppResult<void>> _validateFile(File file) async {
    if (!await file.exists()) {
      return AppResult.failure('File tidak ditemukan di perangkat.');
    }
    final size = await file.length();
    if (size > maxFileSizeBytes) {
      return AppResult.failure('Ukuran file maksimal 5 MB. Silakan pilih file yang lebih kecil.');
    }
    return AppResult.success(null);
  }

  Future<AppResult<String>> uploadKtmPhoto(File file, String userId) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'ktm_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'ktm/$fileName';

      await _effectiveClient.storage.from('ktm_photos').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('ktm_photos').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }

  Future<AppResult<String>> uploadAvatar(File file, String userId) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'avatars/$fileName';

      await _effectiveClient.storage.from('avatars').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('avatars').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }

  Future<AppResult<String>> uploadTaskImage(File file, String taskId) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'task_${taskId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'tasks/$fileName';

      await _effectiveClient.storage.from('task_images').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('task_images').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }

  Future<AppResult<String>> uploadOrderPhoto(File file, String category) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'order_${category}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'orders/$fileName';

      await _effectiveClient.storage.from('order_photos').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('order_photos').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (_) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }

  Future<AppResult<String>> uploadChatAttachment(File file, String roomId) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'chat_${roomId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'chat/$fileName';

      await _effectiveClient.storage.from('chat_attachments').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('chat_attachments').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (_) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }

  Future<AppResult<String>> uploadCompletionProof(File file, String orderId) async {
    final validation = await _validateFile(file);
    if (validation.isFailure) {
      return AppResult.failure(validation.errorOrNull!);
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan penyimpanan cloud belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$orderId/$fileName';

      await _effectiveClient.storage.from('order-proofs').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('order-proofs').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (_) {
      return AppResult.failure('Gagal mengunggah file ke server. Silakan coba lagi.');
    }
  }
}
