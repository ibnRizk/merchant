import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/merchant_order.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/order_failures.dart';
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

  /// Background refresh. Failures stay quiet (the next tick retries, and a
  /// pull-to-refresh still reports them); a success also recovers from a
  /// failed first load.
  Future<void> poll() async {
    if (state is CurrentOrdersLoading) return;

    final int generation = ++_generation;
    final result = await _repository.getCurrentOrders();
    final CurrentOrdersState latest = state;
    if (isClosed || generation != _generation) return;

    result.fold(
      (_) {},
      (orders) => emit(
        latest is CurrentOrdersLoaded
            ? latest.copyWith(orders: orders)
            : CurrentOrdersLoaded(orders: orders),
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

  /// Calls off an accepted or preparing order before it goes to dispatch.
  Future<void> cancel(
    MerchantOrder order, {
    required CancelReason reason,
    String? note,
  }) async {
    if (!order.status.canCancel) return;
    await _send(
      order,
      OrderCommand.cancel(
        orderId: order.id,
        reason: reason,
        note: note,
        expectedVersion: order.statusVersion,
      ),
    );
  }

  /// Start preparing, or mark ready for pickup, whichever comes next.
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

  /// Offers an `assignmentFailed` order to drivers again, then reloads the
  /// list: the response carries no status.
  Future<void> retryDispatch(MerchantOrder order) async {
    if (!order.status.canRetryDispatch) return;
    await _act(order, () => _repository.retryDispatch(order.id), (
      CurrentOrdersLoaded latest,
      Set<int> busyIds,
      Unit _,
    ) {
      emit(
        latest.copyWith(
          busyIds: busyIds,
          notice: OrderDispatchRetriedNotice(),
        ),
      );
      refresh();
    });
  }

  Future<void> _send(MerchantOrder order, OrderCommand command) => _act(
    order,
    () => _repository.sendCommand(command),
    (CurrentOrdersLoaded latest, Set<int> busyIds, OrderStatusChange change) =>
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
        ),
  );

  /// Runs one order action with the order marked busy. A stale order
  /// (409/422/404) is announced and reloaded; other failures show their
  /// message.
  Future<void> _act<T>(
    MerchantOrder order,
    Future<Either<Failure, T>> Function() request,
    void Function(CurrentOrdersLoaded latest, Set<int> busyIds, T value)
    onSuccess,
  ) async {
    final CurrentOrdersState current = state;
    if (current is! CurrentOrdersLoaded || current.busyIds.contains(order.id)) {
      return;
    }

    emit(current.copyWith(busyIds: <int>{...current.busyIds, order.id}));
    final Either<Failure, T> result = await request();
    // A list fetched before this landed would undo it.
    _generation++;
    final CurrentOrdersState latest = state;
    if (isClosed || latest is! CurrentOrdersLoaded) return;

    final Set<int> busyIds = <int>{...latest.busyIds}..remove(order.id);
    result.fold((Failure failure) {
      if (failure.meansStaleOrder) {
        emit(latest.copyWith(busyIds: busyIds, notice: OrderConflictNotice()));
        refresh();
      } else {
        emit(
          latest.copyWith(
            busyIds: busyIds,
            notice: OrderActionFailedNotice(failure.displayMessage),
          ),
        );
      }
    }, (T value) => onSuccess(latest, busyIds, value));
  }
}
