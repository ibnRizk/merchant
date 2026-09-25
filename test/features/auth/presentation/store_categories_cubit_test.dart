import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/entities/store_category.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/auth/presentation/cubit/store_categories/store_categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth_fakes.dart';

void main() {
  late FakeMerchantAuthRepository repository;
  late StoreCategoriesCubit cubit;

  setUp(() {
    repository = FakeMerchantAuthRepository();
    cubit = StoreCategoriesCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('emits the loaded categories', () async {
      await cubit.load();

      expect(cubit.state, isA<StoreCategoriesLoaded>());
      expect(
        (cubit.state as StoreCategoriesLoaded).categories,
        <StoreCategory>[restaurant],
      );
    });

    test('emits the failure message', () async {
      repository.categoriesResult = const Left<Failure, List<StoreCategory>>(
        NetworkFailure(message: 'offline'),
      );

      await cubit.load();

      expect(cubit.state, isA<StoreCategoriesFailure>());
      expect((cubit.state as StoreCategoriesFailure).message, 'offline');
    });

    test('retrying after a failure loads again', () async {
      repository.categoriesResult = const Left<Failure, List<StoreCategory>>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.load();
      repository.categoriesResult = const Right<Failure, List<StoreCategory>>(
        <StoreCategory>[restaurant],
      );

      await cubit.load();

      expect(cubit.state, isA<StoreCategoriesLoaded>());
    });
  });

  group('isSelectionMissing', () {
    test('is true while categories are still loading', () {
      expect(cubit.isSelectionMissing(null), isTrue);
    });

    test('is true when categories exist and none is chosen', () async {
      await cubit.load();

      expect(cubit.isSelectionMissing(null), isTrue);
    });

    test('is false once a category is chosen', () async {
      await cubit.load();

      expect(cubit.isSelectionMissing(restaurant.id), isFalse);
    });

    test('is false when there are no categories to choose from', () async {
      repository.categoriesResult = const Right<Failure, List<StoreCategory>>(
        <StoreCategory>[],
      );
      await cubit.load();

      expect(cubit.isSelectionMissing(null), isFalse);
    });

    test('is true when loading failed', () async {
      repository.categoriesResult = const Left<Failure, List<StoreCategory>>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.load();

      expect(cubit.isSelectionMissing(null), isTrue);
    });
  });
}
