import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrEventKind {
  nip47InfoEvent(NostrConstants.nip47InfoEventKind),
  nip47Request(NostrConstants.nip47RequestKind),
  nip47Response(NostrConstants.nip47ResponseKind);

  final int value;

  const NostrEventKind(this.value);

  factory NostrEventKind.fromValue(int value) {
    switch (value) {
      case NostrConstants.nip47InfoEventKind:
        return NostrEventKind.nip47InfoEvent;
      case NostrConstants.nip47RequestKind:
        return NostrEventKind.nip47Request;
      case NostrConstants.nip47ResponseKind:
        return NostrEventKind.nip47Response;
      default:
        throw ArgumentError('Invalid event kind value: $value');
    }
  }
}
