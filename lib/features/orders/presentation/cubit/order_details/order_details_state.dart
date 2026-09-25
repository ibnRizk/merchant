import '../../../domain/entities/merchant_order.dart';
import '../../../domain/entities/order_line.dart';
import '../order_notice.dart';

sealed class OrderDetailsState {
  const OrderDetailsState();
}

final class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

final class OrderDetailsLoadFailure extends OrderDetailsState {
  final String message;

  const OrderDetailsLoadFailure(this.message);
}

final class OrderDetailsLoaded extends OrderDetailsState {
  final MerchantOrder order;
  final List<OrderLine> lines;

  /// A command is in flight.
  final bool isBusy;

  /// Describes only the emit it came with (see [OrderNotice]).
  final OrderNotice? notice;

  const OrderDetailsLoaded({
    required this.order,
    required this.lines,
    this.isBusy = false,
    this.notice,
  });

  /// [notice] is not carried over.
  OrderDetailsLoaded copyWith({
    MerchantOrder? order,
    List<OrderLine>? lines,
    bool? isBusy,
    OrderNotice? notice,
  }) => OrderDetailsLoaded(
    order: order ?? this.order,
    lines: lines ?? this.lines,
    isBusy: isBusy ?? this.isBusy,
    notice: notice,
  );
}
