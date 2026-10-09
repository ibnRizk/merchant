import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/log_utils.dart';
import '../../../domain/repos/notifications_repository.dart';

/// The unread badge. State is the count; 0 hides the badge.
class UnreadCountCubit extends Cubit<int> {
  final NotificationsRepository _repository;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  UnreadCountCubit({required NotificationsRepository repository})
    : _repository = repository,
      super(0);

  /// A failure keeps the last known count: a badge is no place for an error,
  /// and the next refresh (event, resume, inbox visit) corrects it.
  Future<void> refresh() async {
    final int generation = ++_generation;
    final Either<Failure, int> result = await _repository.getUnreadCount();
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) => Log.w('Unread count failed: ${failure.message}'),
      emit,
    );
  }
}
