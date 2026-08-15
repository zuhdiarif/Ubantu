import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';

abstract class IBarterRepository {
  Future<AppResult<List<BarterItemModel>>> getBarterItems();
}
