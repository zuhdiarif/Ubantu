import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_barter_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/barter_item_model.dart';
import 'package:ubantu/data/repositories/barter_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';

class BarterRepositoryImpl implements IBarterRepository, SessionScoped {
  final SupabaseBarterService _remoteService;

  BarterRepositoryImpl({
    SupabaseBarterService? remoteService,
    SupabaseBarterService? service,
  }) : _remoteService = remoteService ?? service ?? SupabaseBarterService();

  @override
  void clearSessionCache() {}

  bool get hasRemoteService => true;
  SupabaseBarterService get remoteService => _remoteService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<List<BarterItemModel>>> getBarterItems() async {
    if (_useSupabase) {
      return await _remoteService.getBarterItems();
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

  Future<AppResult<List<BarterItemModel>>> getListings() => getBarterItems();

  Future<AppResult<BarterItemModel>> createListing(BarterItemModel item) async {
    return AppResult.success(item);
  }
}
