import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SendState extends Equatable {
  const SendState({
    this.amountSat,
    this.invoice,
    this.satPerVbyte,
    this.isMakingPayment = false,
    this.error,
    this.recommendedFeeRates,
    this.txId,
  });

  final int? amountSat;
  final String? invoice;
  final double? satPerVbyte;
  final bool isMakingPayment;
  final Exception? error;
  final List<double>? recommendedFeeRates;
  final String? txId;

  double? get amountBtc {
    if (amountSat == null) {
      return null;
    }

    return amountSat! / 100000000;
  }

  SendState copyWith({
    int? amountSat,
    bool? clearAmountSat,
    String? invoice,
    double? satPerVbyte,
    bool? isMakingPayment,
    Exception? error,
    bool? clearError,
    List<double>? recommendedFeeRates,
    String? txId,
  }) {
    return SendState(
      amountSat: clearAmountSat == true ? null : amountSat ?? this.amountSat,
      invoice: invoice ?? this.invoice,
      satPerVbyte: satPerVbyte ?? this.satPerVbyte,
      isMakingPayment: isMakingPayment ?? this.isMakingPayment,
      error: clearError == true ? null : error ?? this.error,
      recommendedFeeRates: recommendedFeeRates ?? this.recommendedFeeRates,
      txId: txId ?? this.txId,
    );
  }

  String? get partialTxId {
    if (txId == null) {
      return null;
    }

    return '${txId!.substring(0, 8)}...${txId!.substring(txId!.length - 8)}';
  }

  @override
  List<Object?> get props => [
        amountSat,
        invoice,
        satPerVbyte,
        isMakingPayment,
        error,
        recommendedFeeRates,
        txId,
      ];
}
