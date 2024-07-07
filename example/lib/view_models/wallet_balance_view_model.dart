import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class WalletBalanceViewModel extends Equatable {
  const WalletBalanceViewModel({
    this.balanceSat,
  });

  final int? balanceSat;

  @override
  List<Object?> get props => [
        balanceSat,
      ];
}
