import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_barter_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/repositories/barter_repository.dart';

class BarterRepositoryImpl implements IBarterRepository {
  final SupabaseBarterService? _supabaseBarterService;

  BarterRepositoryImpl({SupabaseBarterService? service})
      : _supabaseBarterService = service;

  @override
  Future<AppResult<List<BarterItemModel>>> getBarterItems() async {
    final service = _supabaseBarterService;
    if (service != null) {
      final result = await service.getBarterItems();
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(const [
      BarterItemModel(
        id: 'b1',
        title: 'Makanan',
        description: 'Tukar jasa dengan makanan',
        type: BarterType.makanan,
        iconAsset: 'fastfood_rounded',
      ),
      BarterItemModel(
        id: 'b2',
        title: 'Barang',
        description: 'Tukar jasa dengan barang',
        type: BarterType.barang,
        iconAsset: 'card_giftcard_rounded',
      ),
    ]);
  }
}
