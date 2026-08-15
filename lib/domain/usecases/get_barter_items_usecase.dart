import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/barter_service.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';

class GetBarterItemsUseCase {
  final BarterService _service;

  GetBarterItemsUseCase({BarterService? service})
      : _service = service ?? BarterService();

  Future<AppResult<List<BarterItemModel>>> execute() {
    return _service.fetchAvailableBarterItems();
  }
}
