import 'dart:io';

import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Single boundary where exceptions become failures. Every repository runs
/// its data-source calls through this so no exception leaks past the data
/// layer.
Future<Either<Failure, T>> guardFailure<T>(Future<T> Function() action) async {
  try {
    return Right<Failure, T>(await action());
  } on AppException catch (e) {
    return Left<Failure, T>(e.toFailure());
  } on FileSystemException {
    // A picked file was deleted or moved before upload.
    return Left<Failure, T>(const FetchDataFailure());
  } catch (_) {
    // Typically a parse error. Raw exception text is not fit to show users.
    return Left<Failure, T>(const UnexpectedResponseFailure());
  }
}
