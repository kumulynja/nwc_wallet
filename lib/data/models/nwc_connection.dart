import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

@immutable
class NwcConnection extends Equatable {
  final String name;
  final String connectionPubkey;
  final List<NwcMethod> permittedMethods;
  final int? monthlyLimitSat;
  final int? expiry;

  const NwcConnection({
    required this.name,
    required this.connectionPubkey,
    required this.permittedMethods,
    this.monthlyLimitSat,
    this.expiry,
  });

  @override
  List<Object?> get props => [
        name,
        connectionPubkey,
        permittedMethods,
        monthlyLimitSat,
        expiry,
      ];
}
