import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/barter_item_model.dart';
import 'package:ubantu/data/repositories/barter_repository.dart';

class GetBarterItemsUseCase {
  final IBarterRepository repository;

  GetBarterItemsUseCase(this.repository);

  Future<AppResult<List<BarterItemModel>>> execute() {
    return repository.getBarterItems();
  }
}
