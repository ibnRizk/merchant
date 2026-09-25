import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product.dart';
import 'package:ssm_merchant/features/menu/presentation/cubit/menu/menu_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../menu_fakes.dart';

void main() {
  late FakeCatalogRepository repository;
  late MenuCubit cubit;

  MenuLoaded loaded() => cubit.state as MenuLoaded;

  setUp(() {
    repository = FakeCatalogRepository();
    cubit = MenuCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('shows the first page', () async {
      await cubit.load();

      expect(loaded().products.map((Product p) => p.id), <int>[1, 2, 3]);
      expect(loaded().hasMore, isFalse);
    });

    test('shows the failure message', () async {
      repository.onGetProducts = (_, __) async =>
          const Left(NetworkFailure(message: 'offline'));

      await cubit.load();

      expect(cubit.state, isA<MenuLoadFailure>());
      expect((cubit.state as MenuLoadFailure).message, 'offline');
    });
  });

  group('search', () {
    test('loads with the trimmed query', () async {
      await cubit.search('  burger ');

      expect(repository.productRequests.last.search, 'burger');
      expect(cubit.state.query, 'burger');
    });

    test('skips the request when the query is unchanged', () async {
      await cubit.search('burger');
      await cubit.search('burger ');

      expect(repository.productRequests, hasLength(1));
    });

    test('ignores a slower response for an older query', () async {
      final Completer<Either<Failure, ProductPage>> slow = Completer();
      repository.onGetProducts = (_, String search) => search == 'bu'
          ? slow.future
          : Future.value(Right(page(<Product>[product(7)])));

      final Future<void> first = cubit.search('bu');
      await cubit.search('burger');
      slow.complete(Right(page(<Product>[product(1)])));
      await first;

      expect(loaded().query, 'burger');
      expect(loaded().products.single.id, 7);
    });
  });

  group('loadMore', () {
    setUp(() {
      repository.onGetProducts = (int p, _) async => Right(
        page(<Product>[product(p * 10)], current: p, last: 2),
      );
    });

    test('appends the next page', () async {
      await cubit.load();
      await cubit.loadMore();

      expect(loaded().products.map((Product p) => p.id), <int>[10, 20]);
      expect(loaded().hasMore, isFalse);
    });

    test('stops after a failure until retried', () async {
      await cubit.load();
      repository.onGetProducts = (_, __) async =>
          const Left(NetworkFailure(message: 'offline'));
      await cubit.loadMore();
      await cubit.loadMore();

      expect(loaded().loadMoreFailed, isTrue);
      expect(repository.productRequests, hasLength(2));

      await cubit.loadMore(retry: true);
      expect(repository.productRequests, hasLength(3));
    });
  });

  group('toggleStatus', () {
    setUp(() => cubit.load());

    test('keeps the new status when the server accepts it', () async {
      await cubit.toggleStatus(product(2), isActive: false);

      expect(loaded().products[1].isActive, isFalse);
      expect(repository.statusChanges.single, (id: 2, isActive: false));
      expect(loaded().busyIds, isEmpty);
    });

    test('reverts and reports when the server refuses', () async {
      repository.statusResult = const Left(ServerFailure(message: 'nope'));

      await cubit.toggleStatus(product(2), isActive: false);

      expect(loaded().products[1].isActive, isTrue);
      expect(loaded().notice, isA<MenuActionFailedNotice>());
    });
  });

  group('deleteProduct', () {
    setUp(() => cubit.load());

    test('removes the product and announces it', () async {
      await cubit.deleteProduct(product(2));

      expect(loaded().products.map((Product p) => p.id), <int>[1, 3]);
      expect(loaded().notice, isA<ProductDeletedNotice>());
    });

    test('keeps the product and explains a 409', () async {
      repository.deleteResult = const Left(
        ConflictFailure(message: 'used in orders'),
      );

      await cubit.deleteProduct(product(2));

      expect(loaded().products, hasLength(3));
      expect(loaded().notice, isA<ProductDeleteBlockedNotice>());
    });

    test('reports any other failure with its message', () async {
      repository.deleteResult = const Left(NetworkFailure(message: 'offline'));

      await cubit.deleteProduct(product(2));

      final MenuNotice? notice = loaded().notice;
      expect(notice, isA<MenuActionFailedNotice>());
      expect((notice! as MenuActionFailedNotice).message, 'offline');
    });
  });

  group('productSaved', () {
    setUp(() => cubit.load());

    test('replaces a listed product in place', () {
      cubit.productSaved(product(2, price: 99));

      expect(loaded().products[1].price, 99);
      expect(loaded().products, hasLength(3));
    });

    test('adds a new product at the top', () {
      cubit.productSaved(product(9));

      expect(loaded().products.first.id, 9);
    });
  });
}
