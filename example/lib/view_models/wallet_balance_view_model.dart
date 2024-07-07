import 'package:equatable/equatable.dart';
import 'package:example/enums/lightning_node_implementation.dart';
import 'package:flutter/material.dart';

@immutable
class WalletBalanceViewModel extends Equatable {
  const WalletBalanceViewModel({
    required this.lightningNodeImplementation,
    this.balanceSat,
  });

  final LightningNodeImplementation lightningNodeImplementation;
  final int? balanceSat;

  double? get balanceBtc => balanceSat != null ? balanceSat! / 100000000 : null;

  @override
  List<Object?> get props => [
        lightningNodeImplementation,
        balanceSat,
      ];
}
