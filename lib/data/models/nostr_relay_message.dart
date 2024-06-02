import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/enums/nostr_relay_message_type_enum.dart';

// Abstract base class for messages from relay to client
@immutable
abstract class NostrRelayMessage extends Equatable {
  const NostrRelayMessage();

  factory NostrRelayMessage.fromSerialized(String serialized) {
    final message = jsonDecode(serialized);

    if (message is List && message.isNotEmpty) {
      final type = NostrRelayMessageTypeX.fromValue(message[0]);

      switch (type) {
        case NostrRelayMessageType.event:
          return RelayEventMessage(
            subscriptionId: message[1],
            event: NostrEvent.fromMap(message[2]),
          );
        case NostrRelayMessageType.ok:
          return RelayOkMessage(
            eventId: message[1],
            accepted: message[2],
            message: message[3],
          );
        case NostrRelayMessageType.eose:
          return RelayEndOfStreamMessage(
            subscriptionId: message[1],
          );
        case NostrRelayMessageType.closed:
          return RelayClosedMessage(
            subscriptionId: message[1],
            message: message[2],
          );
        case NostrRelayMessageType.notice:
          return RelayNoticeMessage(
            message: message[1],
          );
        default:
          throw ArgumentError('Invalid message type');
      }
    } else {
      throw ArgumentError('Invalid message format');
    }
  }

  @override
  List<Object?> get props => [];
}

// Subclass for messages that contain an event
@immutable
class RelayEventMessage extends NostrRelayMessage {
  final String subscriptionId;
  final NostrEvent event;

  const RelayEventMessage({required this.subscriptionId, required this.event});

  @override
  List<Object?> get props => [subscriptionId, event];
}

// Subclass for messages to indicate acceptance or denial of an EVENT message
@immutable
class RelayOkMessage extends NostrRelayMessage {
  final String eventId;
  final bool accepted;
  final String message;

  const RelayOkMessage({
    required this.eventId,
    required this.accepted,
    required this.message,
  });

  @override
  List<Object?> get props => [eventId, accepted, message];
}

// Subclass for messages to indicate the end of stored events
@immutable
class RelayEndOfStreamMessage extends NostrRelayMessage {
  final String subscriptionId;

  const RelayEndOfStreamMessage({required this.subscriptionId});

  @override
  List<Object?> get props => [subscriptionId];
}

// Subclass for messages to indicate that a subscription was ended on the server side
@immutable
class RelayClosedMessage extends NostrRelayMessage {
  final String subscriptionId;
  final String message;

  const RelayClosedMessage({
    required this.subscriptionId,
    required this.message,
  });

  @override
  List<Object?> get props => [subscriptionId, message];
}

// Subclass for messages to send human-readable error messages or other notices
@immutable
class RelayNoticeMessage extends NostrRelayMessage {
  final String message;

  const RelayNoticeMessage({required this.message});

  @override
  List<Object?> get props => [message];
}
