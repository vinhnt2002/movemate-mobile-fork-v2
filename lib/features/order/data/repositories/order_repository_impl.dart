// import local
import 'package:movemate/features/order/data/models/request/order_query_request.dart';
import 'package:movemate/features/order/data/models/request/service_query_request.dart';
import 'package:movemate/features/order/data/models/ressponse/order_reponse.dart';
import 'package:movemate/features/order/data/models/ressponse/service_response.dart';
import 'package:movemate/features/order/data/models/ressponse/truck_category_obj_response.dart';
import 'package:movemate/features/order/data/models/ressponse/truck_categorys_response.dart';
import 'package:movemate/features/order/data/remote/order_remote/order_source.dart';
import 'package:movemate/features/order/domain/repositories/order_repository.dart';
import 'package:movemate/models/request/paging_model.dart';

// utils
import 'package:movemate/utils/constants/api_constant.dart';
import 'package:movemate/utils/resources/remote_base_repository.dart';

class OrderRepositoryImpl extends RemoteBaseRepository
    implements OrderRepository {
  final bool addDelay;
  final OrderSource _orderSource;

  OrderRepositoryImpl(this._orderSource, {this.addDelay = true});

  @override
  Future<OrderReponse> getBookings({
    required PagingModel request,
    required String accessToken,
    required int userId,
  }) async {
    final orderQueryRequest = OrderQueryRequest(
      search: request.searchContent,
      page: request.pageNumber,
      perPage: request.pageSize,
      UserId: userId,
    );

    print("vinh log order : ${orderQueryRequest.toJson()}");
    return getDataOf(
      request: () => _orderSource.getBookings(
        APIConstants.contentType,
        accessToken,
        orderQueryRequest,
      ),
    );
  }

  @override
  Future<ServiceResponse> getAllService({
    required PagingModel request,
    required String accessToken,
    // required int userId,
  }) async {
    final serviceQueryRequest = ServiceQueryRequest(
      search: request.searchContent,
      type: 'TRUCK',
      page: request.pageNumber,
      perPage: request.pageSize,
      // UserId: userId,
    );

    print("tuan log order : ${serviceQueryRequest.toJson()}");
    return getDataOf(
      request: () => _orderSource.getAllService(
        APIConstants.contentType,
        accessToken,
        serviceQueryRequest,
      ),
    );
  }

  @override
  Future<TruckCategorysResponse> getTruckList({
    required PagingModel request,
    required String accessToken,
  }) async {
    return getDataOf(
      request: () =>
          _orderSource.getTruckList(APIConstants.contentType, accessToken),
    );
  }

  @override
  Future<TruckCategoryObjResponse> getTruckById({
    required String accessToken,
    required int id,
  }) async {
    // print("repo log $id");
    return getDataOf(
      request: () => _orderSource.getTruckById(
        APIConstants.contentType,
        accessToken,
        id,
      ),
    );
  }
}
