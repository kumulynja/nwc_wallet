import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NostrEventKind {
  userMetadata(NostrConstants.nip01UserMetadataKind),
  textNote(NostrConstants.nip01TextNoteKind),
  nip47InfoEvent(NostrConstants.nip47InfoEventKind),
  nip47Request(NostrConstants.nip47RequestKind),
  nip47Response(NostrConstants.nip47ResponseKind);

  final int value;

  const NostrEventKind(this.value);

  factory NostrEventKind.fromValue(int value) {
    switch (value) {
      case NostrConstants.nip01UserMetadataKind:
        return NostrEventKind.userMetadata;
      case NostrConstants.nip01TextNoteKind:
        return NostrEventKind.textNote;
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
