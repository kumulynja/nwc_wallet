enum NostrClientMessageType {
  event, // used to publish events
  req, // used to request events and subscribe to new updates
  close, // used to stop a subscription
}

extension NostrClientMessageTypeExtension on NostrClientMessageType {
  String get value {
    switch (this) {
      case NostrClientMessageType.event:
        return 'EVENT';
      case NostrClientMessageType.req:
        return 'REQ';
      case NostrClientMessageType.close:
        return 'CLOSE';
    }
  }

  static NostrClientMessageType fromValue(String value) {
    switch (value) {
      case 'EVENT':
        return NostrClientMessageType.event;
      case 'REQ':
        return NostrClientMessageType.req;
      case 'CLOSE':
        return NostrClientMessageType.close;
      default:
        throw Exception('Unknown NostrClientMessageType: $value');
    }
  }
}
