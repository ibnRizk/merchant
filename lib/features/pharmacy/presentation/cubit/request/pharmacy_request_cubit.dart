import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/pharmacy_request.dart';
import '../../../domain/repos/pharmacy_repository.dart';
import 'pharmacy_request_state.dart';

export 'pharmacy_request_state.dart';

/// One request: its details, prescription image, and the price quote
/// (`POST /vendor/pharmacy-requests/{id}/quote`).
class PharmacyRequestCubit extends Cubit<PharmacyRequestState> {
  final PharmacyRepository _repository;
  int? _requestId;
  int _generation = 0;

  PharmacyRequestCubit({required PharmacyRepository repository})
    : _repository = repository,
      super(const PharmacyRequestLoading());

  Future<void> load(int requestId) async {
    _requestId = requestId;
    final int generation = ++_generation;
    emit(const PharmacyRequestLoading());
    final result = await _repository.getRequest(requestId);
    if (isClosed || generation != _generation) return;

    result.fold(
      (failure) => emit(PharmacyRequestLoadFailure(failure.displayMessage)),
      (PharmacyRequest request) {
        emit(PharmacyRequestLoaded(request: request));
        if (request.hasPrescription) loadPrescription();
      },
    );
  }

  /// Also the "retry" for a failed image.
  Future<void> loadPrescription() async {
    final PharmacyRequestState current = state;
    if (current is! PharmacyRequestLoaded ||
        current.prescriptionStatus == PrescriptionStatus.loading) {
      return;
    }
    emit(current.copyWith(prescriptionStatus: PrescriptionStatus.loading));
    final result = await _repository.getPrescription(current.request.id);
    final PharmacyRequestState latest = state;
    if (isClosed || latest is! PharmacyRequestLoaded) return;

    emit(
      result.fold(
        (_) => latest.copyWith(prescriptionStatus: PrescriptionStatus.failed),
        (Uint8List bytes) => latest.copyWith(
          prescriptionStatus: PrescriptionStatus.loaded,
          prescription: bytes,
        ),
      ),
    );
  }

  /// Validates [quote], then sends it. A request that moved on is
  /// announced and reloaded.
  Future<void> sendQuote(PharmacyQuote quote) async {
    final PharmacyRequestState current = state;
    if (current is! PharmacyRequestLoaded ||
        current.isSending ||
        !current.request.status.canQuote) {
      return;
    }
    final PharmacyQuoteError? error = quote.validationError;
    if (error != null) {
      emit(current.copyWith(notice: QuoteInvalidNotice(error)));
      return;
    }

    emit(current.copyWith(isSending: true));
    final result = await _repository.sendQuote(current.request, quote);
    final PharmacyRequestState latest = state;
    if (isClosed || latest is! PharmacyRequestLoaded) return;

    result.fold(
      (Failure failure) {
        if (failure is ConflictFailure) {
          emit(
            latest.copyWith(
              isSending: false,
              notice: RequestNotActionableNotice(),
            ),
          );
          _reload();
        } else {
          emit(
            latest.copyWith(
              isSending: false,
              notice: PharmacyFailureNotice(failure.displayMessage),
            ),
          );
        }
      },
      (PharmacyRequest updated) => emit(
        latest.copyWith(
          request: updated,
          isSending: false,
          notice: QuoteSentNotice(),
        ),
      ),
    );
  }

  /// Refetches the request, keeping the image already loaded.
  Future<void> _reload() async {
    final int? requestId = _requestId;
    if (requestId == null) return;
    final int generation = ++_generation;
    final result = await _repository.getRequest(requestId);
    final PharmacyRequestState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! PharmacyRequestLoaded) {
      return;
    }
    result.fold(
      (_) {},
      (PharmacyRequest request) => emit(latest.copyWith(request: request)),
    );
  }
}
