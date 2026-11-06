import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/user_model.dart';

class SupabaseProfileService {
  final SupabaseClient? _client;

  SupabaseProfileService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<UserModel>> getProfile(String userId) async {
    try {
      final response = await _effectiveClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return AppResult.failure('Profil tidak ditemukan');
      }

      return AppResult.success(UserModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    try {
      final json = user.toJson();
      try {
        final response = await _effectiveClient
            .from('profiles')
            .upsert(json)
            .select()
            .single();

        return AppResult.success(UserModel.fromJson(response));
      } catch (upsertError) {
        final err = upsertError.toString().toLowerCase();
        if (err.contains('faculty') || err.contains('bio') || err.contains('pgrst204')) {
          final fallbackJson = Map<String, dynamic>.from(json)
            ..remove('faculty')
            ..remove('bio');
          final response = await _effectiveClient
              .from('profiles')
              .upsert(fallbackJson)
              .select()
              .single();
          return AppResult.success(UserModel.fromJson(response));
        }
        rethrow;
      }
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> ensureProfileExists(UserModel user) async {
    try {
      final existing = await _effectiveClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        return AppResult.success(UserModel.fromJson(existing));
      }

      final json = user.toJson();
      try {
        final response = await _effectiveClient
            .from('profiles')
            .upsert(json)
            .select()
            .single();

        return AppResult.success(UserModel.fromJson(response));
      } catch (upsertError) {
        final err = upsertError.toString().toLowerCase();
        if (err.contains('faculty') || err.contains('bio') || err.contains('pgrst204')) {
          final fallbackJson = Map<String, dynamic>.from(json)
            ..remove('faculty')
            ..remove('bio');
          final response = await _effectiveClient
              .from('profiles')
              .upsert(fallbackJson)
              .select()
              .single();
          return AppResult.success(UserModel.fromJson(response));
        }
        rethrow;
      }
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
