import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';

class BarterService {
  Future<AppResult<List<BarterItemModel>>> fetchAvailableBarterItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final items = [
      const BarterItemModel(
        id: 'b1',
        title: 'Makanan',
        description: 'Tukar dengan makanan',
        type: BarterType.makanan,
        iconAsset: 'fastfood_rounded',
      ),
      const BarterItemModel(
        id: 'b2',
        title: 'Barang',
        description: 'Tukar dengan barang',
        type: BarterType.barang,
        iconAsset: 'card_giftcard_rounded',
      ),
    ];
    return AppResult.success(items);
  }
}
