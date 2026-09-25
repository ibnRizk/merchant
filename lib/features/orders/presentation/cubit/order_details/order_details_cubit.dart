import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/merchant_order.dart';
import '../../../domain/entities/order_line.dart';
import '../../../domain/entities/order_status.dart';
import '../../../domain/params/order_command.dart';
import '../../../domain/repos/orders_repository.dart';
import '../order_notice.dart';
import 'order_details_state.dart';

export '../order_notice.dart';
export 'order_details_state.dart';

/// One order: its summary (`/vendor/order`), its lines
/// (`/vendor/order-details`) and the commands that move it forward.
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final OrdersRepository _repository;
  int? _orderId;
  int _generation = 0;

  OrderDetailsCubit({required OrdersRepository repository})
    : _repository = repository,
      super(const OrderDetailsLoading());

  Future<void> load(int orderId) async {
    _orderId = orderId;
    final int generation = ++_generation;
    emit(const OrderDetailsLoading());
    final result = await _fetch(orderId);
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => OrderDetailsLoadFailure(failure.displayMessage),
        (data) => OrderDetailsLoaded(order: data.order, lines: data.lines),
      ),
    );
  }

  /// Refetches while keeping the current details on screen.
  Future<void> refresh() async {
    final int? orderId = _orderId;
    if (orderId == null) return;
    final OrderDetailsState current = state;
    if (current is! OrderDetailsLoaded) return load(orderId);

    final int generation = ++_generation;
    final result = await _fetch(orderId);
    final OrderDetailsState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! OrderDetailsLoaded) {
      return;
    }

    emit(
      result.fold(
        (failure) => latest.copyWith(
          notice: OrderActionFailedNotice(failure.displayMessage),
        ),
        (data) => latest.copyWith(order: data.order, lines: data.lines),
      ),
    );
  }

  Future<void> accept() => _send(
    (MerchantOrder order) => OrderCommand(
      orderId: order.id,
      action: OrderAction.accept,
      expectedVersion: order.statusVersion,
    ),
  );

  Future<void> reject({required RejectReason reason, String? note}) => _send(
    (MerchantOrder order) => OrderCommand.reject(
      orderId: order.id,
      reason: reason,
      note: note,
      expectedVersion: order.statusVersion,
    ),
  );

  /// Start preparing, or mark ready for pickup, whichever comes next.
  Future<void> advance() => _send((MerchantOrder order) {
    final OrderAction? action = order.status.nextAction;
    if (action == null || action == OrderAction.accept) return null;
    return OrderCommand(
      orderId: order.id,
      action: action,
      expectedVersion: order.statusVersion,
    );
  });

  Future<void> _send(OrderCommand? Function(MerchantOrder order) build) async {
    final OrderDetailsState current = state;
    if (current is! OrderDetailsLoaded || current.isBusy) return;
    final OrderCommand? command = build(current.order);
    if (command == null) return;

    emit(current.copyWith(isBusy: true));
    final result = await _repository.sendCommand(command);
    final OrderDetailsState latest = state;
    if (isClosed || latest is! OrderDetailsLoaded) return;

    result.fold(
      (failure) {
        if (failure is ConflictFailure) {
          emit(latest.copyWith(isBusy: false, notice: OrderConflictNotice()));
          refresh();
        } else {
          emit(
            latest.copyWith(
              isBusy: false,
              notice: OrderActionFailedNotice(failure.displayMessage),
            ),
          );
        }
      },
      (change) {
        final MerchantOrder updated = latest.order.applyChange(change);
        emit(
          latest.copyWith(
            order: updated,
            isBusy: false,
            notice: OrderUpdatedNotice(
              orderId: updated.id,
              status: updated.status,
            ),
          ),
        );
      },
    );
  }

  /// Summary and lines in parallel; the screen needs both.
  Future<Either<Failure, _Details>> _fetch(int orderId) async {
    final (
      Either<Failure, MerchantOrder> order,
      Either<Failure, List<OrderLine>> lines,
    ) = await (
      _repository.getOrder(orderId),
      _repository.getOrderLines(orderId),
    ).wait;

    return order.fold(
      (Failure failure) => Left<Failure, _Details>(failure),
      (MerchantOrder summary) => lines.fold(
        (Failure failure) => Left<Failure, _Details>(failure),
        (List<OrderLine> orderLines) =>
            Right<Failure, _Details>((order: summary, lines: orderLines)),
      ),
    );
  }
}

typedef _Details = ({MerchantOrder order, List<OrderLine> lines});
