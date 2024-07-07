import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class ReceiveState extends Equatable {
  const ReceiveState({
    this.amountSat,
    this.isInvalidAmount = false,
    this.label,
    this.message,
    this.bitcoinInvoice,
    this.lightningInvoice,
    this.isGeneratingInvoice = false,
  });

  final int? amountSat;
  final bool isInvalidAmount;
  final String? label;
  final String? message;
  final String? bitcoinInvoice;
  final String? lightningInvoice;
  final bool isGeneratingInvoice;

  double? get amountBtc {
    if (amountSat == null) {
      return null;
    }

    return amountSat! / 100000000;
  }

  String? get bip21Uri {
    if (bitcoinInvoice == null || bitcoinInvoice!.isEmpty) {
      if (lightningInvoice == null || lightningInvoice!.isEmpty) {
        return null;
      } else {
        return lightningInvoice;
      }
    }

    if ((lightningInvoice == null || lightningInvoice!.isEmpty) &&
        amountSat == null &&
        label == null &&
        message == null) {
      return bitcoinInvoice;
    }

    return 'bitcoin:$bitcoinInvoice?'
        '${amountBtc != null ? 'amount=$amountBtc' : ''}'
        '${label != null ? '&label=$label' : ''}'
        '${message != null ? '&message=$message' : ''}'
        '${lightningInvoice != null ? '&lightning=$lightningInvoice' : ''}';
  }

  ReceiveState copyWith({
    int? amountSat,
    bool? isInvalidAmount,
    String? label,
    String? message,
    String? bitcoinInvoice,
    String? lightningInvoice,
    bool? isGeneratingInvoice,
  }) {
    return ReceiveState(
      amountSat: amountSat ?? this.amountSat,
      isInvalidAmount: isInvalidAmount ?? this.isInvalidAmount,
      label: label ?? this.label,
      message: message ?? this.message,
      bitcoinInvoice: bitcoinInvoice ?? this.bitcoinInvoice,
      lightningInvoice: lightningInvoice ?? this.lightningInvoice,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
    );
  }

  @override
  List<Object?> get props => [
        amountSat,
        isInvalidAmount,
        label,
        message,
        bitcoinInvoice,
        lightningInvoice,
        isGeneratingInvoice,
      ];
}
