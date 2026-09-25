import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Opens or closes the merchant's store for new orders.
abstract class StoreStatusRepository {
  /// Returns whether the store is open according to the server.
  Future<Either<Failure, bool>> setStoreOpen({required bool isOpen});
}
