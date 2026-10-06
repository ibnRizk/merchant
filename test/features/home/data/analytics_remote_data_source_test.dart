import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/home/data/datasources/analytics_remote_data_source.dart';
import 'package:ssm_merchant/features/home/domain/entities/store_analytics.dart';

import '../../../helpers/fake_dio_consumer.dart';

void main() {
  late FakeDioConsumer client;
  late AnalyticsRemoteDataSourceImpl dataSource;

  setUp(() {
    client = FakeDioConsumer();
    dataSource = AnalyticsRemoteDataSourceImpl(client: client);
  });

  Future<StoreAnalytics> fetch() => dataSource.getAnalytics(
    from: DateTime(2026, 1, 5),
    to: DateTime(2026, 12, 31),
  );

  test('sends the range as dates and reads the figures', () async {
    client.response = <String, dynamic>{
      'orders': <String, dynamic>{'total': 12, 'delivered': 9, 'cancelled': 2},
      'sales': <String, dynamic>{
        'total': '1250.50',
        'average_order_value': 138.94,
      },
      'top_items': <dynamic>[
        <String, dynamic>{'name': 'Burger', 'total_quantity': '14'},
        <String, dynamic>{
          'item': <String, dynamic>{'name': 'Fries'},
          'quantity': 6,
          'revenue': '90.00',
        },
        <String, dynamic>{'quantity': 3},
      ],
    };

    final StoreAnalytics analytics = await fetch();

    expect(client.calls.single.path, ApiEndpoints.analytics);
    expect(client.calls.single.query, <String, dynamic>{
      'from': '2026-01-05',
      'to': '2026-12-31',
    });
    expect(analytics.totalOrders, 12);
    expect(analytics.otherOrders, 1);
    expect(analytics.totalSales, 1250.5);
    expect(analytics.topItems, const <TopItem>[
      TopItem(name: 'Burger', quantity: 14),
      TopItem(name: 'Fries', quantity: 6, revenue: 90),
    ]);
  });

  test('a missing figure is an unexpected response', () {
    client.response = <String, dynamic>{
      'orders': <String, dynamic>{'total': 1},
      'sales': <String, dynamic>{'total': 1, 'average_order_value': 1},
    };

    expect(fetch, throwsA(isA<UnexpectedResponseException>()));
  });
}
