import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_filters.dart';
import 'package:nwc_wallet/enums/nostr_client_message_type.dart';

// Abstract base class for messages from client to relay
@immutable
abstract class NostrClientMessage extends Equatable {
  const NostrClientMessage();

  const factory NostrClientMessage.clientEventMessage({
    required NostrEvent event,
  }) = ClientEventMessage;
  const factory NostrClientMessage.clientRequesMessage({
    required String subscriptionId,
    List<NostrFilters>? filters,
  }) = ClientRequestMessage;
  const factory NostrClientMessage.clientCloseMessage({
    required String subscriptionId,
  }) = ClientCloseMessage;

  String get serialized;
}

// Subclass for messages to publish events
@immutable
class ClientEventMessage extends NostrClientMessage {
  final NostrEvent event;

  const ClientEventMessage({required this.event});

  @override
  String get serialized {
    final message = [NostrClientMessageType.event.value, event.toMap()];
    return jsonEncode(message);
  }

  @override
  List<Object?> get props => [event];
}

// Subclass for messages to request events and subscribe to new updates
class ClientRequestMessage extends NostrClientMessage {
  final String subscriptionId;
  final List<NostrFilters>? filters;

  const ClientRequestMessage({
    required this.subscriptionId,
    this.filters,
  });

  @override
  String get serialized {
    final message = [
      NostrClientMessageType.req.value,
      subscriptionId,
      if (filters != null) ...filters!.map((f) => f.toMap()),
    ];
    return jsonEncode(message);
  }

  @override
  List<Object?> get props => [subscriptionId, filters];
}

// Subclass for messages to close a subscription
@immutable
class ClientCloseMessage extends NostrClientMessage {
  final String subscriptionId;

  const ClientCloseMessage({required this.subscriptionId});

  @override
  String get serialized {
    final message = [NostrClientMessageType.close.value, subscriptionId];
    return jsonEncode(message);
  }

  @override
  List<Object?> get props => [subscriptionId];
}
