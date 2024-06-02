import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class NostrEvent extends Equatable {
  final String? id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final List<List<String>> tags;
  final String content;
  final String? sig;

  const NostrEvent({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
    required this.sig,
  });

  factory NostrEvent.fromMap(Map<String, dynamic> map) {
    return NostrEvent(
      id: map['id'],
      pubkey: map['pubkey'],
      createdAt: map['createdAt'],
      kind: map['kind'],
      tags: List<List<String>>.from(map['tags']),
      content: map['content'],
      sig: map['sig'],
    );
  }

  NostrEvent copyWith({
    String? id,
    String? pubkey,
    int? createdAt,
    int? kind,
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

  String get calculatedId {
    final event = [
      0,
      pubkey.toLowerCase(),
      createdAt,
      kind,
      tags,
      content,
    ];

    final jsonString = jsonEncode(event);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    final id = hex.encode(digest.bytes);

    return id;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pubkey': pubkey,
      'createdAt': createdAt,
      'kind': kind,
      'tags': tags,
      'content': content,
      'sig': sig,
    };
  }

  @override
  List<Object?> get props => [id, pubkey, createdAt, kind, tags, content, sig];
}
