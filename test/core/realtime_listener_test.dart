import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/realtime/realtime_event.dart';
import 'package:ssm_merchant/core/widgets/realtime_listener.dart';

void main() {
  late StreamController<RealtimeEvent> events;
  late int calls;

  setUp(() {
    events = StreamController<RealtimeEvent>.broadcast();
    calls = 0;
  });

  tearDown(() => events.close());

  Future<void> pumpListener(WidgetTester tester) => tester.pumpWidget(
    RealtimeListener(
      events: events.stream,
      when: (RealtimeEvent event) => event.affectsOrders,
      onEvent: () => calls++,
      child: const SizedBox.shrink(),
    ),
  );

  testWidgets('coalesces a burst of matching events into one call', (
    WidgetTester tester,
  ) async {
    await pumpListener(tester);

    events
      ..add(const RealtimeEvent(RealtimeEventType.orderStatusChanged))
      ..add(const RealtimeEvent(RealtimeEventType.driverAssigned));
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 0);

    await tester.pump(RealtimeListener.defaultDebounce);
    expect(calls, 1);
  });

  testWidgets('ignores events that do not pass `when`', (
    WidgetTester tester,
  ) async {
    await pumpListener(tester);

    events.add(const RealtimeEvent(RealtimeEventType.notificationCreated));
    await tester.pump(RealtimeListener.defaultDebounce * 2);

    expect(calls, 0);
  });

  testWidgets('a pending call is dropped once unmounted', (
    WidgetTester tester,
  ) async {
    await pumpListener(tester);

    events.add(const RealtimeEvent(RealtimeEventType.orderCreated));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(RealtimeListener.defaultDebounce * 2);

    expect(calls, 0);
  });
}
