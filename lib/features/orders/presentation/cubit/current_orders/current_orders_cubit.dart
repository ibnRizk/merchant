import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/merchant_order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/failures/transition_rejected_failure.dart';
import '../../../domain/params/order_command.dart';
import '../../../domain/repos/orders_repository.dart';
import '../order_notice.dart';
import 'current_orders_state.dart';

export '../order_notice.dart';
export 'current_orders_state.dart';

/// New and active orders (`GET /vendor/current-orders`) and the commands
/// that move them forward.
class CurrentOrdersCubit extends Cubit<CurrentOrdersState> {
  final OrdersRepository _repository;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  CurrentOrdersCubit({required OrdersRepository repository})
    : _repository = repository,
      super(const CurrentOrdersLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const CurrentOrdersLoading());
    final result = await _repository.getCurrentOrders();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => CurrentOrdersLoadFailure(failure.displayMessage),
        (orders) => CurrentOrdersLoaded(orders: orders),
      ),
    );
  }

  /// Keeps the current list on screen until the new one arrives.
  Future<void> refresh() async {
    final CurrentOrdersState current = state;
    if (current is! CurrentOrdersLoaded) return load();

    final int generation = ++_generation;
    final result = await _repository.getCurrentOrders();
    final CurrentOrdersState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! CurrentOrdersLoaded) {
      return;
    }

    emit(
      result.fold(
        (failure) => latest.copyWith(
          notice: OrderActionFailedNotice(failure.displayMessage),
        ),
        (orders) => latest.copyWith(orders: orders),
      ),
    );
  }

  Future<void> accept(MerchantOrder order) => _send(
    order,
    OrderCommand(
      orderId: order.id,
      action: OrderAction.accept,
      expectedVersion: order.statusVersion,
    ),
  );

  Future<void> reject(
    MerchantOrder order, {
    required RejectReason reason,
    String? note,
  }) => _send(
    order,
    OrderCommand.reject(
      orderId: order.id,
      reason: reason,
      note: note,
      expectedVersion: order.statusVersion,
    ),
  );

  /// Start preparing, mark ready for pickup, or retry a failed dispatch,
  /// whichever comes next.
  Future<void> advance(MerchantOrder order) async {
    final OrderAction? action = order.status.nextAction;
    if (action == null || action == OrderAction.accept) return;
    await _send(
      order,
      OrderCommand(
        orderId: order.id,
        action: action,
        expectedVersion: order.statusVersion,
      ),
    );
  }

  Future<void> _send(MerchantOrder order, OrderCommand command) async {
    final CurrentOrdersState current = state;
    if (current is! CurrentOrdersLoaded || current.busyIds.contains(order.id)) {
      return;
    }

    emit(current.copyWith(busyIds: <int>{...current.busyIds, order.id}));
    final result = await _repository.sendCommand(command);
    final CurrentOrdersState latest = state;
    if (isClosed || latest is! CurrentOrdersLoaded) return;

    final Set<int> busyIds = <int>{...latest.busyIds}..remove(order.id);
    result.fold(
      (failure) {
        if (failure.isStaleOrder) {
          emit(
            latest.copyWith(busyIds: busyIds, notice: OrderConflictNotice()),
          );
          refresh();
        } else {
          emit(
            latest.copyWith(
              busyIds: busyIds,
              notice: OrderActionFailedNotice(failure.displayMessage),
            ),
          );
        }
      },
      (change) {
        emit(
          latest.copyWith(
            orders: <MerchantOrder>[
              for (final MerchantOrder o in latest.orders)
                o.id == order.id ? o.applyChange(change) : o,
            ],
            busyIds: busyIds,
            notice: OrderUpdatedNotice(
              orderId: order.id,
              status: order.applyChange(change).status,
            ),
          ),
        );
      },
    );
  }
}
