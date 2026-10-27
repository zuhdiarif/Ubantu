import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';

class SupabaseStorageService {
  final SupabaseClient? _client;

  SupabaseStorageService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  bool get isAvailable {
    if (_client != null) return true;
    return SupabaseService.instance.isInitialized;
  }

  Future<AppResult<String>> uploadKtmPhoto(File file, String userId) async {
    if (!isAvailable) {
      return AppResult.success(file.path);
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'ktm_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'ktm/$fileName';

      await _effectiveClient.storage.from('ktm_photos').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('ktm_photos').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.success(file.path);
    }
  }

  Future<AppResult<String>> uploadAvatar(File file, String userId) async {
    if (!isAvailable) {
      return AppResult.success(file.path);
    }
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'avatars/$fileName';

      await _effectiveClient.storage.from('avatars').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('avatars').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.success(file.path);
    }
  }

  Future<AppResult<String>> uploadTaskImage(File file, String taskId) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'task_${taskId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'tasks/$fileName';

      await _effectiveClient.storage.from('task_images').upload(path, file);
      final publicUrl = _effectiveClient.storage.from('task_images').getPublicUrl(path);

      return AppResult.success(publicUrl);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<String>> uploadOrderPhoto(File file, String category) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final fileExt = file.path.split('.').last;
        final fileName = 'order_${category}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final path = 'orders/$fileName';

        await _effectiveClient.storage.from('order_photos').upload(path, file);
        final publicUrl = _effectiveClient.storage.from('order_photos').getPublicUrl(path);

        return AppResult.success(publicUrl);
      }
      return AppResult.success(file.path);
    } catch (_) {
      return AppResult.success(file.path);
    }
  }
}
