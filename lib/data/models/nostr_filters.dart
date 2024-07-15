import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nostr_event_kind.dart';

@immutable
class NostrFilters extends Equatable {
  final List<String>? ids;
  final List<String>? authors;
  final List<int>? kinds;
  final Map<String, List<String>>? tags;
  final int? since;
  final int? until;
  final int? limit;

  const NostrFilters({
    this.ids,
    this.authors,
    this.kinds,
    this.tags,
    this.since,
    this.until,
    this.limit,
  });

  factory NostrFilters.nwcRequests({
    required String walletPublicKey,
    int? since,
  }) =>
      NostrFilters(
        kinds: [NostrEventKind.nip47Request.value],
        tags: {
          'p': [walletPublicKey]
        },
        since: since,
      );

  Map<String, dynamic> toMap() {
    final filter = <String, dynamic>{
      if (ids != null) 'ids': ids,
      if (authors != null) 'authors': authors,
      if (kinds != null) 'kinds': kinds,
      if (since != null) 'since': since,
      if (until != null) 'until': until,
      if (limit != null) 'limit': limit,
    };

    if (tags != null) {
      for (var tag in tags!.entries) {
        filter['#${tag.key}'] = tag.value;
      }
    }

    return filter;
  }

  @override
  List<Object?> get props => [ids, authors, kinds, tags, since, until, limit];
}
