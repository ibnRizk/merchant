import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/params/order_command.dart';
import '../exceptions/transition_rejected_exception.dart';
import '../models/order_models.dart';

/// Talks to the `/vendor` order routes. Throws [AppException]s; the
/// repository turns them into failures. On commands, a stale
/// `expected_version` surfaces as [ConflictException] (HTTP 409), and an
/// order that moved on (HTTP 404, or 422 `order_transition_invalid`) as
/// [TransitionRejectedException].
abstract class OrdersRemoteDataSource {
  Future<List<MerchantOrder>> getCurrentOrders();

  Future<OrderHistoryPage> getCompletedOrders({
    required int page,
    required int limit,
  });

  Future<MerchantOrder> getOrder(int orderId);

  Future<List<OrderLine>> getOrderLines(int orderId);

  Future<OrderStatusChange> sendCommand(
    OrderCommand command, {
    required String idempotencyKey,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioConsumer _client;

  const OrdersRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<List<MerchantOrder>> getCurrentOrders() async {
    final dynamic response = await _client.get(ApiEndpoints.currentOrders);
    if (response is List) return parseOrders(response);
    // Tolerate a wrapped list, as the history endpoint uses.
    if (response is Map<String, dynamic>) {
      return parseOrders(response['orders'] ?? response['data']);
    }
    throw const ServerException(message: 'Unexpected response format.');
  }

  /// `offset` is the page number on this endpoint, not a row offset.
  @override
  Future<OrderHistoryPage> getCompletedOrders({
    required int page,
    required int limit,
  }) async => OrderHistoryPageModel.fromJson(
    _asMap(
      await _client.get(
        ApiEndpoints.completedOrders,
        queryParameters: <String, dynamic>{'offset': page, 'limit': limit},
      ),
    ),
  );

  @override
  Future<MerchantOrder> getOrder(int orderId) async {
    final Map<String, dynamic> json = _asMap(
      await _client.get(
        ApiEndpoints.orderSummary,
        queryParameters: <String, dynamic>{'order_id': orderId},
      ),
    );
    final dynamic order = json['order'];
    return MerchantOrderModel.fromJson(
      order is Map<String, dynamic> ? order : json,
    );
  }

  @override
  Future<List<OrderLine>> getOrderLines(int orderId) async => parseOrderLines(
    await _client.get(
      ApiEndpoints.orderLines,
      queryParameters: <String, dynamic>{'order_id': orderId},
    ),
  );

  @override
  Future<OrderStatusChange> sendCommand(
    OrderCommand command, {
    required String idempotencyKey,
  }) async {
    final dynamic response;
    try {
      response = await _client.post(
        ApiEndpoints.orderCommand(command.orderId, command.action.path),
        headers: <String, String>{'Idempotency-Key': idempotencyKey},
        body: <String, dynamic>{
          if (command.expectedVersion != null)
            'expected_version': command.expectedVersion,
          if (command.reason != null) 'reason': command.reason,
          if (command.note?.trim().isNotEmpty ?? false)
            'note': command.note!.trim(),
        },
      );
    } on ServerException catch (error) {
      throw TransitionRejectedException.from(error) ?? error;
    }
    return parseStatusChange(_asMap(response), command.orderId);
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw const ServerException(message: 'Unexpected response format.');
  }
}
