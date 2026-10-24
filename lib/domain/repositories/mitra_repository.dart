import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

abstract class IMitraRepository {
  Future<AppResult<MitraProfileModel>> getMitraProfile();
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline);
  Future<AppResult<bool>> updateServiceCategories(List<ServiceCategory> categories);
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders();
  Future<AppResult<ServiceOrderModel?>> getActiveOrder();
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders();
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory();
  Future<AppResult<bool>> acceptOrder(String orderId);
  Future<AppResult<bool>> declineOrder(String orderId);
  Future<AppResult<bool>> updateOrderStatus(String orderId, MoveServiceStatus status);
}
