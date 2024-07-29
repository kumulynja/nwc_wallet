import 'package:equatable/equatable.dart';
import 'package:nwc_wallet_app/enums/payment_direction.dart';
import 'package:flutter/foundation.dart';

@immutable
class PaymentDetailsEntity extends Equatable {
  final String paymentHash;
  final int? amountSat;
  final PaymentDirection direction;
  final int? timestamp;
  final String? preimage;
  final bool? isPaid;
  final int latestUpdateTimestamp;

  const PaymentDetailsEntity({
    required this.paymentHash,
    this.amountSat,
    required this.direction,
    this.timestamp,
    this.preimage,
    this.isPaid,
    required this.latestUpdateTimestamp,
  });

  factory PaymentDetailsEntity.fromMap(Map<String, dynamic> map) {
    return PaymentDetailsEntity(
      paymentHash: map['paymentHash'],
      amountSat: map['amountSat'],
      direction: PaymentDirection.fromPlaintext(map['direction']),
      timestamp: map['timestamp'],
      preimage: map['preimage'],
      isPaid: map['isPaid'],
      latestUpdateTimestamp: map['latestUpdateTimestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentHash': paymentHash,
      'amountSat': amountSat,
      'direction': direction.plaintext,
      'timestamp': timestamp,
      'preimage': preimage,
      'isPaid': isPaid,
      'latestUpdateTimestamp': latestUpdateTimestamp,
    };
  }

  @override
  List<Object?> get props => [
        paymentHash,
        amountSat,
        direction,
        timestamp,
        preimage,
        isPaid,
        latestUpdateTimestamp,
      ];
}
