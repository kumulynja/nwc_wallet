import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/data/models/nostr_client_message.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_filters.dart';
import 'package:nwc_wallet/data/models/nostr_relay_message.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';

abstract class NostrRepository {
  Stream<NostrEvent> get events;
  void connect();
  void requestEvents(String subscriptionId, List<NostrFilters> filters);
  Future<bool> publishEvent(NostrEvent event);
  void closeSubscription(String subscriptionId);
  void disconnect();
}

class NostrRepositoryImpl implements NostrRepository {
  final NostrRelayProviderImpl _relayProvider;
  final StreamController<NostrEvent> _eventController =
      StreamController.broadcast();
  final Map<String, Completer<bool>> _publishedEvents = {};

  NostrRepositoryImpl(this._relayProvider);

  @override
  Stream<NostrEvent> get events => _eventController.stream;

  @override
  void connect() {
    _relayProvider.connect();
    _relayProvider.messages
        .listen(_handleRelayMessage); // Todo: Handle errors and other callbacks
  }

  @override
  Future<bool> publishEvent(
    NostrEvent event, {
    int timeoutSec = AppConfigs.defaultPublishEventTimeoutSec,
  }) async {
    final completer = Completer<bool>();
    final message = ClientEventMessage(event: event);

    _publishedEvents[event.id!] = completer; // Store completer with event ID

    _relayProvider.sendMessage(message);

    final isPublishedSuccessfully = await Future.any([
      completer.future,
      Future.delayed(Duration(seconds: timeoutSec), () {
        debugPrint('Publish event timeout: ${event.id}');
        return false; // Return false on timeout
      }),
    ]);

    _publishedEvents.remove(event.id);

    return isPublishedSuccessfully;
  }

  @override
  void requestEvents(String subscriptionId, List<NostrFilters> filters) {
    final message =
        ClientRequestMessage(subscriptionId: subscriptionId, filters: filters);
    _relayProvider.sendMessage(message);
  }

  @override
  void closeSubscription(String subscriptionId) {
    final message = ClientCloseMessage(subscriptionId: subscriptionId);
    _relayProvider.sendMessage(message);
  }

  @override
  void disconnect() {
    _relayProvider.disconnect();
  }

  void _handleRelayMessage(NostrRelayMessage message) {
    if (message is RelayEventMessage) {
      // Handle event message
      debugPrint('Received event: ${message.event.content}');

      // Publish the event to the stream
      _eventController.add(message.event);
    } else if (message is RelayNoticeMessage) {
      // Handle notice message
      debugPrint('Received notice: ${message.message}');
    } else if (message is RelayEndOfStreamMessage) {
      // Handle end of stream message
      debugPrint(
        'End of stored events for subscription: ${message.subscriptionId}',
      );
    } else if (message is RelayClosedMessage) {
      // Handle closed message
      debugPrint(
        'Subscription closed: ${message.subscriptionId} with message: ${message.message}',
      );
    } else if (message is RelayOkMessage) {
      debugPrint(
        'OK message: Event ${message.eventId} accepted: ${message.accepted}, message: ${message.message}',
      );

      // Handle OK message by completing the completer
      final completer = _publishedEvents[message.eventId];
      if (completer != null) {
        completer.complete(message.accepted);
      }
    }
  }
}
