enum NostrEventKind {
  nip47InfoEvent,
  nip47Request,
  nip47Response,
}

extension NostrEventKindX on NostrEventKind {
  int get value {
    switch (this) {
      case NostrEventKind.nip47InfoEvent:
        return 13194;
      case NostrEventKind.nip47Request:
        return 23194;
      case NostrEventKind.nip47Response:
        return 23195;
    }
  }

  static NostrEventKind fromValue(int value) {
    switch (value) {
      case 13194:
        return NostrEventKind.nip47InfoEvent;
      case 23194:
        return NostrEventKind.nip47Request;
      case 23195:
        return NostrEventKind.nip47Response;
      default:
        throw Exception('Unknown NostrEventKind value: $value');
    }
  }
}
