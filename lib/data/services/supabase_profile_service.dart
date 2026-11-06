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
      final payload = buildEditableProfilePayload(user);
      final response = await _effectiveClient
          .from('profiles')
          .upsert(payload)
          .select()
          .single();

      return AppResult.success(UserModel.fromJson(response));
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

      final payload = buildEditableProfilePayload(user);
      final response = await _effectiveClient
          .from('profiles')
          .upsert(payload)
          .select()
          .single();

      return AppResult.success(UserModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Map<String, dynamic> buildEditableProfilePayload(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'full_name': user.fullName,
      'phone_number': user.phoneNumber,
      'nim': user.nim,
      'avatar_url': user.avatarUrl,
      'ktm_photo_url': user.ktmPhotoUrl,
      'gender': user.gender.name,
      'is_female_only_preferred': user.isFemaleOnlyPreferred,
      'faculty': user.faculty,
      'bio': user.bio,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
