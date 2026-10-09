import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../../../../core/utils/log_utils.dart';

/// Signs a private-channel subscription for [socketId].
typedef ChannelAuthorizer =
    Future<String> Function(String socketId, String channelName);

/// Where the Pusher-protocol server is. Built from `.env` (see `AppEnv`).
class RealtimeConfig {
  final String appKey;

  /// Pusher Channels cluster, used when [host] is empty.
  final String cluster;

  /// A self-hosted server (Reverb, Soketi); wins over [cluster].
  final String host;
  final int port;
  final String scheme;

  const RealtimeConfig({
    required this.appKey,
    this.cluster = '',
    this.host = '',
    this.port = 443,
    this.scheme = 'wss',
  });

  bool get isConfigured =>
      appKey.isNotEmpty && (host.isNotEmpty || cluster.isNotEmpty);
}

/// An event received on the subscribed channel.
class RealtimeSocketMessage {
  final String name;
  final Map<String, dynamic>? data;

  const RealtimeSocketMessage(this.name, this.data);
}

/// A connection to one private channel. Reconnects and resubscribes by
/// itself until [close].
abstract class RealtimeSocket {
  Stream<RealtimeSocketMessage> get messages;

  /// Fires each time the channel subscription succeeds: once after [open],
  /// then after every reconnect.
  Stream<void> get subscribed;

  Future<void> open({
    required String channelName,
    required ChannelAuthorizer authorize,
  });

  Future<void> close();
}

class PusherRealtimeSocket implements RealtimeSocket {
  final RealtimeConfig _config;
  final StreamController<RealtimeSocketMessage> _messages =
      StreamController<RealtimeSocketMessage>.broadcast();
  final StreamController<void> _subscribed = StreamController<void>.broadcast();

  PusherChannelsClient? _client;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  PusherRealtimeSocket({required RealtimeConfig config}) : _config = config;

  @override
  Stream<RealtimeSocketMessage> get messages => _messages.stream;

  @override
  Stream<void> get subscribed => _subscribed.stream;

  @override
  Future<void> open({
    required String channelName,
    required ChannelAuthorizer authorize,
  }) async {
    await close();

    final PusherChannelsClient client = PusherChannelsClient.websocket(
      options: _options,
      // Network drops are routine on a phone: log and retry. The client
      // spaces attempts by minimumReconnectDelayDuration.
      connectionErrorHandler: (dynamic exception, StackTrace trace, refresh) {
        Log.w('Realtime connection error: $exception');
        refresh();
      },
      minimumReconnectDelayDuration: const Duration(seconds: 3),
    );
    _client = client;

    final PrivateChannel channel = client.privateChannel(
      channelName,
      authorizationDelegate: _CallbackAuthorizationDelegate(authorize),
    );
    _subscriptions
      ..add(
        channel.bindToAll().listen(
          (ChannelReadEvent event) => _messages.add(
            RealtimeSocketMessage(event.name, event.tryGetDataAsMap()),
          ),
        ),
      )
      ..add(
        channel.whenSubscriptionSucceeded().listen(
          (_) => _subscribed.add(null),
        ),
      )
      // Resubscribe after every reconnect; the server forgets channels.
      ..add(
        client.onConnectionEstablished.listen(
          (_) => channel.subscribeIfNotUnsubscribed(),
        ),
      );

    unawaited(client.connect());
  }

  @override
  Future<void> close() async {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _client?.dispose();
    _client = null;
  }

  PusherChannelsOptions get _options {
    final PusherChannelsOptionsMetadata metadata =
        PusherChannelsOptionsMetadata.byDefault();
    if (_config.host.isNotEmpty) {
      return PusherChannelsOptions.fromHost(
        scheme: _config.scheme,
        host: _config.host,
        port: _config.port,
        key: _config.appKey,
        shouldSupplyMetadataQueries: true,
        metadata: metadata,
      );
    }
    return PusherChannelsOptions.fromCluster(
      scheme: _config.scheme,
      cluster: _config.cluster,
      key: _config.appKey,
      port: _config.port,
      shouldSupplyMetadataQueries: true,
      metadata: metadata,
    );
  }
}

/// Lets the app's own HTTP client sign subscriptions, instead of the
/// package's `http`-based delegate.
class _CallbackAuthorizationDelegate
    implements
        EndpointAuthorizableChannelAuthorizationDelegate<
          PrivateChannelAuthorizationData
        > {
  final ChannelAuthorizer _authorize;

  const _CallbackAuthorizationDelegate(this._authorize);

  @override
  EndpointAuthFailedCallback? get onAuthFailed =>
      (dynamic exception, StackTrace trace) =>
          Log.w('Realtime channel authorization failed: $exception');

  @override
  Future<PrivateChannelAuthorizationData> authorizationData(
    String socketId,
    String channelName,
  ) async => PrivateChannelAuthorizationData(
    authKey: await _authorize(socketId, channelName),
  );
}
