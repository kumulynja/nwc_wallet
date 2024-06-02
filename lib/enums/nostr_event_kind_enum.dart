import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrEventKind {
  nip47InfoEvent,
  nip47Request,
  nip47Response,
}

extension NostrEventKindX on NostrEventKind {
  int get value {
    switch (this) {
      case NostrEventKind.nip47InfoEvent:
        return NostrConstants.nip47InfoEventKind;
      case NostrEventKind.nip47Request:
        return NostrConstants.nip47RequestKind;
      case NostrEventKind.nip47Response:
        return NostrConstants.nip47ResponseKind;
    }
  }

  static NostrEventKind fromValue(int value) {
    switch (value) {
      case NostrConstants.nip47InfoEventKind:
        return NostrEventKind.nip47InfoEvent;
      case NostrConstants.nip47RequestKind:
        return NostrEventKind.nip47Request;
      case NostrConstants.nip47ResponseKind:
        return NostrEventKind.nip47Response;
      default:
        throw Exception('Unknown NostrEventKind value: $value');
    }
  }
}
