import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet/nwc_wallet.dart';
import 'package:nwc_wallet_app/entities/nwc_connection_entity.dart';

@immutable
class NwcConnectionViewModel extends Equatable {
  const NwcConnectionViewModel({
    required this.name,
    required this.pubkey,
    required this.permittedMethods,
  });

  final String name;
  final String pubkey;
  final List<NwcMethod> permittedMethods;

  factory NwcConnectionViewModel.fromEntity(NwcConnectionEntity entity) {
    return NwcConnectionViewModel(
      name: entity.name,
      pubkey: entity.pubkey,
      permittedMethods: entity.permittedMethods,
    );
  }

  @override
  List<Object?> get props => [
        name,
        pubkey,
        permittedMethods,
      ];
}
