import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/widgets/refresh_poller.dart';

const Duration interval = Duration(seconds: 15);

void main() {
  late int refreshes;

  setUp(() => refreshes = 0);

  Widget poller() => RefreshPoller(
    onRefresh: () => refreshes++,
    interval: interval,
    child: const SizedBox(),
  );

  Future<void> setLifecycle(
    WidgetTester tester,
    List<AppLifecycleState> states,
  ) async {
    for (final AppLifecycleState state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
  }

  testWidgets('refreshes every interval while on screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(poller());

    await tester.pump(interval * 3);

    expect(refreshes, 3);
  });

  testWidgets('stays idle on a tab that is not selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: IndexedStack(children: <Widget>[const SizedBox(), poller()]),
      ),
    );

    await tester.pump(interval * 2);

    expect(refreshes, 0);
  });

  testWidgets('stays idle while another route covers it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: poller()));
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
    await tester.pumpAndSettle();
    refreshes = 0;

    await tester.pump(interval * 2);

    expect(refreshes, 0);
  });

  testWidgets('pauses in the background and refreshes on resume', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(poller());
    await setLifecycle(tester, <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);

    await tester.pump(interval * 2);
    expect(refreshes, 0);

    await setLifecycle(tester, <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    expect(refreshes, 1);

    await tester.pump(interval);
    expect(refreshes, 2);
  });
}
