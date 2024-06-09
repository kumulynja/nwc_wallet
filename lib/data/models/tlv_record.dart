import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TlvRecord extends Equatable {
  final int type;
  final String value;

  const TlvRecord({
    required this.type,
    required this.value,
  });

  factory TlvRecord.fromMap(Map<String, dynamic> map) {
    return TlvRecord(
      type: map['type'] as int,
      value: map['value'] as String,
    );
  }

  @override
  List<Object?> get props => [type, value];
}
