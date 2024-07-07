import 'package:equatable/equatable.dart';
import 'package:example/enums/payment_direction.dart';
import 'package:flutter/foundation.dart';

@immutable
class PaymentDetailsEntity extends Equatable {
  final String paymentHash;
  final int? amountSat;
  final PaymentDirection direction;
  final int? timestamp;
  final String? preimage;
  final bool? isPaid;

  const PaymentDetailsEntity({
    required this.paymentHash,
    this.amountSat,
    required this.direction,
    this.timestamp,
    this.preimage,
    this.isPaid,
  });

  @override
  List<Object?> get props => [
        paymentHash,
        amountSat,
        direction,
        timestamp,
        preimage,
        isPaid,
      ];
}
