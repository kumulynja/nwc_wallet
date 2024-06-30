import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/transaction_type.dart';

@immutable
class Transaction extends Equatable {
  final TransactionType type;
  final String? invoice;
  final String? description;
  final String? descriptionHash;
  final String? preimage;
  final String paymentHash;
  final int amountSat;
  final int feesPaidSat;
  final int createdAt;
  final int? expiresAt;
  final int? settledAt;
  final Map<dynamic, dynamic> metadata;

  const Transaction({
    required this.type,
    this.invoice,
    this.description,
    this.descriptionHash,
    this.preimage,
    required this.paymentHash,
    required this.amountSat,
    required this.feesPaidSat,
    required this.createdAt,
    this.expiresAt,
    this.settledAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        type,
        invoice,
        description,
        descriptionHash,
        preimage,
        paymentHash,
        amountSat,
        feesPaidSat,
        createdAt,
        expiresAt,
        settledAt,
        metadata,
      ];
}
