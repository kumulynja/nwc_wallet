import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

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

  @override
  List<Object?> get props => [
        name,
        pubkey,
        permittedMethods,
      ];
}
