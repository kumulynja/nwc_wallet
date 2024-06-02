import 'package:nwc_wallet/constants/nostr_constants.dart';

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
        return NostrConstants.relayMessageEventType;
      case NostrRelayMessageType.ok:
        return NostrConstants.relayMessageOkType;
      case NostrRelayMessageType.eose:
        return NostrConstants.relayMessageEoseType;
      case NostrRelayMessageType.closed:
        return NostrConstants.relayMessageClosedType;
      case NostrRelayMessageType.notice:
        return NostrConstants.relayMessageNoticeType;
    }
  }

  static NostrRelayMessageType fromValue(String value) {
    switch (value) {
      case NostrConstants.relayMessageEventType:
        return NostrRelayMessageType.event;
      case NostrConstants.relayMessageOkType:
        return NostrRelayMessageType.ok;
      case NostrConstants.relayMessageEoseType:
        return NostrRelayMessageType.eose;
      case NostrConstants.relayMessageClosedType:
        return NostrRelayMessageType.closed;
      case NostrConstants.relayMessageNoticeType:
        return NostrRelayMessageType.notice;
      default:
        throw Exception('Unknown NostrRelayMessageType: $value');
    }
  }
}
