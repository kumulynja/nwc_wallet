import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';

class Nip01 {
  static String calculateEventId({
    required String pubkey,
    required int createdAt,
    required NostrEventKind kind,
    required List tags,
    required String content,
  }) {
    final data = [
      0,
      pubkey,
      createdAt,
      kind.value,
      tags,
      content,
    ];

    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    final id = hex.encode(digest.bytes);

    return id;
  }
}
