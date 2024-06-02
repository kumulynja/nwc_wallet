enum NostrRelayMessageType {
  event, // used to send events requested by clients
  ok, // used to indicate acceptance or denial of an EVENT message
  eose, // used to indicate the end of stored events and the beginning of events newly received in real-time
  closed, // used to indicate that a subscription was ended on the server side
  notice, // used to send human-readable error messages or other things to clients
}

extension NostrRelayMessageTypeX on NostrRelayMessageType {
  String get value {
    switch (this) {
      case NostrRelayMessageType.event:
        return 'EVENT';
      case NostrRelayMessageType.ok:
        return 'OK';
      case NostrRelayMessageType.eose:
        return 'EOSE';
      case NostrRelayMessageType.closed:
        return 'CLOSED';
      case NostrRelayMessageType.notice:
        return 'NOTICE';
    }
  }

  static NostrRelayMessageType fromValue(String value) {
    switch (value) {
      case 'EVENT':
        return NostrRelayMessageType.event;
      case 'OK':
        return NostrRelayMessageType.ok;
      case 'EOSE':
        return NostrRelayMessageType.eose;
      case 'CLOSED':
        return NostrRelayMessageType.closed;
      case 'NOTICE':
        return NostrRelayMessageType.notice;
      default:
        throw Exception('Unknown NostrRelayMessageType: $value');
    }
  }
}
