import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/repos/store_status_repository.dart';
import '../datasources/store_status_remote_data_source.dart';

class StoreStatusRepositoryImpl implements StoreStatusRepository {
  final StoreStatusRemoteDataSource _remote;

  const StoreStatusRepositoryImpl({required StoreStatusRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, bool>> setStoreOpen({required bool isOpen}) =>
      guardFailure(() => _remote.setStoreOpen(isOpen: isOpen));
}
