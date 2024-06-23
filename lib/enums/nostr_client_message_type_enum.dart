import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrClientMessageType {
  event(NostrConstants.clientMessageEventType), // used to publish events
  req(NostrConstants
      .clientMessageRequestType), // used to request events and subscribe to new updates
  close(NostrConstants.clientMessageCloseType); // used to stop a subscription

  final String value;

  const NostrClientMessageType(this.value);

  factory NostrClientMessageType.fromValue(String value) {
    switch (value) {
      case NostrConstants.clientMessageEventType:
        return NostrClientMessageType.event;
      case NostrConstants.clientMessageRequestType:
        return NostrClientMessageType.req;
      case NostrConstants.clientMessageCloseType:
        return NostrClientMessageType.close;
      default:
        throw ArgumentError('Invalid client message type');
    }
  }
}
