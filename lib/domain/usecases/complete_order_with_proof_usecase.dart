import 'dart:io';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';

class CompleteOrderWithProofUseCase {
  final IServiceOrderRepository _repository;

  CompleteOrderWithProofUseCase(this._repository);

  Future<AppResult<ServiceOrderModel>> execute(String orderId, File photo) {
    return _repository.completeOrderWithProof(orderId, photo);
  }
}
