import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';
import 'package:nwc_wallet/nips/nip01.dart';

@immutable
class NostrEvent extends Equatable {
  final String? id;
  final String pubkey;
  final int createdAt;
  final NostrEventKind kind;
  final List<List<String>> tags;
  final String content;
  final String? sig;

  const NostrEvent({
    this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    this.tags = const [],
    required this.content,
    this.sig,
  });

  factory NostrEvent.fromMap(Map<String, dynamic> map) {
    return NostrEvent(
      id: map['id'],
      pubkey: map['pubkey'],
      createdAt: map['created_at'],
      kind: NostrEventKind.fromValue(map['kind']),
      tags: List<List<String>>.from(map['tags']),
      content: map['content'],
      sig: map['sig'],
    );
  }

  NostrEvent copyWith({
    String? id,
    String? pubkey,
    int? createdAt,
    NostrEventKind? kind,
    List<List<String>>? tags,
    String? content,
    String? sig,
  }) {
    return NostrEvent(
      id: id ?? this.id,
      pubkey: pubkey ?? this.pubkey,
      createdAt: createdAt ?? this.createdAt,
      kind: kind ?? this.kind,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      sig: sig ?? this.sig,
    );
  }

  String get calculatedId => Nip01.calculateEventId(
        pubkey: pubkey,
        createdAt: createdAt,
        kind: kind,
        tags: tags,
        content: content,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pubkey': pubkey,
      'created_at': createdAt,
      'kind': kind.value,
      'tags': tags,
      'content': content,
      'sig': sig,
    };
  }

  @override
  List<Object?> get props => [id, pubkey, createdAt, kind, tags, content, sig];
}
