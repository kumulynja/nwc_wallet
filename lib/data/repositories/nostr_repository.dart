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
  Future<void> connect();
  void requestEvents(String subscriptionId, List<NostrFilters> filters);
  Future<bool> publishEvent(NostrEvent event);
  void closeSubscription(String subscriptionId);
  Future<void> disconnect();
  Future<void> dispose();
}

class NostrRepositoryImpl implements NostrRepository {
  final NostrRelayProviderImpl _relayProvider;
  StreamSubscription? _subscription;
  final StreamController<NostrEvent> _eventController =
      StreamController.broadcast();
  final Map<String, Completer<bool>> _requestingEvents =
      {}; // Todo: Implement completion with EOSE
  final Map<String, Completer<bool>> _publishingEvents = {};

  NostrRepositoryImpl(this._relayProvider);

  @override
  Stream<NostrEvent> get events => _eventController.stream;

  @override
  Future<void> connect() async {
    await _relayProvider.connect();
    _subscription = _relayProvider.messages.listen(
      _handleRelayMessage,
      onError: (error) {
        debugPrint('Error listening to events: $error');
        _eventController.addError(error);
      },
      onDone: () {
        debugPrint('Event subscription done');
        // Todo: Is this even needed? Should I make custom error for this?
        _eventController.addError('Connection lost');
      },
    );
  }

  @override
  Future<bool> publishEvent(
    NostrEvent event, {
    int timeoutSec = AppConfigs.defaultPublishEventTimeoutSec,
  }) async {
    final completer = Completer<bool>();
    final message = ClientEventMessage(event: event);

    _publishingEvents[event.id!] = completer; // Store completer with event ID

    _relayProvider.sendMessage(message);

    final isPublishedSuccessfully = await completer.future.timeout(
      Duration(seconds: timeoutSec),
      onTimeout: () {
        debugPrint('Publish event timeout: ${event.id}');
        return false; // Return false on timeout
      },
    );

    _publishingEvents.remove(event.id);

    return isPublishedSuccessfully;
  }

  @override
  void requestEvents(String subscriptionId, List<NostrFilters> filters) {
    // Todo: Implement completion with EOSE
    final message =
        ClientRequestMessage(subscriptionId: subscriptionId, filters: filters);
    _relayProvider.sendMessage(message);
  }

  @override
  void closeSubscription(String subscriptionId) async {
    final message = ClientCloseMessage(subscriptionId: subscriptionId);

    _relayProvider.sendMessage(message);
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _relayProvider.disconnect();
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
    await disconnect();
    await _relayProvider.dispose();
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
      debugPrint(
        'Subscription closed by relay: ${message.subscriptionId} with message: ${message.message}',
      );

      _eventController
          .addError('Subscription closed by relay: ${message.message}');
    } else if (message is RelayOkMessage) {
      debugPrint(
        'OK message: Event ${message.eventId} accepted: ${message.accepted}, message: ${message.message}',
      );

      // Handle OK message by completing the completer
      final completer = _publishingEvents[message.eventId];
      if (completer != null) {
        completer.complete(message.accepted);
      }
    }
  }
}
