import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/features/home/data/datasources/store_status_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_consumer.dart';

void main() {
  late FakeDioConsumer client;
  late StoreStatusRemoteDataSourceImpl dataSource;

  setUp(() {
    client = FakeDioConsumer();
    dataSource = StoreStatusRemoteDataSourceImpl(client: client);
  });

  test('posts is_open to update-active-status', () async {
    client.response = <String, dynamic>{'message': 'ok', 'active': true};

    await dataSource.setStoreOpen(isOpen: true);

    expect(client.calls.single.path, ApiEndpoints.updateActiveStatus);
    expect(client.calls.single.body, <String, dynamic>{'is_open': true});
  });

  test("returns the server's active flag", () async {
    client.response = <String, dynamic>{'message': 'ok', 'active': 0};

    expect(await dataSource.setStoreOpen(isOpen: true), isFalse);
  });

  test('trusts the request when active is missing', () async {
    client.response = <String, dynamic>{'message': 'ok'};

    expect(await dataSource.setStoreOpen(isOpen: false), isFalse);
  });
}
