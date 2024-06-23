import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

@immutable
class NwcConnectionModel extends Equatable {
  final String name;
  final String connectionPubkey;
  final String relayUrl;
  final List<NwcMethod> permittedMethods;
  final int? monthlyLimitSat;
  final int? expiry;

  const NwcConnectionModel({
    required this.name,
    required this.connectionPubkey,
    required this.relayUrl,
    required this.permittedMethods,
    this.monthlyLimitSat,
    this.expiry,
  });

  NwcConnectionModel copyWith({
    String? name,
    String? connectionPubkey,
    String? relayUrl,
    List<NwcMethod>? permittedMethods,
    int? monthlyLimitSat,
    int? expiry,
  }) {
    return NwcConnectionModel(
      name: name ?? this.name,
      connectionPubkey: connectionPubkey ?? this.connectionPubkey,
      relayUrl: relayUrl ?? this.relayUrl,
      permittedMethods: permittedMethods ?? this.permittedMethods,
      monthlyLimitSat: monthlyLimitSat ?? this.monthlyLimitSat,
      expiry: expiry ?? this.expiry,
    );
  }

  @override
  List<Object?> get props => [
        name,
        connectionPubkey,
        relayUrl,
        permittedMethods,
        monthlyLimitSat,
        expiry,
      ];
}
