import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

@immutable
class NwcConnectionEntity extends Equatable {
  const NwcConnectionEntity({
    required this.name,
    required this.pubkey,
    required this.permittedMethods,
  });

  final String name;
  final String pubkey;
  final List<NwcMethod> permittedMethods;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pubkey': pubkey,
      'permittedMethods': permittedMethods.map((e) => e.plaintext).toList(),
    };
  }

  factory NwcConnectionEntity.fromJson(Map<String, dynamic> json) {
    return NwcConnectionEntity(
      name: json['name'] as String,
      pubkey: json['pubkey'] as String,
      permittedMethods: (json['permittedMethods'] as List)
          .map((e) => NwcMethod.fromPlaintext(e as String))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        name,
        pubkey,
        permittedMethods,
      ];
}
