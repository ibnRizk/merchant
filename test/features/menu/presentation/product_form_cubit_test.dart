import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product.dart';
import 'package:ssm_merchant/features/menu/domain/params/product_params.dart';
import 'package:ssm_merchant/features/menu/presentation/cubit/product_form/product_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../menu_fakes.dart';

void main() {
  late FakeCatalogRepository repository;
  late ProductFormCubit cubit;

  final Product existing = product(1);

  ProductDraft draftOf(Product p, {double? price}) => ProductDraft(
    name: p.name,
    description: p.description,
    price: price ?? p.price,
    categoryId: p.category!.id,
  );

  setUp(() {
    repository = FakeCatalogRepository()..productResult = Right(existing);
    cubit = ProductFormCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('is ready with metadata only when adding', () async {
      await cubit.load();

      final ProductFormState state = cubit.state;
      expect(state, isA<ProductFormEditing>());
      expect((state as ProductFormEditing).product, isNull);
      expect(state.metadata, sampleMetadata);
    });

    test('is ready with the full product when editing', () async {
      await cubit.load(productId: 1);

      expect((cubit.state as ProductFormEditing).product, existing);
    });

    test('fails when the metadata fails', () async {
      repository.metadataResult = const Left(
        NetworkFailure(message: 'offline'),
      );

      await cubit.load();

      expect(cubit.state, isA<ProductFormLoadFailure>());
    });

    test('fails when the product fails', () async {
      repository.productResult = const Left(ServerFailure(message: 'gone'));

      await cubit.load(productId: 1);

      expect((cubit.state as ProductFormLoadFailure).message, 'gone');
    });
  });

  group('create', () {
    setUp(() => cubit.load());

    test('saves without a status call when available', () async {
      await cubit.save(draftOf(product(9)), isAvailable: true);

      expect(cubit.state, isA<ProductFormSaved>());
      expect(repository.statusChanges, isEmpty);
    });

    test('hides the new product when marked unavailable', () async {
      await cubit.save(draftOf(product(9)), isAvailable: false);

      final ProductFormSaved state = cubit.state as ProductFormSaved;
      expect(repository.statusChanges.single, (id: 9, isActive: false));
      expect(state.saved.isActive, isFalse);
    });

    test('reports a partial save when hiding fails', () async {
      repository.statusResult = const Left(ServerFailure(message: 'nope'));

      await cubit.save(draftOf(product(9)), isAvailable: false);

      expect((cubit.state as ProductFormSaved).statusUpdateFailed, isTrue);
    });

    test('shows the failure message when creating fails', () async {
      repository.createResult = const Left(
        ServerFailure(message: 'The price must be at least 0.01.'),
      );

      await cubit.save(draftOf(product(9)), isAvailable: true);

      expect(
        (cubit.state as ProductFormSaveFailure).message,
        'The price must be at least 0.01.',
      );
    });
  });

  group('update', () {
    setUp(() => cubit.load(productId: 1));

    test('does nothing when nothing changed', () async {
      await cubit.save(draftOf(existing), isAvailable: existing.isActive);

      expect(cubit.state, isA<ProductFormUnchanged>());
      expect(repository.updates, isEmpty);
      expect(repository.statusChanges, isEmpty);
    });

    test('sends only the changed fields', () async {
      await cubit.save(draftOf(existing, price: 30), isAvailable: true);

      expect(repository.updates.single, const ProductUpdate(price: 30));
      expect(repository.statusChanges, isEmpty);
      expect(cubit.state, isA<ProductFormSaved>());
    });

    test('uses only the status call for an availability change', () async {
      await cubit.save(draftOf(existing), isAvailable: false);

      expect(repository.updates, isEmpty);
      expect(repository.statusChanges.single, (id: 1, isActive: false));
      expect((cubit.state as ProductFormSaved).saved.isActive, isFalse);
    });

    test('a failed status-only change is a failed save', () async {
      repository.statusResult = const Left(ServerFailure(message: 'nope'));

      await cubit.save(draftOf(existing), isAvailable: false);

      expect(cubit.state, isA<ProductFormSaveFailure>());
    });

    test('keeps the product when updating fails', () async {
      repository.updateResult = const Left(ServerFailure(message: 'nope'));

      await cubit.save(draftOf(existing, price: 30), isAvailable: true);

      final ProductFormSaveFailure state =
          cubit.state as ProductFormSaveFailure;
      expect(state.product, existing);
      expect(state.message, 'nope');
    });
  });
}
