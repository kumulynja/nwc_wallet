import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrClientMessageType {
  event, // used to publish events
  req, // used to request events and subscribe to new updates
  close, // used to stop a subscription
}

extension NostrClientMessageTypeExtension on NostrClientMessageType {
  String get value {
    switch (this) {
      case NostrClientMessageType.event:
        return NostrConstants.clientMessageEventType;
      case NostrClientMessageType.req:
        return NostrConstants.clientMessageRequestType;
      case NostrClientMessageType.close:
        return NostrConstants.clientMessageCloseType;
    }
  }

  static NostrClientMessageType fromValue(String value) {
    switch (value) {
      case NostrConstants.clientMessageEventType:
        return NostrClientMessageType.event;
      case NostrConstants.clientMessageRequestType:
        return NostrClientMessageType.req;
      case NostrConstants.clientMessageCloseType:
        return NostrClientMessageType.close;
      default:
        throw Exception('Unknown NostrClientMessageType: $value');
    }
  }
}
