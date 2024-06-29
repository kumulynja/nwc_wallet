import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrRelayMessageType {
  event(
    NostrConstants.relayMessageEventType,
  ), // used to send events requested by clients
  ok(
    NostrConstants.relayMessageOkType,
  ), // used to indicate acceptance or denial of an EVENT message
  eose(
    NostrConstants.relayMessageEoseType,
  ), // used to indicate the end of stored events and the beginning of events newly received in real-time
  closed(
    NostrConstants.relayMessageClosedType,
  ), // used to indicate that a subscription was ended on the server side
  notice(
    NostrConstants.relayMessageNoticeType,
  ); // used to send human-readable error messages or other things to clients

  final String value;

  const NostrRelayMessageType(this.value);

  factory NostrRelayMessageType.fromValue(String value) {
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
        throw ArgumentError('Invalid relay message type');
    }
  }
}
