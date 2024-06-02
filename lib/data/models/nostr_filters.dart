import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ids': ids,
      'authors': authors,
      'kinds': kinds,
      'tags': tags,
      'since': since,
      'until': until,
      'limit': limit,
    };
  }

  @override
  List<Object?> get props => [ids, authors, kinds, tags, since, until, limit];
}
