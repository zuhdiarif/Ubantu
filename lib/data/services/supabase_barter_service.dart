import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';

class SupabaseBarterService {
  final SupabaseClient? _client;

  SupabaseBarterService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<BarterItemModel>>> getBarterItems() async {
    try {
      final response = await _effectiveClient
          .from('barter_items')
          .select()
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => BarterItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
