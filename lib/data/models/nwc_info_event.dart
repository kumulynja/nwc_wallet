import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

@immutable
class NwcInfoEvent extends Equatable {
  final List<NwcMethod> permittedMethods;

  const NwcInfoEvent({
    required this.permittedMethods,
  });

  NostrEvent toUnsignedNostrEvent({
    required String creatorPubkey,
    required String connectionPubkey,
    required String relayUrl,
  }) {
    final partialNostrEvent = NostrEvent(
      pubkey: creatorPubkey,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      kind: NostrEventKind.nip47InfoEvent,
      // The info event should be a replaceable event, so add 'a' tag.
      tags: [
        [
          'a',
          '${NostrEventKind.nip47InfoEvent}:$connectionPubkey:',
          relayUrl,
        ]
      ],
      content: permittedMethods
          .map(
            (method) => method.plaintext,
          )
          .join(
            ' ',
          ), // NIP-47 spec: The content should be a plaintext string with the supported commands, space-separated.
    );

    final unsignedNostrEvent = partialNostrEvent.copyWith(
      id: partialNostrEvent.calculatedId,
    );

    return unsignedNostrEvent;
  }

  @override
  List<Object?> get props => [permittedMethods];
}
