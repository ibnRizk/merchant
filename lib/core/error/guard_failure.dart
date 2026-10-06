import 'dart:io';

import 'package:dartz/dartz.dart';

import '../utils/log_utils.dart';
import '../utils/values/strings.dart';
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
  } catch (error, stackTrace) {
    // Almost always a response that didn't match the model (a type error).
    // The raw text is for the logs; users get a localized message.
    Log.e('Unhandled error in a repository call: $error\n$stackTrace');
    return Left<Failure, T>(
      ServerFailure(message: Strings.unexpectedResponse),
    );
  }
}
