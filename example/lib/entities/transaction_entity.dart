import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TransactionEntity extends Equatable {
  final String id;
  final int receivedAmountSat;
  final int sentAmountSat;
  final int? timestamp;

  const TransactionEntity({
    required this.id,
    this.receivedAmountSat = 0,
    this.sentAmountSat = 0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        receivedAmountSat,
        sentAmountSat,
        timestamp,
      ];
}
