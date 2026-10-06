import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product_options.dart';
import 'package:ssm_merchant/features/menu/presentation/cubit/product_options/product_options_cubit.dart';

import '../menu_fakes.dart';

const ProductOptions large = ProductOptions(
  variationTitle: 'Size',
  variations: <ProductVariation>[ProductVariation(name: 'Large', price: 30)],
);

void main() {
  late FakeCatalogRepository repository;
  late ProductOptionsCubit cubit;

  ProductOptionsReady ready() => cubit.state as ProductOptionsReady;

  setUp(() {
    repository = FakeCatalogRepository()
      ..productResult = const Right(
        Product(
          id: 4,
          name: 'Pizza',
          description: '',
          price: 20,
          isActive: true,
          options: large,
        ),
      );
    cubit = ProductOptionsCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load starts from the saved options', () async {
    await cubit.load(4);

    expect(ready().options, large);
  });

  test('save sends valid options and announces it', () async {
    await cubit.load(4);

    await cubit.save(ProductOptions.none);

    expect(repository.optionUpdates.single.id, 4);
    expect(ready().options, ProductOptions.none);
    expect(ready().notice, isA<ProductOptionsSavedNotice>());
  });

  test('invalid options are announced and not sent', () async {
    await cubit.load(4);

    await cubit.save(
      const ProductOptions(
        variations: <ProductVariation>[
          ProductVariation(name: 'Large', price: 30),
        ],
      ),
    );

    expect(repository.optionUpdates, isEmpty);
    expect(
      (ready().notice as ProductOptionsInvalidNotice).error,
      ProductOptionsError.missingTitle,
    );
  });

  test('a failed save keeps the previous options', () async {
    await cubit.load(4);
    repository.optionsResult = const Left(ServerFailure(message: 'Nope'));

    await cubit.save(ProductOptions.none);

    expect(ready().options, large);
    expect((ready().notice as ProductOptionsFailedNotice).message, 'Nope');
    expect(ready().isSaving, isFalse);
  });
}
